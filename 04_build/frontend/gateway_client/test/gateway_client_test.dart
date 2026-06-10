import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as corpus;
import 'package:caliber_eval_frontend/caliber_eval_frontend.dart' as eval;
import 'package:caliber_gateway_client/caliber_gateway_client.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:test/test.dart';

void main() {
  test(
    'posts gateway envelope with bearer auth and parses canonical response',
    () async {
      String? authorization;
      Map<String, Object?>? postedBody;
      final server = await _startServer((request, body) async {
        authorization = request.headers.value(HttpHeaders.authorizationHeader);
        postedBody = jsonDecode(body) as Map<String, Object?>;
        await _writeJson(request.response, <String, Object?>{
          'request_hash': 'b' * 64,
          'canonical_json': jsonEncode(_schemaJudgmentJson()),
          'output_hash': 'c' * 64,
          'cache_hit': false,
          'attempts': 1,
          'audit_ref': 'audit:${'b' * 24}',
        });
      });
      addTearDown(server.close);

      final client = GatewayClient(
        config: GatewayClientConfig(
          baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
          apiKey: 'test-key',
        ),
      );

      final judgment = await client.judgeInterviewContent(_request());

      expect(authorization, 'Bearer test-key');
      expect(postedBody?['feature'], 'interview_content');
      expect(postedBody?['answer'], 'I led the migration.');
      expect(judgment.judgmentId, 'judgment-1');
      expect(judgment.answerId, 'answer-1');
      expect(judgment.band, 'at_bar');
      expect(judgment.levelRead, 'at_bar');
      expect(judgment.recommendedActions.single, 'Add quantified outcomes.');
      expect(judgment.evidenceSpans.single.recordId, 'source-1');
      expect(judgment.evidenceMetadata.single['criterion_id'], 'ownership');
      expect(judgment.evidenceMetadata.single['criterion_status'], 'partial');
      expect(
        judgment.evidenceMetadata.single['provider_suggested_band'],
        'below_bar',
      );
      expect(
        judgment.evidenceMetadata.single['deterministic_level_band'],
        'at_bar',
      );
    },
  );

  test('cost guard ignores retry fan-out even when configured', () async {
    var attempts = 0;
    final server = await _startServer((request, body) async {
      attempts += 1;
      request.response.statusCode = HttpStatus.serviceUnavailable;
      request.response.write('temporary');
      await request.response.close();
    });
    addTearDown(server.close);

    final client = GatewayClient(
      config: GatewayClientConfig(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
        retries: 3,
      ),
    );

    await expectLater(
      client.judgeInterviewContent(_request()),
      throwsA(
        isA<GatewayHttpException>()
            .having((error) => error.statusCode, 'statusCode', 503)
            .having((error) => error.attempts, 'attempts', 1),
      ),
    );
    expect(attempts, 1);
  });

  test('does not retry server failures by default', () async {
    var attempts = 0;
    final server = await _startServer((request, body) async {
      attempts += 1;
      request.response.statusCode = HttpStatus.serviceUnavailable;
      request.response.write('temporary');
      await request.response.close();
    });
    addTearDown(server.close);

    final client = GatewayClient(
      config: GatewayClientConfig(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      ),
    );

    await expectLater(
      client.judgeInterviewContent(_request()),
      throwsA(
        isA<GatewayHttpException>()
            .having((error) => error.statusCode, 'statusCode', 503)
            .having((error) => error.attempts, 'attempts', 1),
      ),
    );
    expect(attempts, 1);
  });

  test('maps non-retryable http errors', () async {
    final server = await _startServer((request, body) async {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write('bad-request');
      await request.response.close();
    });
    addTearDown(server.close);

    final client = GatewayClient(
      config: GatewayClientConfig(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
        retries: 3,
      ),
    );

    await expectLater(
      client.judgeInterviewContent(_request()),
      throwsA(
        isA<GatewayHttpException>()
            .having((error) => error.statusCode, 'statusCode', 400)
            .having((error) => error.attempts, 'attempts', 1),
      ),
    );
  });

  test('maps invalid schema responses to decode errors', () async {
    final server = await _startServer((request, body) async {
      await _writeJson(request.response, <String, Object?>{
        'canonical_json': jsonEncode(<String, Object?>{'bad': true}),
      });
    });
    addTearDown(server.close);

    final client = GatewayClient(
      config: GatewayClientConfig(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      ),
    );

    await expectLater(
      client.judgeInterviewContent(_request()),
      throwsA(isA<GatewayDecodeException>()),
    );
  });

  test('config reads base URL and api key from an environment map', () {
    final config = GatewayClientConfig.fromEnvironment(
      environment: <String, String>{
        'CALIBER_AI_GATEWAY_BASE_URL': 'http://127.0.0.1:9999/base',
        'CALIBER_AI_GATEWAY_API_KEY': 'env-key',
        'CALIBER_AI_GATEWAY_RETRIES': '2',
      },
    );

    expect(config.baseUrl, Uri.parse('http://127.0.0.1:9999/base'));
    expect(
      config.endpoint,
      Uri.parse('http://127.0.0.1:9999/base/v1/judge/interview'),
    );
    expect(config.apiKey, 'env-key');
    expect(config.retries, 0);
  });

  test('config requires explicit base URL for gateway mode', () {
    expect(
      () =>
          GatewayClientConfig.fromEnvironment(environment: <String, String>{}),
      throwsA(isA<StateError>()),
    );
  });
}

Future<HttpServer> _startServer(
  Future<void> Function(HttpRequest request, String body) handler,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  unawaited(
    server.forEach((request) async {
      final body = await utf8.decoder.bind(request).join();
      await handler(request, body);
    }),
  );
  return server;
}

Future<void> _writeJson(
  HttpResponse response,
  Map<String, Object?> payload,
) async {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(payload));
  await response.close();
}

eval.StructuredJudgeRequest _request() {
  return eval.StructuredJudgeRequest(
    answerId: 'answer-1',
    questionId: 'question-1',
    normalizedAnswer: 'I led the migration.',
    schemaVersion: 'ai-output-v1',
    rubricVersion: 'rubric-v1',
    promptVersion: 'prompt-v1',
    corpusBundleVersion: 'corpus-v1',
    routingPolicyVersion: 'route-policy-v1',
    routeHash: 'a' * 64,
    fixedCorpusSubset: <corpus.RetrievedCorpusRecord>[
      corpus.RetrievedCorpusRecord(
        record: corpus.CorpusRecord(
          recordId: 'record-1',
          kind: corpus.CorpusRecordKind.rubricSlice,
          title: 'Ownership',
          body: 'Looks for direct ownership.',
          corpusBundleVersion: 'corpus-v1',
          tags: <String>['ownership'],
        ),
        score: 1,
        evidenceSpans: <corpus.CorpusEvidenceSpan>[
          corpus.CorpusEvidenceSpan(
            recordId: 'source-1',
            startOffset: 0,
            endOffset: 20,
            text: 'I led the migration.',
            corpusBundleVersion: 'corpus-v1',
            score: 1,
          ),
        ],
      ),
    ],
  );
}

Map<String, Object?> _schemaJudgmentJson() {
  final payload = schema.InterviewContentJudgment(
    judgmentId: 'judgment-1',
    profileId: 'profile-1',
    target: const schema.TargetRoleCompany(
      roleId: 'role-1',
      domain: 'mobile',
      levelBand: 'senior',
      companyArchetype: 'startup',
    ),
    questionId: 'question-1',
    answerTranscriptId: 'answer-1',
    rubricVersion: 'rubric-v1',
    promptVersion: 'prompt-v1',
    modelId: 'gpt-5.4-mini',
    levelBand: 'at_bar',
    strengths: <String>['Clear ownership.'],
    risks: <String>['Needs more metrics.'],
    recommendedActions: <String>['Add quantified outcomes.'],
    evidenceSpans: const <schema.EvidenceSpan>[
      schema.EvidenceSpan(
        sourceId: 'source-1',
        sourceType: 'answer',
        startOffset: 0,
        endOffset: 20,
        quote: 'I led the migration.',
      ),
    ],
    createdAt: DateTime.utc(2026),
  ).toJson();
  payload['criterion_marks'] = <Map<String, Object?>>[
    <String, Object?>{
      'criterion_id': 'ownership',
      'criterion_label': 'Ownership',
      'status': 'partial',
      'exact_quote': 'I led the migration.',
      'quote_start': 0,
      'quote_end': 20,
      'finding': 'The answer names ownership but lacks impact detail.',
      'down_level_reason':
          'Ownership is not yet tied to measurable senior impact.',
      'minimum_fix': 'Add the metric or operational impact of the migration.',
    },
  ];
  payload['provider_suggested_band'] = 'below_bar';
  payload['deterministic_level_band'] = 'at_bar';
  return payload;
}

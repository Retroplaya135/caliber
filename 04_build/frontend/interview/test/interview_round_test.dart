import 'dart:convert';
import 'dart:io';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as corpus;
import 'package:caliber_eval_frontend/caliber_eval_frontend.dart' as eval;
import 'package:caliber_interview/interview.dart';
import 'package:caliber_interview/src/block10_benchmark_safety.dart';
import 'package:caliber_interview/src/block10_debug_artifact.dart';
import 'package:caliber_interview/src/block10_proof_validation.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:caliber_speech_stack/speech_stack.dart' as speech;
import 'package:test/test.dart';

void main() {
  test('runInterviewRound returns calibrated judgment with answer quotes', () async {
    final judgment = await runInterviewRound(
      kSeedBackendPracticeQuestion,
      'I would define tenant quotas, burst policy, and latency budget first. '
      'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
      'The tradeoff versus sliding windows is less exact fairness. '
      'For login I would fail closed after a timeout, while read-only traffic can fail open. '
      'I would measure p95 latency and reject rate.',
      now: DateTime.utc(2026, 6, 4, 12),
    );

    expect(judgment, isA<schema.InterviewContentJudgment>());
    expect(judgment.questionId, kSeedBackendPracticeQuestion.questionId);
    expect(judgment.modelId, 'local-deterministic-rubric-verdict.v0.1');
    expect(judgment.rubricVersion, 'backend_depth_l5_l6_seed.v0.1');
    expect(
      judgment.levelBand,
      isIn(<String>{'below_bar', 'approaching', 'at_bar'}),
    );
    expect(jsonEncode(judgment.toJson()), isNot(contains('score')));
    expect(
      judgment.strengths.any((item) => item.startsWith('Content:')),
      isTrue,
    );
    expect(
      <String>[
        ...judgment.strengths,
        ...judgment.risks,
      ].any((item) => item.startsWith('Delivery:')),
      isTrue,
    );
    expect(judgment.risks.any((item) => item.startsWith('Content:')), isTrue);
    expect(judgment.evidenceSpans, isNotEmpty);
    expect(
      judgment.evidenceSpans
          .map((span) => span.metadata['criterion_id'])
          .whereType<String>(),
      contains('failure_modes'),
    );
    expect(
      judgment.evidenceSpans.map((span) => span.quote).whereType<String>(),
      contains(contains('fail closed')),
    );
    for (final span in judgment.evidenceSpans) {
      final quote = span.quote!;
      expect(
        quote,
        'I would define tenant quotas, burst policy, and latency budget first. '
                'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
                'The tradeoff versus sliding windows is less exact fairness. '
                'For login I would fail closed after a timeout, while read-only traffic can fail open. '
                'I would measure p95 latency and reject rate.'
            .substring(span.startOffset, span.endOffset)
            .trim(),
      );
      expect(span.metadata['minimum_fix'], isA<String>());
    }
  });

  test('runInterviewRound is reproducible for same answer and rubric', () async {
    const answer =
        'I would define tenant quotas, burst policy, and latency budget first. '
        'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
        'The tradeoff versus sliding windows is less exact fairness. '
        'For login I would fail closed after a timeout, while read-only traffic can fail open. '
        'I would measure p95 latency and reject rate.';

    final first = await runInterviewRound(kSeedBackendPracticeQuestion, answer);
    final second = await runInterviewRound(
      kSeedBackendPracticeQuestion,
      answer,
    );

    expect(jsonEncode(first.toJson()), jsonEncode(second.toJson()));
  });

  test('configured judge defaults to local unless gateway is requested', () {
    final judge = buildConfiguredStructuredJudge(
      environment: const <String, String>{},
      clock: () => DateTime.utc(2026, 6, 4),
    );

    expect(judge, isA<LocalDeterministicStructuredJudge>());
  });

  test('configured judge can select gateway behind the same interface', () {
    final judge = buildConfiguredStructuredJudge(
      environment: const <String, String>{
        'CALIBER_INTERVIEW_JUDGE': 'gateway',
        'CALIBER_AI_GATEWAY_BASE_URL': 'http://127.0.0.1:8000',
      },
      clock: () => DateTime.utc(2026, 6, 4),
    );

    expect(judge, isA<GatewayStructuredJudgeAdapter>());
    expect(judge, isA<schema.StructuredJudge>());
  });

  test('gateway adapter leaves missing criterion id invalid', () async {
    const answer =
        'I would define tenant quotas, burst policy, and latency budget first. '
        'Then I would compare token bucket with sliding windows. '
        'For login I would fail closed, while read-only traffic can fail open.';
    final judgment = await runInterviewRound(
      kSeedBackendPracticeQuestion,
      answer,
      judge: GatewayStructuredJudgeAdapter(
        gatewayClient: _GatewayMetadataJudge(
          evidenceMetadata: const <Map<String, Object?>>[<String, Object?>{}],
        ),
        clock: () => DateTime.utc(2026, 6, 5),
      ),
      now: DateTime.utc(2026, 6, 5),
    );

    expect(judgment.modelId, 'gpt-5.4-mini');
    expect(judgment.evidenceSpans, hasLength(1));
    expect(judgment.evidenceSpans.single.metadata['criterion_id'], isNull);
    expect(
      _validateForBlock10(answer, judgment).failures,
      contains('criterion_id_missing_on_evidence:0'),
    );
  });

  test('gateway adapter leaves unknown criterion id invalid', () async {
    const answer =
        'I would define tenant quotas, burst policy, and latency budget first. '
        'Then I would compare token bucket with sliding windows. '
        'For login I would fail closed, while read-only traffic can fail open.';
    final judgment = await runInterviewRound(
      kSeedBackendPracticeQuestion,
      answer,
      judge: GatewayStructuredJudgeAdapter(
        gatewayClient: _GatewayMetadataJudge(
          evidenceMetadata: const <Map<String, Object?>>[
            <String, Object?>{
              'criterion_id': 'not_a_signed_criterion',
              'criterion_label': 'Fake criterion',
              'criterion_status': 'partial',
              'down_level_reason': 'Fake rubric mapping.',
              'minimum_fix': 'Fake fix.',
            },
          ],
        ),
        clock: () => DateTime.utc(2026, 6, 5),
      ),
      now: DateTime.utc(2026, 6, 5),
    );

    expect(
      judgment.evidenceSpans.single.metadata['criterion_id'],
      'not_a_signed_criterion',
    );
    expect(
      _validateForBlock10(answer, judgment).failures,
      contains('criterion_id_unknown_on_evidence:0:not_a_signed_criterion'),
    );
  });

  test(
    'gateway adapter enriches labels only after valid signed criterion id',
    () async {
      const answer =
          'I would define tenant quotas, burst policy, and latency budget first. '
          'Then I would compare token bucket with sliding windows. '
          'For login I would fail closed, while read-only traffic can fail open.';
      final judgment = await runInterviewRound(
        kSeedBackendPracticeQuestion,
        answer,
        judge: GatewayStructuredJudgeAdapter(
          gatewayClient: _GatewayMetadataJudge(
            evidenceMetadata: const <Map<String, Object?>>[
              <String, Object?>{
                'criterion_id': 'failure_modes',
                'criterion_status': 'partial',
              },
            ],
          ),
          clock: () => DateTime.utc(2026, 6, 5),
        ),
        now: DateTime.utc(2026, 6, 5),
      );

      final span = judgment.evidenceSpans.single;
      expect(span.metadata['criterion_id'], 'failure_modes');
      expect(span.metadata['criterion_label'], isA<String>());
      expect(span.metadata['down_level_reason'], isA<String>());
      expect(span.metadata['minimum_fix'], isA<String>());
      expect(judgment.recommendedActions, hasLength(1));
      expect(judgment.recommendedActions.single, contains('Failure modes'));
      expect(judgment.recommendedActions.single, contains('fail closed'));
      expect(_validateForBlock10(answer, judgment).failures, isEmpty);
    },
  );

  test('interview memory compares current round to prior user round', () async {
    final store = InMemoryInterviewRoundMemoryStore();
    final first = await runInterviewRound(
      kSeedBackendPracticeQuestion,
      'I would use Redis.',
      now: DateTime.utc(2026, 6, 4, 12),
    );
    final firstComparison = await rememberInterviewJudgment(
      memoryStore: store,
      judgment: first,
    );

    final second = await runInterviewRound(
      kSeedBackendPracticeQuestion,
      'I would define tenant quotas, burst policy, and latency budget first. '
      'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
      'The tradeoff versus sliding windows is less exact fairness. '
      'For login I would fail closed after a timeout, while read-only traffic can fail open. '
      'I would measure p95 latency and reject rate.',
      now: DateTime.utc(2026, 6, 4, 13),
    );
    final secondComparison = await rememberInterviewJudgment(
      memoryStore: store,
      judgment: second,
    );

    expect(firstComparison, isNull);
    expect(secondComparison, isNotNull);
    expect(secondComparison!.previousJudgmentId, first.judgmentId);
    expect(secondComparison.currentJudgmentId, second.judgmentId);
    expect(secondComparison.summaryBullets, isNotEmpty);
    expect(
      secondComparison.summaryBullets.any(
        (item) => item.contains('Calibration'),
      ),
      isTrue,
    );
  });

  test('backend verdict benchmark rows omit numeric scores', () async {
    final rows = await buildBackendVerdictBenchmarkRows(limit: 1);
    final encoded = jsonEncode(rows);

    expect(rows, hasLength(1));
    expect(rows.single['rubric_version'], 'backend_depth_l5_l6_seed.v0.1');
    expect(
      rows.single['level_read'],
      isIn(<String>{'below_bar', 'approaching', 'at_bar'}),
    );
    expect(encoded, isNot(contains('content_score')));
    expect(encoded, isNot(contains('score')));
    expect(encoded, contains('criterion_id'));
  });

  test('Block 10 debug smoke artifact renders proof fields', () async {
    final judgment = await runInterviewRound(
      kSeedBackendPracticeQuestion,
      'I would use Redis counters, but I did not define quota policy or failure behavior.',
      now: DateTime.utc(2026, 6, 5),
    );
    final scenario = corpus.kBackendDepthRubric.scenarioForQuestion(
      kSeedBackendPracticeQuestion.questionId,
    );

    final markdown = renderBlock10DebugSmokeMarkdown(
      runId: 'debug-test',
      fixtureId: 'fixture-1',
      prompt: kSeedBackendPracticeQuestion.prompt,
      archetypeId: scenario.scenarioId,
      scenario: scenario,
      judgment: judgment,
      validationFailures: const <String>[],
      tokenCostLedger: const <String, Object?>{
        'estimated_prompt_tokens': 10,
        'estimated_completion_tokens': 5,
      },
    );

    expect(markdown, contains('# Caliber Block 10 Debug Smoke'));
    expect(markdown, contains('Fixture: `fixture-1`'));
    expect(markdown, contains('Level band: `'));
    expect(markdown, contains('## Criterion Marks'));
    expect(markdown, contains('Highest-leverage fix'));
    expect(markdown, contains('Token And Cost Ledger'));
  });

  test('Gate 0 suite wrapper keeps Caliber smoke before baselines', () {
    final suiteWrapper = File(
      '../../../tool/run_gate0_benchmark_suite.sh',
    ).readAsStringSync();
    final directDispatch = suiteWrapper.indexOf('CALIBER_ONLY_RUN');
    final openRouterRequire = suiteWrapper.indexOf(
      'require_secret OPENROUTER_API_KEY',
    );

    expect(suiteWrapper, contains('--caliber-debug-one'));
    expect(directDispatch, isNonNegative);
    expect(openRouterRequire, isNonNegative);
    expect(directDispatch, lessThan(openRouterRequire));
  });

  test('Block 10 harness separates transport failures and supports resume', () {
    final benchmarkTool = File(
      'bin/backend_gate0_blind_benchmark.dart',
    ).readAsStringSync();

    expect(benchmarkTool, contains('--chunk-size'));
    expect(benchmarkTool, contains('--retry-transport-failures-only'));
    expect(benchmarkTool, contains('caliber_rows_'));
    expect(benchmarkTool, contains('transport_failures'));
    expect(benchmarkTool, contains('calibration_failures'));
    expect(benchmarkTool, contains('discrepancy_packet_'));
    expect(benchmarkTool, contains('caliber_token_economics'));
    expect(benchmarkTool, contains('token_delta_scope'));
    expect(benchmarkTool, contains('proof_valid_rows'));
    expect(benchmarkTool, contains('actualValue > 0'));
    expect(benchmarkTool, contains('excludeAnswerIds: retrySelectedAnswerIds'));
    expect(
      benchmarkTool,
      contains("!retrySelectedAnswerIds.contains(row['answer_id'])"),
    );
    expect(benchmarkTool, contains('--baseline-only'));
    expect(benchmarkTool, contains('--caliber-run-id'));
    expect(benchmarkTool, contains('blind_rows_'));
    expect(benchmarkTool, contains('_restoreCachedBlindRows'));
    expect(benchmarkTool, contains('_runBaselineConnectivitySmoke'));
    expect(benchmarkTool, contains('blocked_until_block_10_5_code_rereview'));
    expect(benchmarkTool, contains('cached_caliber_run:'));
    expect(benchmarkTool, contains('baseline_connectivity_smoke'));
    final benchmarkWrapper = File(
      '../../../tool/run_gate0_blind_benchmark.sh',
    ).readAsStringSync();
    expect(benchmarkWrapper, contains('_INPUT_USD_PER_MILLION'));
    expect(benchmarkWrapper, contains('_OUTPUT_USD_PER_MILLION'));
  });

  test('Block 10 safety makes baseline-only Caliber calls impossible', () {
    expect(block10CaliberCallsPerRow(baselineOnly: true), 0);
    expect(block10CaliberCallsPerRow(baselineOnly: false), 1);
  });

  test('Block 10 Caliber cache validation requires full verdict payload', () {
    final valid = <String, Object?>{
      'row_schema_version': block10CaliberRowCacheSchemaVersion,
      'answer_id': 'answer-1',
      'question_id': 'question-1',
      'seed_band': 'clearly_mid',
      'caliber_band': 'below_bar',
      'caliber_model_id': block10ProductJudgeModelId,
      'caliber_verdict_text': 'Level read: below_bar.',
      'caliber_highest_leverage_fix': 'Name one concrete failure mode.',
      'caliber_judgment_json': <String, Object?>{'judgment_id': 'judgment-1'},
    };

    expect(
      validateBlock10CachedCaliberRow(
        row: valid,
        expectedAnswerId: 'answer-1',
        expectedQuestionId: 'question-1',
      ),
      isEmpty,
    );

    final oldSchema = Map<String, Object?>.of(valid)
      ..remove('row_schema_version')
      ..remove('caliber_verdict_text');
    expect(
      validateBlock10CachedCaliberRow(
        row: oldSchema,
        expectedAnswerId: 'answer-1',
        expectedQuestionId: 'question-1',
      ),
      containsAll(<String>['row_schema_version', 'caliber_verdict_text']),
    );
  });

  test(
    'Block 10 blind row cache rejects key, model, seed, and clone leaks',
    () {
      final safe = <String, Object?>{
        'row_schema_version': block10BlindRowCacheSchemaVersion,
        'answer_id': 'answer-1',
        'blinded_verdicts': <Object?>[
          <String, Object?>{'label': 'A', 'text': 'Verdict A'},
          <String, Object?>{'label': 'B', 'text': 'Verdict B'},
          <String, Object?>{'label': 'C', 'text': 'Verdict C'},
        ],
      };
      expect(validateBlock10BlindCacheRow(safe), isEmpty);

      final unsafe = Map<String, Object?>.of(safe)
        ..['key_row'] = <String, Object?>{}
        ..['baseline_costs'] = <Object?>[]
        ..['seed_band'] = 'clearly_mid'
        ..['blinded_verdicts'] = <Object?>[
          <String, Object?>{
            'label': 'A',
            'source': 'caliber',
            'model_id': block10ProductJudgeModelId,
            'text': 'Same verdict',
          },
          <String, Object?>{'label': 'A', 'text': 'Same verdict'},
          <String, Object?>{'label': 'C', 'text': 'Same verdict'},
        ];
      expect(
        validateBlock10BlindCacheRow(unsafe),
        containsAll(<String>[
          'key_row_leak',
          'provider_metadata_leak',
          'seed_band_leak',
          'model_or_source_leak',
          'duplicate_or_missing_labels',
          'cloned_or_missing_text',
        ]),
      );
    },
  );

  test('Block 10 provider error redaction masks secrets before storage', () {
    final redacted = redactBlock10ProviderError(
      'Authorization: Bearer or-secret OPENROUTER_API_KEY=sk-test-secret '
      'api_key=sk-another-secret',
    );

    expect(redacted, contains('[REDACTED'));
    expect(redacted, isNot(contains('or-secret')));
    expect(redacted, isNot(contains('sk-test-secret')));
    expect(redacted, isNot(contains('sk-another-secret')));
  });

  test('Block 10 Backend blind benchmark fixtures cover proof matrix', () {
    final fixtureFile = File(
      '../../_benchmark/fixtures/backend_gate0_answers.json',
    );
    final decoded = jsonDecode(fixtureFile.readAsStringSync());

    expect(decoded, isA<List<Object?>>());
    final rows = decoded as List<Object?>;
    final typedRows = rows.cast<Map<String, Object?>>();
    expect(rows, hasLength(greaterThanOrEqualTo(40)));
    expect(
      kBackendDepthPracticeQuestions.map((question) => question.questionId),
      containsAll(typedRows.map((row) => row['question_id'] as String).toSet()),
    );
    expect(
      typedRows.map((row) => row['question_id'] as String).toSet(),
      hasLength(greaterThanOrEqualTo(12)),
    );
    expect(
      typedRows.map((row) => row['seed_band'] as String).toSet(),
      containsAll(<String>[
        'clearly_mid',
        'borderline_senior',
        'clearly_senior',
      ]),
    );
    expect(
      typedRows.map((row) => row['scenario_kind'] as String).toSet(),
      containsAll(<String>[
        'system_design',
        'low_level_design',
        'debugging_code_review',
        'concurrency_productionization',
        'incident_reasoning',
        'project_deep_dive',
        'behavioral_leadership',
        'ai_in_the_loop_verification',
      ]),
    );
    for (final row in typedRows) {
      expect(row['candidate_answer'], isA<String>());
      expect((row['candidate_answer']! as String).trim(), isNotEmpty);
      expect(row['prompt'], isA<String>());
      expect(row['expected_rubric_marks'], isA<Map<String, Object?>>());
      expect(row['rationale_for_seed_band'], isA<String>());
      expect(row['provenance_note'], isA<String>());
    }
  });

  test(
    'SpeechStackInterviewVoiceInput records through speech_stack pipeline',
    () async {
      final input = SpeechStackInterviewVoiceInput(
        pipeline: speech.SpeechRecognitionPipeline(
          capture: _FakeAudioCapture(),
          transcriptionEngine: _FakeTranscriptionEngine(),
        ),
        outputPath: '/tmp/caliber-seed-answer.wav',
      );

      expect(await input.isAvailable(), isTrue);
      expect(
        await input.recordAndTranscribeAnswer(),
        'I scaled a queue-backed worker and measured p95 latency.',
      );
    },
  );
}

Block10ProofValidationResult _validateForBlock10(
  String answer,
  schema.InterviewContentJudgment judgment,
) {
  return validateBlock10CaliberJudgment(
    scenario: corpus.kBackendDepthRubric.scenarioForQuestion(
      kSeedBackendPracticeQuestion.questionId,
    ),
    answer: answer,
    judgment: judgment,
  );
}

final class _GatewayMetadataJudge implements eval.StructuredJudge {
  const _GatewayMetadataJudge({required this.evidenceMetadata});

  final List<Map<String, Object?>> evidenceMetadata;

  @override
  Future<eval.InterviewContentJudgment> judgeInterviewContent(
    eval.StructuredJudgeRequest request,
  ) async {
    final start = request.normalizedAnswer.indexOf('fail closed');
    return eval.InterviewContentJudgment(
      judgmentId: 'judgment:metadata-fixture',
      answerId: request.answerId,
      schemaVersion: request.schemaVersion,
      promptVersion: request.promptVersion,
      corpusBundleVersion: request.corpusBundleVersion,
      routingPolicyVersion: request.routingPolicyVersion,
      modelId: 'gpt-5.4-mini',
      routeHash: request.routeHash,
      band: 'approaching',
      levelRead: 'approaching',
      summary: 'Level read: approaching.',
      strengths: const <String>['Defines some requirements.'],
      gaps: const <String>['failure_modes: failure behavior is thin.'],
      evidenceSpans: <corpus.CorpusEvidenceSpan>[
        corpus.CorpusEvidenceSpan(
          recordId: 'provider-span:0',
          startOffset: start,
          endOffset: start + 'fail closed'.length,
          text: 'fail closed',
          corpusBundleVersion: request.corpusBundleVersion,
          score: 1,
        ),
      ],
      evidenceMetadata: evidenceMetadata,
    );
  }
}

final class _FakeAudioCapture implements speech.AudioCapture {
  @override
  Future<speech.AudioFile> record({
    required String outputPath,
    required Duration maxDuration,
  }) async {
    return speech.AudioFile(path: outputPath, durationMs: 1200);
  }
}

final class _FakeTranscriptionEngine implements speech.TranscriptionEngine {
  @override
  Future<speech.Transcript> transcribe(
    speech.AudioFile file, {
    required speech.SpeechLocale locale,
    required speech.JargonGlossary glossary,
    required speech.PrivacyMode privacyMode,
  }) async {
    return speech.Transcript(
      transcriptId: 'voice-transcript-1',
      segments: const <speech.TranscriptSegment>[
        speech.TranscriptSegment(
          segmentId: 'voice-segment-1',
          startMs: 0,
          endMs: 1200,
          text: 'I scaled a queue-backed worker and measured p95 latency.',
          speakerLabel: 'candidate',
        ),
      ],
      words: const <speech.TranscriptWord>[],
      engineId: 'fake-local-engine',
      engineVersion: 'fake.v1',
      glossaryHits: const <speech.GlossaryHit>[],
      transcriptPolicyVersion: speech.TranscriptPolicy.currentVersion,
      locale: locale.tag,
      recordedAt: DateTime.utc(2026, 6, 4, 12),
      sourceUri: file.path,
      durationMs: 1200,
    );
  }
}

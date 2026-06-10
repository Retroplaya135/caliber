import 'dart:convert';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as corpus;
import 'package:caliber_eval_frontend/caliber_eval_frontend.dart' as eval;
import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'gateway_client_config.dart';
import 'gateway_client_error.dart';
import 'gateway_http_transport.dart';

final class GatewayClient implements eval.StructuredJudge {
  GatewayClient({required this.config, GatewayPostJson? postJson})
    : _postJson = postJson ?? postGatewayJson;

  final GatewayClientConfig config;
  final GatewayPostJson _postJson;

  @override
  Future<eval.InterviewContentJudgment> judgeInterviewContent(
    eval.StructuredJudgeRequest request,
  ) async {
    final envelope =
        eval.GatewayJudgeRequestEnvelope.fromStructuredJudgeRequest(
          request,
          role: config.role,
          userContext: <String, Object?>{
            'answer_id': request.answerId,
            'question_id': request.questionId,
          },
        );
    final response = await _postJson(config, envelope.toJson());
    final canonicalPayload = _canonicalPayload(response.body);
    final schemaJudgment = _schemaJudgmentFrom(canonicalPayload);
    return _toEvalJudgment(schemaJudgment, request, canonicalPayload);
  }

  Map<String, Object?> _canonicalPayload(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('gateway response must be a JSON object');
      }
      final canonical = decoded['canonical_json'];
      if (canonical is String) {
        final nested = jsonDecode(canonical);
        if (nested is Map<String, Object?>) {
          return nested;
        }
        throw const FormatException('canonical_json must decode to an object');
      }
      return decoded;
    } on Object catch (error) {
      throw GatewayDecodeException(
        'AI Gateway response was not valid judgment JSON',
        body: body,
        cause: error,
      );
    }
  }

  schema.InterviewContentJudgment _schemaJudgmentFrom(
    Map<String, Object?> payload,
  ) {
    try {
      return schema.InterviewContentJudgment.fromJson(payload);
    } on Object catch (error) {
      throw GatewayDecodeException(
        'AI Gateway response did not match Schema Core InterviewContentJudgment',
        body: jsonEncode(payload),
        cause: error,
      );
    }
  }

  eval.InterviewContentJudgment _toEvalJudgment(
    schema.InterviewContentJudgment judgment,
    eval.StructuredJudgeRequest request,
    Map<String, Object?> canonicalPayload,
  ) {
    final criterionMetadata = _criterionMetadataFrom(canonicalPayload);
    return eval.InterviewContentJudgment(
      judgmentId: judgment.judgmentId,
      answerId: judgment.answerTranscriptId,
      schemaVersion: judgment.schemaVersion,
      promptVersion: judgment.promptVersion,
      corpusBundleVersion: request.corpusBundleVersion,
      routingPolicyVersion: request.routingPolicyVersion,
      modelId: judgment.modelId,
      routeHash: request.routeHash,
      band: judgment.levelBand,
      levelRead: judgment.levelBand,
      summary: _summaryFrom(judgment),
      strengths: judgment.strengths.isEmpty
          ? <String>['No strengths returned by gateway.']
          : judgment.strengths,
      gaps: judgment.risks.isEmpty
          ? <String>['No risks returned by gateway.']
          : judgment.risks,
      recommendedActions: judgment.recommendedActions,
      evidenceSpans: <corpus.CorpusEvidenceSpan>[
        for (final span in judgment.evidenceSpans)
          corpus.CorpusEvidenceSpan(
            recordId: span.sourceId,
            startOffset: span.startOffset,
            endOffset: span.endOffset,
            text: span.quote ?? span.sourceId,
            corpusBundleVersion: request.corpusBundleVersion,
            score: 1,
          ),
      ],
      evidenceMetadata: <Map<String, Object?>>[
        for (var index = 0; index < judgment.evidenceSpans.length; index += 1)
          if (index < criterionMetadata.length)
            criterionMetadata[index]
          else
            judgment.evidenceSpans[index].metadata,
      ],
    );
  }

  static String _summaryFrom(schema.InterviewContentJudgment judgment) {
    final firstRisk = judgment.risks.isEmpty ? null : judgment.risks.first;
    if (firstRisk == null || firstRisk.trim().isEmpty) {
      return 'Level read: ${judgment.levelBand}.';
    }
    return 'Level read: ${judgment.levelBand}. $firstRisk';
  }

  static List<Map<String, Object?>> _criterionMetadataFrom(
    Map<String, Object?> canonicalPayload,
  ) {
    final rawMarks = canonicalPayload['criterion_marks'];
    if (rawMarks is! List<Object?>) {
      return const <Map<String, Object?>>[];
    }
    final providerSuggestedBand = canonicalPayload['provider_suggested_band'];
    final deterministicLevelBand =
        canonicalPayload['deterministic_level_band'] ??
        canonicalPayload['level_band'];
    return <Map<String, Object?>>[
      for (final item in rawMarks)
        if (item is Map<String, Object?>)
          <String, Object?>{
            'criterion_id': item['criterion_id'],
            'criterion_label': item['criterion_label'],
            'criterion_status': item['status'],
            'provider_suggested_band': providerSuggestedBand,
            'deterministic_level_band': deterministicLevelBand,
            'exact_quote': item['exact_quote'],
            'quote_start': item['quote_start'],
            'quote_end': item['quote_end'],
            'finding': item['finding'],
            'down_level_reason': item['down_level_reason'],
            'minimum_fix': item['minimum_fix'],
          },
    ];
  }
}

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as corpus;
import 'package:caliber_eval_frontend/caliber_eval_frontend.dart' as eval;
import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'calibration_policy.dart';

final class GatewayStructuredJudgeAdapter implements schema.StructuredJudge {
  GatewayStructuredJudgeAdapter({
    required this.gatewayClient,
    corpus.BackendCalibrationCorpus? calibrationCorpus,
    this.clock,
  }) : _calibrationCorpus =
           calibrationCorpus ?? corpus.BackendCalibrationCorpus();

  final eval.StructuredJudge gatewayClient;
  final corpus.BackendCalibrationCorpus _calibrationCorpus;
  final DateTime Function()? clock;

  @override
  Future<schema.InterviewContentJudgment> judgeInterviewContent({
    required schema.ProfileIdentity profile,
    required schema.TargetRoleCompany target,
    required schema.Transcript transcript,
    required String questionId,
    required String rubricVersion,
    required String promptVersion,
  }) async {
    final grounding = _calibrationCorpus.groundingForQuestion(
      questionId: questionId,
      answer: _transcriptText(transcript),
      roleId: target.roleId,
      domain: target.domain,
      levelBand: target.levelBand,
      companyArchetype: target.companyArchetype,
    );
    final scenario = _calibrationCorpus.scenarioForQuestion(questionId);
    final request = eval.StructuredJudgeRequest(
      answerId: transcript.transcriptId,
      questionId: questionId,
      normalizedAnswer: _transcriptText(transcript),
      schemaVersion: schema.kInterviewContentJudgmentSchemaVersion,
      rubricVersion: rubricVersion,
      promptVersion: promptVersion,
      corpusBundleVersion: grounding.corpusBundleVersion,
      routingPolicyVersion: kCalibrationRoutingPolicyVersion,
      routeHash: grounding.routeHash,
      fixedCorpusSubset: grounding.records,
    );
    final judgment = await gatewayClient.judgeInterviewContent(request);
    final policy = CalibrationPolicyTuple(
      corpusBundleVersion: grounding.corpusBundleVersion,
      rubricVersion: rubricVersion,
      promptVersion: promptVersion,
      modelPin: judgment.modelId,
      schemaVersion: schema.kInterviewContentJudgmentSchemaVersion,
      routingPolicyVersion: kCalibrationRoutingPolicyVersion,
    );
    final evidenceMetadata = <Map<String, Object?>>[
      for (var index = 0; index < judgment.evidenceSpans.length; index += 1)
        _evidenceMetadataFrom(judgment, index, scenario),
    ];
    return schema.InterviewContentJudgment(
      judgmentId: judgment.judgmentId,
      profileId: profile.profileId,
      target: target,
      questionId: questionId,
      answerTranscriptId: transcript.transcriptId,
      rubricVersion: rubricVersion,
      promptVersion: promptVersion,
      modelId: judgment.modelId,
      levelBand: judgment.levelRead,
      strengths: judgment.strengths,
      risks: judgment.gaps,
      recommendedActions: _oneRecommendedActionFrom(judgment, evidenceMetadata),
      evidenceSpans: <schema.EvidenceSpan>[
        for (var index = 0; index < judgment.evidenceSpans.length; index += 1)
          schema.EvidenceSpan(
            sourceId: transcript.transcriptId,
            sourceType: 'answer_transcript',
            startOffset: _answerOffset(judgment.evidenceSpans[index]),
            endOffset: _answerEndOffset(
              judgment.evidenceSpans[index],
              _transcriptText(transcript),
            ),
            quote: judgment.evidenceSpans[index].text,
            metadata: <String, Object?>{
              ...policyTupleMetadata(policy),
              ...evidenceMetadata[index],
            },
          ),
      ],
      createdAt: clock?.call() ?? DateTime.now().toUtc(),
    );
  }

  @override
  Future<schema.ResumeBullet> rewriteResumeBullet({
    required schema.ResumeDocument document,
    required schema.TargetRoleCompany target,
    required schema.EvidenceAtom sourceEvidence,
    required String rewritePolicyVersion,
    required String promptVersion,
  }) {
    throw UnsupportedError(
      'Gateway interview adapter only supports interviews.',
    );
  }

  @override
  Future<schema.ATSReportV2> analyzeAts({
    required schema.ResumeDocument document,
    required schema.TargetRoleCompany target,
    required String atsTestMatrixVersion,
    required String keywordMatchVersion,
  }) {
    throw UnsupportedError(
      'Gateway interview adapter only supports interviews.',
    );
  }
}

String _transcriptText(schema.Transcript transcript) {
  return transcript.segments.map((segment) => segment.text.trim()).join(' ');
}

List<String> _oneRecommendedActionFrom(
  eval.InterviewContentJudgment judgment,
  List<Map<String, Object?>> evidenceMetadata,
) {
  final direct = judgment.recommendedActions
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
  if (direct.isNotEmpty) return <String>[direct.first];

  for (var index = 0; index < evidenceMetadata.length; index += 1) {
    final metadata = evidenceMetadata[index];
    final status = _metadataString(metadata, 'criterion_status');
    if (status != 'partial' && status != 'missing') continue;
    final fix = metadata['minimum_fix'];
    if (fix is String && fix.trim().isNotEmpty) {
      final criterion =
          (metadata['criterion_label'] as String?) ??
          (metadata['criterion_id'] as String?) ??
          'rubric criterion';
      final quote = index < judgment.evidenceSpans.length
          ? judgment.evidenceSpans[index].text
          : '';
      return <String>[
        'Fix $criterion: ${fix.trim()} Evidence: "${_shortQuote(quote)}"',
      ];
    }
  }
  return const <String>[];
}

Map<String, Object?> _evidenceMetadataFrom(
  eval.InterviewContentJudgment judgment,
  int index,
  corpus.BackendRubricScenario scenario,
) {
  final raw = index < judgment.evidenceMetadata.length
      ? Map<String, Object?>.of(judgment.evidenceMetadata[index])
      : <String, Object?>{};
  raw.putIfAbsent(
    'gateway_record_id',
    () => judgment.evidenceSpans[index].recordId,
  );
  final dimension = _dimensionForCriterionId(
    scenario,
    _metadataString(raw, 'criterion_id'),
  );
  if (dimension != null) {
    raw['criterion_id'] = dimension.dimensionId;
    raw.putIfAbsent('criterion_label', () => dimension.label);
    raw.putIfAbsent('finding', () => dimension.judgmentFocus);
    raw.putIfAbsent(
      'down_level_reason',
      () => dimension.downLevelSignals.first,
    );
    raw.putIfAbsent('minimum_fix', () => dimension.minimumFix);
  }
  raw.putIfAbsent('dimension', () => 'content');
  raw.putIfAbsent('level_signal', () => judgment.levelRead);
  return raw;
}

corpus.BackendRubricDimension? _dimensionForCriterionId(
  corpus.BackendRubricScenario scenario,
  String criterionId,
) {
  if (criterionId.isEmpty) return null;
  for (final dimension in scenario.dimensions) {
    if (dimension.dimensionId == criterionId) {
      return dimension;
    }
  }
  return null;
}

int _answerOffset(corpus.CorpusEvidenceSpan span) {
  return span.startOffset < 0 ? 0 : span.startOffset;
}

int _answerEndOffset(corpus.CorpusEvidenceSpan span, String answer) {
  final start = _answerOffset(span);
  final proposed = span.endOffset <= start
      ? start + span.text.length
      : span.endOffset;
  return proposed.clamp(start + 1, answer.length).toInt();
}

String _shortQuote(String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= 96) return normalized;
  return '${normalized.substring(0, 93)}...';
}

String _metadataString(Map<String, Object?> metadata, String key) {
  final value = metadata[key];
  return value is String ? value.trim() : '';
}

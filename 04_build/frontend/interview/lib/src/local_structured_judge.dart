import 'package:caliber_eval_backend/caliber_eval_backend.dart' as backend;
import 'package:caliber_eval_frontend/caliber_eval_frontend.dart' as eval;
import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'calibration_policy.dart';

final class LocalDeterministicStructuredJudge
    implements schema.StructuredJudge {
  LocalDeterministicStructuredJudge({
    backend.BackendInterviewRubric? rubric,
    this.engine = const eval.DeterministicRubricVerdictEngine(),
  }) : rubric = rubric ?? backend.kBackendDepthRubric;

  static final DateTime deterministicCreatedAt = DateTime.utc(2026, 6, 4);

  final backend.BackendInterviewRubric rubric;
  final eval.DeterministicRubricVerdictEngine engine;

  @override
  Future<schema.InterviewContentJudgment> judgeInterviewContent({
    required schema.ProfileIdentity profile,
    required schema.TargetRoleCompany target,
    required schema.Transcript transcript,
    required String questionId,
    required String rubricVersion,
    required String promptVersion,
  }) async {
    final answer = transcript.segments.map((segment) => segment.text).join(' ');
    final scenario = rubric.scenarioForQuestion(questionId);
    final policy = CalibrationPolicyTuple.forBackend(
      modelPin: 'local-deterministic-rubric-verdict.v0.1',
      schemaVersion: schema.kInterviewContentJudgmentSchemaVersion,
    );
    final verdict = engine.evaluate(
      scenario: _toEvalScenario(scenario),
      answer: answer,
      rubricVersion: rubricVersion,
      promptVersion: promptVersion,
    );

    return schema.InterviewContentJudgment(
      judgmentId: 'local_judgment_${transcript.transcriptId}',
      profileId: profile.profileId,
      target: target,
      questionId: questionId,
      answerTranscriptId: transcript.transcriptId,
      rubricVersion: rubricVersion,
      promptVersion: promptVersion,
      modelId: 'local-deterministic-rubric-verdict.v0.1',
      levelBand: verdict.levelRead,
      strengths: <String>[
        for (final item in verdict.contentStrengths) 'Content: $item',
        for (final item in verdict.deliveryStrengths) 'Delivery: $item',
      ],
      risks: <String>[
        for (final item in verdict.contentRisks) 'Content: $item',
        for (final item in verdict.deliveryRisks) 'Delivery: $item',
      ],
      recommendedActions: verdict.recommendedActions,
      evidenceSpans: <schema.EvidenceSpan>[
        for (final finding in verdict.findings)
          schema.EvidenceSpan(
            sourceId: transcript.transcriptId,
            sourceType: 'answer_transcript',
            startOffset: finding.startOffset,
            endOffset: finding.endOffset,
            quote: finding.quote,
            metadata: <String, Object?>{
              ...policyTupleMetadata(policy),
              'rubric_version': rubricVersion,
              'prompt_version': promptVersion,
              'criterion_id': finding.criterionId,
              'criterion_label': finding.label,
              'level_signal': finding.levelSignal.name,
              'finding': finding.finding,
              'down_level_reason': finding.downLevelReason,
              'minimum_fix': finding.minimumFix,
              'matched_signals': finding.matchedSignals,
            },
          ),
      ],
      createdAt: deterministicCreatedAt,
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
    throw UnsupportedError('Local interview judge only supports interviews.');
  }

  @override
  Future<schema.ATSReportV2> analyzeAts({
    required schema.ResumeDocument document,
    required schema.TargetRoleCompany target,
    required String atsTestMatrixVersion,
    required String keywordMatchVersion,
  }) {
    throw UnsupportedError('Local interview judge only supports interviews.');
  }
}

eval.RubricScenario _toEvalScenario(backend.BackendRubricScenario scenario) {
  return eval.RubricScenario(
    questionId: scenario.questionId,
    title: scenario.title,
    prompt: scenario.prompt,
    criteria: <eval.RubricCriterion>[
      for (final dimension in scenario.dimensions)
        eval.RubricCriterion(
          criterionId: dimension.dimensionId,
          label: dimension.label,
          judgmentFocus: dimension.judgmentFocus,
          l5Anchor: dimension.l5Anchor,
          l6Anchor: dimension.l6Anchor,
          downLevelSignals: dimension.downLevelSignals,
          expectedSignals: dimension.expectedSignals,
          advancedSignals: dimension.advancedSignals,
          minimumFix: dimension.minimumFix,
        ),
    ],
  );
}

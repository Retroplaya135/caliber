import 'package:caliber_interview/interview.dart';
import 'package:caliber_prep_brief/prep_brief.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;

final class JobPacketViewModel {
  const JobPacketViewModel({
    required this.packetId,
    required this.sourceHash,
    required this.normalizedTitle,
    required this.currentLevel,
    required this.targetLevel,
    required this.timeline,
    required this.hasResumeEvidence,
    required this.corpusBundleVersion,
    required this.rubricVersion,
  });

  factory JobPacketViewModel.fromBrief({
    required PrepBrief brief,
    required String currentLevel,
    required String timeline,
    required bool hasResumeEvidence,
  }) {
    return JobPacketViewModel(
      packetId: 'packet:${brief.sourceHash}',
      sourceHash: brief.sourceHash,
      normalizedTitle: brief.jdSignals.normalizedTitle,
      currentLevel: currentLevel.trim().isEmpty ? 'Mid-level' : currentLevel,
      targetLevel: brief.targetLevel,
      timeline: timeline.trim().isEmpty ? '90-day pass' : timeline,
      hasResumeEvidence: hasResumeEvidence,
      corpusBundleVersion: brief.corpusBundleVersion,
      rubricVersion: brief.rubricVersion,
    );
  }

  final String packetId;
  final String sourceHash;
  final String normalizedTitle;
  final String currentLevel;
  final String targetLevel;
  final String timeline;
  final bool hasResumeEvidence;
  final String corpusBundleVersion;
  final String rubricVersion;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'packet_id': packetId,
      'source_hash': sourceHash,
      'normalized_title': normalizedTitle,
      'current_level': currentLevel,
      'target_level': targetLevel,
      'timeline': timeline,
      'has_resume_evidence': hasResumeEvidence,
      'corpus_bundle_version': corpusBundleVersion,
      'rubric_version': rubricVersion,
    };
  }
}

final class PrepBriefViewModel {
  const PrepBriefViewModel({
    required this.sourceHash,
    required this.normalizedTitle,
    required this.targetLevel,
    required this.corpusBundleVersion,
    required this.rubricVersion,
    required this.roundMix,
    required this.likelyQuestions,
    required this.topQuestionId,
    required this.topQuestionTitle,
    required this.topQuestionPrompt,
    required this.riskNotes,
    required this.ctaLabel,
  });

  factory PrepBriefViewModel.fromBrief(PrepBrief brief) {
    final topQuestion = brief.likelyQuestions.first;
    return PrepBriefViewModel(
      sourceHash: brief.sourceHash,
      normalizedTitle: brief.jdSignals.normalizedTitle,
      targetLevel: brief.targetLevel,
      corpusBundleVersion: brief.corpusBundleVersion,
      rubricVersion: brief.rubricVersion,
      roundMix: <String>[
        for (final item in brief.roundMixForecast)
          '${item.label}: ${item.rationale}',
      ],
      likelyQuestions: <String>[
        for (final item in brief.likelyQuestions)
          '${item.rank}. ${item.title}: ${item.rationale}',
      ],
      topQuestionId: topQuestion.questionId,
      topQuestionTitle: topQuestion.title,
      topQuestionPrompt: topQuestion.prompt,
      riskNotes: <String>[
        for (final risk in brief.downLevelRiskNotes)
          '${risk.title}: ${risk.note}',
      ],
      ctaLabel: brief.ctaLabel,
    );
  }

  final String sourceHash;
  final String normalizedTitle;
  final String targetLevel;
  final String corpusBundleVersion;
  final String rubricVersion;
  final List<String> roundMix;
  final List<String> likelyQuestions;
  final String topQuestionId;
  final String topQuestionTitle;
  final String topQuestionPrompt;
  final List<String> riskNotes;
  final String ctaLabel;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'source_hash': sourceHash,
      'normalized_title': normalizedTitle,
      'target_level': targetLevel,
      'corpus_bundle_version': corpusBundleVersion,
      'rubric_version': rubricVersion,
      'round_mix': roundMix,
      'likely_questions': likelyQuestions,
      'top_question_id': topQuestionId,
      'top_question_title': topQuestionTitle,
      'top_question_prompt': topQuestionPrompt,
      'risk_notes': riskNotes,
      'cta_label': ctaLabel,
    };
  }
}

final class PracticeRoomViewModel {
  const PracticeRoomViewModel({
    required this.questionId,
    required this.title,
    required this.prompt,
    required this.domain,
    required this.levelBand,
    required this.rubricVersion,
    required this.promptVersion,
    required this.seniorBarCriteria,
    required this.glossary,
  });

  factory PracticeRoomViewModel.fromQuestion({
    required InterviewPracticeQuestion question,
    PrepBrief? brief,
  }) {
    final scaffold = brief?.rubricScaffolds
        .where((item) => item.questionId == question.questionId)
        .firstOrNull;
    return PracticeRoomViewModel(
      questionId: question.questionId,
      title: question.title,
      prompt: question.prompt,
      domain: question.target.domain,
      levelBand: question.target.levelBand,
      rubricVersion: question.rubricVersion,
      promptVersion: question.promptVersion,
      seniorBarCriteria: <String>[
        if (scaffold != null)
          for (final criterion in scaffold.criteria)
            '${criterion.label}: ${criterion.seniorBar}'
        else
          question.seedRubric,
      ],
      glossary: question.glossary,
    );
  }

  final String questionId;
  final String title;
  final String prompt;
  final String domain;
  final String levelBand;
  final String rubricVersion;
  final String promptVersion;
  final List<String> seniorBarCriteria;
  final List<String> glossary;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'title': title,
      'prompt': prompt,
      'domain': domain,
      'level_band': levelBand,
      'rubric_version': rubricVersion,
      'prompt_version': promptVersion,
      'senior_bar_criteria': seniorBarCriteria,
      'glossary': glossary,
    };
  }
}

final class VerdictArtifactViewModel {
  const VerdictArtifactViewModel({
    required this.judgmentId,
    required this.questionId,
    required this.levelBand,
    required this.policy,
    required this.contentStrengths,
    required this.contentRisks,
    required this.deliveryStrengths,
    required this.deliveryRisks,
    required this.evidenceQuotes,
    required this.highestLeverageFix,
    required this.comparison,
  });

  factory VerdictArtifactViewModel.fromJudgment({
    required schema.InterviewContentJudgment judgment,
    InterviewRoundComparison? comparison,
  }) {
    final feedback = InterviewFeedbackViewModel.fromJudgment(judgment);
    return VerdictArtifactViewModel(
      judgmentId: judgment.judgmentId,
      questionId: judgment.questionId,
      levelBand: feedback.levelRead,
      policy: feedback.policy,
      contentStrengths: feedback.contentStrengths,
      contentRisks: feedback.contentRisks,
      deliveryStrengths: feedback.deliveryStrengths,
      deliveryRisks: feedback.deliveryRisks,
      evidenceQuotes: feedback.quotes,
      highestLeverageFix: feedback.recommendedActions.isEmpty
          ? 'Answer again with one concrete backend decision tied to the rubric.'
          : feedback.recommendedActions.first,
      comparison: comparison?.summaryBullets ?? const <String>[],
    );
  }

  final String judgmentId;
  final String questionId;
  final String levelBand;
  final CalibrationPolicyTuple policy;
  final List<String> contentStrengths;
  final List<String> contentRisks;
  final List<String> deliveryStrengths;
  final List<String> deliveryRisks;
  final List<String> evidenceQuotes;
  final String highestLeverageFix;
  final List<String> comparison;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'judgment_id': judgmentId,
      'question_id': questionId,
      'level_band': levelBand,
      'policy': policy.toJson(),
      'content_strengths': contentStrengths,
      'content_risks': contentRisks,
      'delivery_strengths': deliveryStrengths,
      'delivery_risks': deliveryRisks,
      'evidence_quotes': evidenceQuotes,
      'highest_leverage_fix': highestLeverageFix,
      'comparison': comparison,
    };
  }
}

final class EvidenceInspectViewModel {
  const EvidenceInspectViewModel({
    required this.judgmentId,
    required this.rubricVersion,
    required this.items,
  });

  factory EvidenceInspectViewModel.fromJudgment(
    schema.InterviewContentJudgment judgment,
  ) {
    final feedback = InterviewFeedbackViewModel.fromJudgment(judgment);
    return EvidenceInspectViewModel(
      judgmentId: judgment.judgmentId,
      rubricVersion: feedback.rubricVersion,
      items: <EvidenceInspectItemViewModel>[
        for (final mapping in feedback.rubricMappings)
          EvidenceInspectItemViewModel(
            criterionId: mapping.criterionId,
            criterionLabel: mapping.criterionLabel,
            state: mapping.levelSignal,
            finding: mapping.finding,
            quote: mapping.quote,
            downLevelReason: mapping.downLevelReason,
            minimumFix: mapping.minimumFix,
          ),
      ],
    );
  }

  final String judgmentId;
  final String rubricVersion;
  final List<EvidenceInspectItemViewModel> items;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'judgment_id': judgmentId,
      'rubric_version': rubricVersion,
      'items': <Object?>[for (final item in items) item.toJson()],
    };
  }
}

final class EvidenceInspectItemViewModel {
  const EvidenceInspectItemViewModel({
    required this.criterionId,
    required this.criterionLabel,
    required this.state,
    required this.finding,
    required this.quote,
    required this.downLevelReason,
    required this.minimumFix,
  });

  final String criterionId;
  final String criterionLabel;
  final String state;
  final String finding;
  final String quote;
  final String downLevelReason;
  final String minimumFix;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'criterion_id': criterionId,
      'criterion_label': criterionLabel,
      'state': state,
      'finding': finding,
      'quote': quote,
      'down_level_reason': downLevelReason,
      'minimum_fix': minimumFix,
    };
  }
}

final class RetestPlanViewModel {
  const RetestPlanViewModel({
    required this.questionId,
    required this.title,
    required this.reason,
    required this.highestLeverageFix,
    required this.policy,
  });

  factory RetestPlanViewModel.fromVerdict({
    required InterviewPracticeQuestion question,
    required VerdictArtifactViewModel verdict,
  }) {
    return RetestPlanViewModel(
      questionId: question.questionId,
      title: question.title,
      reason:
          'Retest the same archetype so the next attempt isolates whether the fix changed the level read.',
      highestLeverageFix: verdict.highestLeverageFix,
      policy: verdict.policy,
    );
  }

  final String questionId;
  final String title;
  final String reason;
  final String highestLeverageFix;
  final CalibrationPolicyTuple policy;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'title': title,
      'reason': reason,
      'highest_leverage_fix': highestLeverageFix,
      'policy': policy.toJson(),
    };
  }
}

final class BackendMapViewModel {
  const BackendMapViewModel({
    required this.schemaVersion,
    required this.profileId,
    required this.completionLabel,
    required this.nextRetest,
    required this.prepSprint,
    required this.breakthroughs,
    required this.cells,
  });

  factory BackendMapViewModel.fromEngagementState(
    BackendEngagementStateViewModel state,
  ) {
    return BackendMapViewModel(
      schemaVersion: state.schemaVersion,
      profileId: state.profileId,
      completionLabel: state.masteryMap.completionLabel,
      nextRetest: state.nextRetest.toJson(),
      prepSprint: state.prepSprint.toJson(),
      breakthroughs: <Map<String, Object?>>[
        for (final item in state.breakthroughs) item.toJson(),
      ],
      cells: <Map<String, Object?>>[
        for (final cell in state.masteryMap.cells) cell.toJson(),
      ],
    );
  }

  final String schemaVersion;
  final String profileId;
  final String completionLabel;
  final Map<String, Object?> nextRetest;
  final Map<String, Object?> prepSprint;
  final List<Map<String, Object?>> breakthroughs;
  final List<Map<String, Object?>> cells;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schema_version': schemaVersion,
      'profile_id': profileId,
      'completion_label': completionLabel,
      'next_retest': nextRetest,
      'prep_sprint': prepSprint,
      'breakthroughs': breakthroughs,
      'cells': cells,
    };
  }
}

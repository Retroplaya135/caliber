import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'calibration_policy.dart';

final class InterviewFeedbackViewModel {
  InterviewFeedbackViewModel.fromJudgment(schema.InterviewContentJudgment item)
    : contentStrengths = _withoutPrefix(item.strengths, 'Content:'),
      deliveryStrengths = _withoutPrefix(item.strengths, 'Delivery:'),
      contentRisks = _withoutPrefix(item.risks, 'Content:'),
      deliveryRisks = _withoutPrefix(item.risks, 'Delivery:'),
      recommendedActions = item.recommendedActions,
      rubricVersion = item.rubricVersion,
      policy = CalibrationPolicyTuple.fromJudgment(item),
      levelRead = item.levelBand,
      rubricMappings = <InterviewRubricMappingViewModel>[
        for (final span in item.evidenceSpans)
          InterviewRubricMappingViewModel.fromEvidence(span),
      ],
      quotes = <String>[
        for (final span in item.evidenceSpans)
          if (span.quote case final quote? when quote.trim().isNotEmpty)
            quote.trim(),
      ];

  final List<String> contentStrengths;
  final List<String> deliveryStrengths;
  final List<String> contentRisks;
  final List<String> deliveryRisks;
  final List<String> recommendedActions;
  final String rubricVersion;
  final CalibrationPolicyTuple policy;
  final String levelRead;
  final List<InterviewRubricMappingViewModel> rubricMappings;
  final List<String> quotes;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'level_read': levelRead,
      'rubric_version': rubricVersion,
      'policy': policy.toJson(),
      'content_strengths': contentStrengths,
      'delivery_strengths': deliveryStrengths,
      'content_risks': contentRisks,
      'delivery_risks': deliveryRisks,
      'recommended_actions': recommendedActions,
      'rubric_mappings': <Object?>[
        for (final mapping in rubricMappings) mapping.toJson(),
      ],
      'quotes': quotes,
    };
  }
}

final class InterviewRubricMappingViewModel {
  InterviewRubricMappingViewModel.fromEvidence(schema.EvidenceSpan span)
    : criterionId = (span.metadata['criterion_id'] as String?) ?? 'criterion',
      criterionLabel =
          (span.metadata['criterion_label'] as String?) ?? 'Rubric criterion',
      levelSignal = (span.metadata['level_signal'] as String?) ?? 'mapped',
      finding = (span.metadata['finding'] as String?) ?? 'Mapped to rubric.',
      downLevelReason =
          (span.metadata['down_level_reason'] as String?) ??
          'No down-level reason recorded.',
      minimumFix =
          (span.metadata['minimum_fix'] as String?) ??
          'Answer again with a more concrete backend decision.',
      quote = span.quote?.trim() ?? '';

  final String criterionId;
  final String criterionLabel;
  final String levelSignal;
  final String finding;
  final String downLevelReason;
  final String minimumFix;
  final String quote;

  String get summary {
    return '$criterionLabel ($levelSignal): $finding';
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'criterion_id': criterionId,
      'criterion_label': criterionLabel,
      'level_signal': levelSignal,
      'finding': finding,
      'down_level_reason': downLevelReason,
      'minimum_fix': minimumFix,
      'quote': quote,
    };
  }
}

List<String> _withoutPrefix(List<String> values, String prefix) {
  return <String>[
    for (final value in values)
      if (value.startsWith(prefix)) value.substring(prefix.length).trim(),
  ];
}

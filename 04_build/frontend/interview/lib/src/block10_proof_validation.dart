import 'package:caliber_eval_backend/caliber_eval_backend.dart' as corpus;
import 'package:caliber_shared/caliber_shared.dart' as schema;

const block10ProofStatuses = <String>{'met', 'partial', 'missing'};

final class Block10ProofValidationResult {
  const Block10ProofValidationResult({
    required this.failures,
    required this.highestLeverageFix,
  });

  final List<String> failures;
  final String? highestLeverageFix;

  bool get isValid => failures.isEmpty;
}

Block10ProofValidationResult validateBlock10CaliberJudgment({
  required corpus.BackendRubricScenario scenario,
  required String answer,
  required schema.InterviewContentJudgment judgment,
}) {
  final failures = <String>[];
  final normalizedAnswer = normalizeBlock10Answer(answer);
  final dimensionById = <String, corpus.BackendRubricDimension>{
    for (final dimension in scenario.dimensions)
      dimension.dimensionId: dimension,
  };
  final mappedSpans = <schema.EvidenceSpan>[];
  final partialOrMissingSpans = <schema.EvidenceSpan>[];

  if (judgment.evidenceSpans.isEmpty) {
    failures.add('evidence_spans_empty');
  }

  for (var index = 0; index < judgment.evidenceSpans.length; index += 1) {
    final span = judgment.evidenceSpans[index];
    final quote = span.quote?.trim() ?? '';
    if (quote.isEmpty || !normalizedAnswer.contains(quote)) {
      failures.add('evidence_quote_not_answer_substring:$index');
    }

    final criterionId = _metadataString(span.metadata, 'criterion_id');
    if (criterionId.isEmpty) {
      failures.add('criterion_id_missing_on_evidence:$index');
      continue;
    }
    final dimension = dimensionById[criterionId];
    if (dimension == null) {
      failures.add('criterion_id_unknown_on_evidence:$index:$criterionId');
      continue;
    }

    final label = _metadataString(span.metadata, 'criterion_label');
    if (label.isEmpty) {
      failures.add('criterion_label_missing_on_evidence:$index');
    }

    final status = _metadataString(span.metadata, 'criterion_status');
    if (!block10ProofStatuses.contains(status)) {
      failures.add('criterion_status_invalid_on_evidence:$index:$status');
    }

    if (_metadataString(span.metadata, 'down_level_reason').isEmpty) {
      failures.add('down_level_reason_missing_on_evidence:$index');
    }
    if (_metadataString(span.metadata, 'minimum_fix').isEmpty) {
      failures.add('minimum_fix_missing_on_evidence:$index');
    }

    mappedSpans.add(span);
    if (status == 'partial' || status == 'missing') {
      partialOrMissingSpans.add(span);
    }
  }

  for (var index = 0; index < judgment.risks.length; index += 1) {
    if (!_textMapsToAnyCriterion(judgment.risks[index], mappedSpans)) {
      failures.add('risk_missing_criterion_mapping:$index');
    }
  }

  final specificActions = judgment.recommendedActions
      .map((item) => item.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  if (specificActions.length != 1) {
    failures.add('recommended_action_count_not_one:${specificActions.length}');
  }

  String? highestLeverageFix;
  if (specificActions.isNotEmpty) {
    final action = specificActions.length == 1 ? specificActions.single : null;
    if (action == null) {
      failures.add('specific_recommended_action_missing');
    } else if (isGenericBlock10Fix(action)) {
      failures.add('generic_recommended_action');
    } else {
      highestLeverageFix = action;
      if (!_textMapsToAnyCriterion(action, partialOrMissingSpans)) {
        failures.add('recommended_action_missing_partial_criterion_mapping');
      }
      if (!_textUsesAnyEvidenceQuote(action, partialOrMissingSpans)) {
        failures.add('recommended_action_missing_evidence_quote');
      }
    }
  } else {
    failures.add('specific_recommended_action_missing');
  }

  return Block10ProofValidationResult(
    failures: failures,
    highestLeverageFix: highestLeverageFix,
  );
}

String normalizeBlock10Answer(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool isGenericBlock10Fix(String value) {
  final lower = value.toLowerCase();
  return lower.contains('highest-risk rubric miss') ||
      lower.contains('first uncovered rubric gap') ||
      lower.contains('preserve the strongest content') ||
      lower.contains('tighten one weak spot') ||
      lower.contains('one weak spot') ||
      lower == 'none returned.';
}

bool _textMapsToAnyCriterion(String text, Iterable<schema.EvidenceSpan> spans) {
  final lower = text.toLowerCase();
  for (final span in spans) {
    final criterionId = _metadataString(span.metadata, 'criterion_id');
    final label = _metadataString(span.metadata, 'criterion_label');
    if (criterionId.isNotEmpty && lower.contains(criterionId.toLowerCase())) {
      return true;
    }
    if (label.isNotEmpty && lower.contains(label.toLowerCase())) {
      return true;
    }
  }
  return false;
}

bool _textUsesAnyEvidenceQuote(
  String text,
  Iterable<schema.EvidenceSpan> spans,
) {
  for (final span in spans) {
    final quote = span.quote?.trim();
    if (quote != null && quote.isNotEmpty && text.contains(quote)) {
      return true;
    }
  }
  return false;
}

String _metadataString(Map<String, Object?> metadata, String key) {
  final value = metadata[key];
  return value is String ? value.trim() : '';
}

import 'dart:convert';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as corpus;
import 'package:caliber_shared/caliber_shared.dart' as schema;

String renderBlock10DebugSmokeMarkdown({
  required String runId,
  required String fixtureId,
  required String prompt,
  required String archetypeId,
  required corpus.BackendRubricScenario scenario,
  required schema.InterviewContentJudgment? judgment,
  required List<String> validationFailures,
  required Map<String, Object?> tokenCostLedger,
  String? invalidReason,
}) {
  final buffer = StringBuffer()
    ..writeln('# Caliber Block 10 Debug Smoke')
    ..writeln()
    ..writeln('Run: `$runId`')
    ..writeln('Fixture: `$fixtureId`')
    ..writeln('Prompt archetype: `$archetypeId`')
    ..writeln('Selected archetype: `${scenario.scenarioId}`')
    ..writeln()
    ..writeln('## Prompt')
    ..writeln()
    ..writeln(prompt)
    ..writeln()
    ..writeln('## Validation')
    ..writeln()
    ..writeln(
      'Result: `${validationFailures.isEmpty && invalidReason == null ? 'valid' : 'invalid'}`',
    );
  if (invalidReason != null) {
    buffer.writeln('Reason: `$invalidReason`');
  }
  if (validationFailures.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Failures:')
      ..writeln(_bullets(validationFailures));
  }
  if (judgment == null) {
    buffer
      ..writeln()
      ..writeln('## Token And Cost Ledger')
      ..writeln()
      ..writeln('```json')
      ..writeln(const JsonEncoder.withIndent('  ').convert(tokenCostLedger))
      ..writeln('```');
    return _stripTrailingWhitespace(buffer.toString());
  }

  buffer
    ..writeln()
    ..writeln('## Verdict')
    ..writeln()
    ..writeln('Level band: `${judgment.levelBand}`')
    ..writeln()
    ..writeln('Strengths:')
    ..writeln(_bullets(judgment.strengths))
    ..writeln()
    ..writeln('Risks:')
    ..writeln(_bullets(judgment.risks))
    ..writeln()
    ..writeln('Highest-leverage fix:')
    ..writeln(_bullets(judgment.recommendedActions))
    ..writeln()
    ..writeln('## Criterion Marks')
    ..writeln()
    ..writeln('| Criterion | Status | Exact quote | Finding | Minimum fix |')
    ..writeln('|---|---|---|---|---|');
  for (final span in judgment.evidenceSpans) {
    final metadata = span.metadata;
    buffer.writeln(
      '| ${_cell(metadata['criterion_id'])} | ${_cell(metadata['criterion_status'])} | "${_cell(span.quote)}" | ${_cell(metadata['finding'])} | ${_cell(metadata['minimum_fix'])} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('## Evidence Quotes')
    ..writeln();
  for (final span in judgment.evidenceSpans) {
    buffer.writeln(
      '- `${span.metadata['criterion_id'] ?? 'criterion'}`: "${span.quote ?? ''}"',
    );
  }
  buffer
    ..writeln()
    ..writeln('## Token And Cost Ledger')
    ..writeln()
    ..writeln('```json')
    ..writeln(const JsonEncoder.withIndent('  ').convert(tokenCostLedger))
    ..writeln('```');
  return _stripTrailingWhitespace(buffer.toString());
}

String _bullets(Iterable<String> items) {
  final filtered = items
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty);
  if (filtered.isEmpty) return '- None.';
  return filtered.map((item) => '- $item').join('\n');
}

String _cell(Object? value) {
  return (value?.toString() ?? '')
      .replaceAll('|', r'\|')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _stripTrailingWhitespace(String value) {
  final lines = const LineSplitter()
      .convert(value)
      .map((line) => line.trimRight())
      .toList();
  return '${lines.join('\n')}\n';
}

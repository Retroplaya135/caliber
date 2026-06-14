const block10CaliberRowCacheSchemaVersion = 'caliber_block10_caliber_row.v0.2';
const block10BlindRowCacheSchemaVersion = 'caliber_block10_blind_row.v0.2';
const block10ProductJudgeModelId = 'gpt-5.4-mini';

int block10CaliberCallsPerRow({required bool baselineOnly}) =>
    baselineOnly ? 0 : 1;

List<String> validateBlock10CachedCaliberRow({
  required Map<String, Object?> row,
  required String expectedAnswerId,
  required String expectedQuestionId,
}) {
  final failures = <String>[];
  void requireString(String key) {
    final value = row[key];
    if (value is! String || value.trim().isEmpty) failures.add(key);
  }

  if (row['row_schema_version'] != block10CaliberRowCacheSchemaVersion) {
    failures.add('row_schema_version');
  }
  for (final key in <String>[
    'answer_id',
    'question_id',
    'seed_band',
    'caliber_band',
    'caliber_model_id',
    'caliber_verdict_text',
    'caliber_highest_leverage_fix',
  ]) {
    requireString(key);
  }
  if (row['answer_id'] != expectedAnswerId) failures.add('answer_id_match');
  if (row['question_id'] != expectedQuestionId) {
    failures.add('question_id_match');
  }
  if (row['caliber_model_id'] != block10ProductJudgeModelId) {
    failures.add('caliber_model_id_product_pin');
  }
  if (row['caliber_judgment_json'] is! Map<String, Object?>) {
    failures.add('caliber_judgment_json');
  }
  return failures;
}

List<String> validateBlock10BlindCacheRow(Map<String, Object?> row) {
  final failures = <String>[];
  if (row['row_schema_version'] != block10BlindRowCacheSchemaVersion) {
    failures.add('row_schema_version');
  }
  if (row.containsKey('key_row')) failures.add('key_row_leak');
  if (row.containsKey('baseline_costs') || row.containsKey('fallback_rows')) {
    failures.add('provider_metadata_leak');
  }
  if (row.containsKey('seed_band') || row.containsKey('quality_band')) {
    failures.add('seed_band_leak');
  }
  final verdicts = row['blinded_verdicts'];
  if (verdicts is! List<Object?> || verdicts.length != 3) {
    failures.add('blinded_verdicts_count');
    return failures;
  }
  final labels = <String>{};
  final texts = <String>{};
  for (final item in verdicts) {
    if (item is! Map<String, Object?>) {
      failures.add('non_map_verdict');
      continue;
    }
    if (item.containsKey('source') || item.containsKey('model_id')) {
      failures.add('model_or_source_leak');
    }
    final label = item['label'];
    final text = item['text'];
    if (label is! String || label.trim().isEmpty) {
      failures.add('missing_label');
    } else {
      labels.add(label.trim());
    }
    if (text is! String || text.trim().isEmpty) {
      failures.add('missing_text');
    } else {
      texts.add(text.trim());
    }
  }
  if (labels.length != 3) failures.add('duplicate_or_missing_labels');
  if (texts.length != 3) failures.add('cloned_or_missing_text');
  return failures.toSet().toList(growable: false)..sort();
}

String redactBlock10ProviderError(Object error) {
  final text = error
      .toString()
      .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+'), 'Bearer [REDACTED]')
      .replaceAll(RegExp(r'\bsk-[A-Za-z0-9_-]{8,}\b'), 'sk-[REDACTED]')
      .replaceAll(
        RegExp(
          r'\b(openai|openrouter|anthropic)?_?api[_-]?key\s*[:=]\s*\S+',
          caseSensitive: false,
        ),
        '[REDACTED_API_KEY]',
      )
      .replaceAll(
        RegExp(r'\bauthorization\s*[:=]\s*\S+', caseSensitive: false),
        'authorization=[REDACTED]',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (text.length <= 260) return text;
  return '${text.substring(0, 260)}...';
}

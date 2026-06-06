import 'dart:collection';
import 'dart:convert';

import 'corpus_models.dart';

final class CorpusBundle {
  CorpusBundle({
    required this.bundleVersion,
    required this.signature,
    required Iterable<CorpusRecord> records,
  }) : records = UnmodifiableListView<CorpusRecord>(
          records.toList()
            ..sort((left, right) => left.recordId.compareTo(right.recordId)),
        ) {
    if (bundleVersion.trim().isEmpty) {
      throw ArgumentError.value(
          bundleVersion, 'bundleVersion', 'must not be empty');
    }
    final ids = <String>{};
    for (final record in this.records) {
      if (record.corpusBundleVersion != bundleVersion) {
        throw StateError(
          'Record ${record.recordId} belongs to ${record.corpusBundleVersion}, not $bundleVersion.',
        );
      }
      if (!ids.add(record.recordId)) {
        throw StateError('Duplicate corpus record id: ${record.recordId}');
      }
    }
  }

  final String bundleVersion;
  final String signature;
  final UnmodifiableListView<CorpusRecord> records;

  static CorpusBundle fromJson(Map<String, Object?> json) {
    final bundleVersion = json['bundle_version'] as String;
    final records = (json['records'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((record) {
      return CorpusRecord(
        recordId: record['record_id'] as String,
        kind: _kindFromWire(record['kind'] as String),
        title: record['title'] as String,
        body: record['body'] as String,
        corpusBundleVersion: bundleVersion,
        roleId: record['role_id'] as String?,
        domain: record['domain'] as String?,
        levelBand: record['level_band'] as String?,
        companyArchetype: record['company_archetype'] as String?,
        tags: (record['tags'] as List<Object?>? ?? const <Object?>[])
            .cast<String>(),
        metadata: (record['metadata'] as Map<String, Object?>? ??
                const <String, Object?>{})
            .map((key, value) =>
                MapEntry<String, String>(key, value.toString())),
      );
    });
    return CorpusBundle(
      bundleVersion: bundleVersion,
      signature: json['signature'] as String,
      records: records,
    );
  }

  static CorpusBundle fromJsonString(String jsonText) {
    return fromJson(jsonDecode(jsonText) as Map<String, Object?>);
  }

  bool verifySignature() {
    return signature == expectedSignature;
  }

  String get expectedSignature {
    final canonicalRows = records.map((record) {
      return <String>[
        record.recordId,
        record.kind.name,
        record.title,
        record.body,
        record.roleId ?? '',
        record.domain ?? '',
        record.levelBand ?? '',
        record.companyArchetype ?? '',
        record.tags.join(','),
      ].join('|');
    }).join('\n');
    return 'caliber-fnv1a64:${_fnv1a64('$bundleVersion\n$canonicalRows')}';
  }
}

CorpusRecordKind _kindFromWire(String value) {
  return switch (value) {
    'rubric_slice' => CorpusRecordKind.rubricSlice,
    'benchmark_answer' => CorpusRecordKind.benchmarkAnswer,
    'glossary_term' => CorpusRecordKind.glossaryTerm,
    _ => throw ArgumentError.value(value, 'kind', 'unknown corpus record kind'),
  };
}

String _fnv1a64(String input) {
  var hash = BigInt.parse('cbf29ce484222325', radix: 16);
  final prime = BigInt.parse('100000001b3', radix: 16);
  final mask = BigInt.parse('ffffffffffffffff', radix: 16);
  for (final codeUnit in utf8.encode(input)) {
    hash ^= BigInt.from(codeUnit);
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

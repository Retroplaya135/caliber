import 'dart:collection';
import 'dart:convert';

import 'corpus_models.dart';
import 'signed_corpus_bundle.dart';

final class CorpusSqliteBundlePlan {
  const CorpusSqliteBundlePlan();

  static const manifestTableName = 'corpus_bundle_manifest';
  static const recordTableName = 'corpus_record';
  static const tagTableName = 'corpus_record_tag';
  static const ftsTableName = 'corpus_record_fts';

  List<String> get manifestColumns => const <String>[
        'corpus_bundle_version',
        'signature',
        'record_count',
        'created_at_utc',
      ];

  List<String> get recordColumns => const <String>[
        'record_id',
        'corpus_bundle_version',
        'kind',
        'title',
        'body',
        'role_id',
        'domain',
        'level_band',
        'company_archetype',
        'metadata_json',
      ];

  List<String> get tagColumns => const <String>['record_id', 'tag'];

  List<String> get ftsColumns =>
      const <String>['record_id', 'title', 'body', 'tags'];

  List<String> get createStatements => const <String>[
        '''
CREATE TABLE IF NOT EXISTS corpus_bundle_manifest (
  corpus_bundle_version TEXT NOT NULL PRIMARY KEY,
  signature TEXT NOT NULL,
  record_count INTEGER NOT NULL,
  created_at_utc TEXT NOT NULL
);''',
        '''
CREATE TABLE IF NOT EXISTS corpus_record (
  record_id TEXT NOT NULL PRIMARY KEY,
  corpus_bundle_version TEXT NOT NULL,
  kind TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  role_id TEXT,
  domain TEXT,
  level_band TEXT,
  company_archetype TEXT,
  metadata_json TEXT NOT NULL,
  FOREIGN KEY(corpus_bundle_version) REFERENCES corpus_bundle_manifest(corpus_bundle_version)
);''',
        '''
CREATE TABLE IF NOT EXISTS corpus_record_tag (
  record_id TEXT NOT NULL,
  tag TEXT NOT NULL,
  PRIMARY KEY(record_id, tag),
  FOREIGN KEY(record_id) REFERENCES corpus_record(record_id)
);''',
        '''
CREATE VIRTUAL TABLE IF NOT EXISTS corpus_record_fts USING fts5(
  record_id UNINDEXED,
  title,
  body,
  tags,
  tokenize = 'unicode61'
);''',
        '''
CREATE INDEX IF NOT EXISTS corpus_record_filter_idx
ON corpus_record (role_id, domain, level_band, company_archetype, record_id);''',
        '''
CREATE INDEX IF NOT EXISTS corpus_record_tag_idx
ON corpus_record_tag (tag, record_id);''',
      ];

  String get insertManifestSql =>
      _insertSql(manifestTableName, manifestColumns);

  String get insertRecordSql => _insertSql(recordTableName, recordColumns);

  String get insertTagSql => _insertSql(tagTableName, tagColumns);

  String get insertFtsSql => _insertSql(ftsTableName, ftsColumns);

  CorpusSqliteBundleRows encodeBundle(
    CorpusBundle bundle, {
    required DateTime createdAtUtc,
  }) {
    final manifest = encodeBundleManifest(bundle, createdAtUtc: createdAtUtc);
    final recordRows = <CorpusSqliteRow>[];
    final tagRows = <CorpusSqliteRow>[];
    final ftsRows = <CorpusSqliteRow>[];
    for (final record in bundle.records) {
      recordRows.add(encodeRecord(record));
      tagRows.addAll(encodeRecordTags(record));
      ftsRows.add(encodeFtsRecord(record));
    }

    return CorpusSqliteBundleRows(
      manifest: manifest,
      records: recordRows,
      tags: tagRows,
      ftsRecords: ftsRows,
    );
  }

  String retrievalSql({required int requiredTagCount}) {
    if (requiredTagCount < 0) {
      throw ArgumentError.value(
        requiredTagCount,
        'requiredTagCount',
        'must not be negative',
      );
    }

    final tagClause = requiredTagCount == 0
        ? ''
        : '''
  AND r.record_id IN (
    SELECT record_id
    FROM corpus_record_tag
    WHERE tag IN (${List<String>.filled(requiredTagCount, '?').join(', ')})
    GROUP BY record_id
    HAVING COUNT(DISTINCT tag) = $requiredTagCount
  )
''';

    return '''
SELECT r.record_id, bm25(corpus_record_fts) AS rank
FROM corpus_record_fts
JOIN corpus_record r ON r.record_id = corpus_record_fts.record_id
WHERE corpus_record_fts MATCH ?
  AND (? IS NULL OR r.role_id = ?)
  AND (? IS NULL OR r.domain = ?)
  AND (? IS NULL OR r.level_band = ?)
  AND (? IS NULL OR r.company_archetype = ?)
$tagClause
ORDER BY rank ASC, r.record_id ASC
LIMIT ?;''';
  }

  CorpusSqliteRow encodeBundleManifest(
    CorpusBundle bundle, {
    required DateTime createdAtUtc,
  }) {
    final utc = createdAtUtc.toUtc();
    return CorpusSqliteRow(
      tableName: manifestTableName,
      values: <String, Object?>{
        'corpus_bundle_version': bundle.bundleVersion,
        'signature': bundle.signature,
        'record_count': bundle.records.length,
        'created_at_utc': utc.toIso8601String(),
      },
    );
  }

  CorpusSqliteRow encodeRecord(CorpusRecord record) {
    return CorpusSqliteRow(
      tableName: recordTableName,
      values: <String, Object?>{
        'record_id': record.recordId,
        'corpus_bundle_version': record.corpusBundleVersion,
        'kind': _kindToWire(record.kind),
        'title': record.title,
        'body': record.body,
        'role_id': record.roleId,
        'domain': record.domain,
        'level_band': record.levelBand,
        'company_archetype': record.companyArchetype,
        'metadata_json': _sortedJson(record.metadata),
      },
    );
  }

  List<CorpusSqliteRow> encodeRecordTags(CorpusRecord record) {
    return UnmodifiableListView<CorpusSqliteRow>(
      <CorpusSqliteRow>[
        for (final tag in record.tags)
          CorpusSqliteRow(
            tableName: tagTableName,
            values: <String, Object?>{
              'record_id': record.recordId,
              'tag': tag,
            },
          ),
      ],
    );
  }

  CorpusSqliteRow encodeFtsRecord(CorpusRecord record) {
    return CorpusSqliteRow(
      tableName: ftsTableName,
      values: <String, Object?>{
        'record_id': record.recordId,
        'title': record.title,
        'body': record.body,
        'tags': record.tags.join(' '),
      },
    );
  }
}

final class CorpusSqliteRow {
  CorpusSqliteRow({
    required this.tableName,
    required Map<String, Object?> values,
  })  : values = UnmodifiableMapView<String, Object?>(
            Map<String, Object?>.of(values)),
        arguments = UnmodifiableListView<Object?>(values.values.toList());

  final String tableName;
  final UnmodifiableMapView<String, Object?> values;
  final UnmodifiableListView<Object?> arguments;
}

final class CorpusSqliteBundleRows {
  CorpusSqliteBundleRows({
    required this.manifest,
    required Iterable<CorpusSqliteRow> records,
    required Iterable<CorpusSqliteRow> tags,
    required Iterable<CorpusSqliteRow> ftsRecords,
  })  : records = UnmodifiableListView<CorpusSqliteRow>(records.toList()),
        tags = UnmodifiableListView<CorpusSqliteRow>(tags.toList()),
        ftsRecords = UnmodifiableListView<CorpusSqliteRow>(
          ftsRecords.toList(),
        );

  final CorpusSqliteRow manifest;
  final UnmodifiableListView<CorpusSqliteRow> records;
  final UnmodifiableListView<CorpusSqliteRow> tags;
  final UnmodifiableListView<CorpusSqliteRow> ftsRecords;

  UnmodifiableListView<CorpusSqliteRow> get allRows {
    return UnmodifiableListView<CorpusSqliteRow>(
      <CorpusSqliteRow>[manifest, ...records, ...tags, ...ftsRecords],
    );
  }
}

String _insertSql(String tableName, List<String> columns) {
  final placeholders = List<String>.filled(columns.length, '?').join(', ');
  return 'INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders);';
}

String _kindToWire(CorpusRecordKind kind) {
  return switch (kind) {
    CorpusRecordKind.rubricSlice => 'rubric_slice',
    CorpusRecordKind.benchmarkAnswer => 'benchmark_answer',
    CorpusRecordKind.glossaryTerm => 'glossary_term',
  };
}

String _sortedJson(Map<String, String> values) {
  return jsonEncode(<String, String>{
    for (final key in values.keys.toList()..sort()) key: values[key]!,
  });
}

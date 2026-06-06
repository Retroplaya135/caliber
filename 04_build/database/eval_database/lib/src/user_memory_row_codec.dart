import 'dart:collection';
import 'dart:convert';

import 'memory_models.dart';
import 'user_memory_schema.dart';

final class EncodedUserMemoryRow {
  EncodedUserMemoryRow({
    required this.table,
    required Map<String, Object?> values,
  }) : values = UnmodifiableMapView<String, Object?>(
          _orderedValues(table, values),
        );

  final UserMemoryTable table;
  final UnmodifiableMapView<String, Object?> values;

  String get tableName => table.tableName;

  List<String> get columns => UserMemorySchema.requiredColumns(table);

  List<Object?> get arguments {
    return <Object?>[
      for (final column in columns) values[column],
    ];
  }

  static Map<String, Object?> _orderedValues(
    UserMemoryTable table,
    Map<String, Object?> values,
  ) {
    final columns = UserMemorySchema.requiredColumns(table);
    final missing = columns.where((column) => !values.containsKey(column));
    if (missing.isNotEmpty) {
      throw StateError(
        'Encoded ${table.tableName} row is missing columns: ${missing.join(', ')}',
      );
    }

    return <String, Object?>{
      for (final column in columns) column: values[column],
    };
  }
}

final class UserMemoryRowCodec {
  const UserMemoryRowCodec();

  EncodedUserMemoryRow encode(UserMemoryRow row) {
    return switch (row) {
      TargetMatrixCell() => _targetMatrix(row),
      EvidenceLedgerEntry() => _evidenceLedger(row),
      GapLedgerEntry() => _gapLedger(row),
      HistoryEvent() => _historyEvent(row),
      SpeakingProfile() => _speakingProfile(row),
      DeletionTombstone() => _deletionTombstone(row),
      _ => throw ArgumentError.value(
          row.runtimeType,
          'row',
          'unknown user memory row type',
        ),
    };
  }

  EncodedUserMemoryRow _targetMatrix(TargetMatrixCell row) {
    return EncodedUserMemoryRow(
      table: UserMemoryTable.targetMatrix,
      values: _base(row)
        ..addAll(<String, Object?>{
          'role_id': row.roleId,
          'domain': row.domain,
          'level_band': row.levelBand,
          'company_archetype': row.companyArchetype,
          'priority': row.priority,
        }),
    );
  }

  EncodedUserMemoryRow _evidenceLedger(EvidenceLedgerEntry row) {
    return EncodedUserMemoryRow(
      table: UserMemoryTable.evidenceLedger,
      values: _base(row)
        ..addAll(<String, Object?>{
          'claim': row.claim,
          'strength_band': row.strengthBand,
        }),
    );
  }

  EncodedUserMemoryRow _gapLedger(GapLedgerEntry row) {
    return EncodedUserMemoryRow(
      table: UserMemoryTable.gapLedger,
      values: _base(row)
        ..addAll(<String, Object?>{
          'gap_label': row.gapLabel,
          'severity_band': row.severityBand,
          'remediation_hint': row.remediationHint,
        }),
    );
  }

  EncodedUserMemoryRow _historyEvent(HistoryEvent row) {
    return EncodedUserMemoryRow(
      table: UserMemoryTable.historyEvent,
      values: _base(row)
        ..addAll(<String, Object?>{
          'event_type': row.eventType,
          'summary': row.summary,
        }),
    );
  }

  EncodedUserMemoryRow _speakingProfile(SpeakingProfile row) {
    return EncodedUserMemoryRow(
      table: UserMemoryTable.speakingProfile,
      values: _base(row)
        ..addAll(<String, Object?>{
          'words_per_minute': row.wordsPerMinute,
          'pause_count': row.pauseCount,
          'filler_ratio': row.fillerRatio,
        }),
    );
  }

  EncodedUserMemoryRow _deletionTombstone(DeletionTombstone row) {
    return EncodedUserMemoryRow(
      table: UserMemoryTable.deletionTombstone,
      values: _base(row)
        ..addAll(<String, Object?>{
          'deleted_table': row.deletedTable,
          'deleted_row_id': row.deletedRowId,
          'deleted_at': row.deletedAt.toUtc().toIso8601String(),
        }),
    );
  }

  Map<String, Object?> _base(UserMemoryRow row) {
    return <String, Object?>{
      'row_id': row.rowId,
      'user_id': row.userId,
      'provenance_json': encodeProvenance(row.provenance),
    };
  }

  String encodeProvenance(Provenance provenance) {
    return jsonEncode(<String, Object?>{
      'source_id': provenance.sourceId,
      'source_type': provenance.sourceType,
      'schema_version': provenance.schemaVersion,
      'corpus_bundle_version': provenance.corpusBundleVersion,
      'created_at': provenance.createdAt.toUtc().toIso8601String(),
      'evidence_spans': <Map<String, Object?>>[
        for (final span in provenance.evidenceSpans) span.toJson(),
      ],
      'metadata': <String, String>{
        for (final key in provenance.metadata.keys.toList()..sort())
          key: provenance.metadata[key]!,
      },
    });
  }
}

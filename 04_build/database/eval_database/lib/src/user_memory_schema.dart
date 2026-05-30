import 'dart:collection';

import 'memory_models.dart';

final class UserMemorySchema {
  static const schemaVersion = 'user_memory_schema_v001';
  static const encryptionOwner = 'fork/09-storage-sync';

  static final tables = UnmodifiableMapView<UserMemoryTable, List<String>>(
    <UserMemoryTable, List<String>>{
      UserMemoryTable.targetMatrix: const <String>[
        'row_id',
        'user_id',
        'role_id',
        'domain',
        'level_band',
        'company_archetype',
        'priority',
        'provenance_json',
      ],
      UserMemoryTable.evidenceLedger: const <String>[
        'row_id',
        'user_id',
        'claim',
        'strength_band',
        'provenance_json',
      ],
      UserMemoryTable.gapLedger: const <String>[
        'row_id',
        'user_id',
        'gap_label',
        'severity_band',
        'remediation_hint',
        'provenance_json',
      ],
      UserMemoryTable.historyEvent: const <String>[
        'row_id',
        'user_id',
        'event_type',
        'summary',
        'provenance_json',
      ],
      UserMemoryTable.speakingProfile: const <String>[
        'row_id',
        'user_id',
        'words_per_minute',
        'pause_count',
        'filler_ratio',
        'provenance_json',
      ],
      UserMemoryTable.deletionTombstone: const <String>[
        'row_id',
        'user_id',
        'deleted_table',
        'deleted_row_id',
        'deleted_at',
        'provenance_json',
      ],
    },
  );

  static List<String> requiredColumns(UserMemoryTable table) {
    return List<String>.unmodifiable(tables[table] ?? const <String>[]);
  }
}

final class StorageSyncCoordinationNote {
  const StorageSyncCoordinationNote();

  String get owner => UserMemorySchema.encryptionOwner;

  String get evalClusterOwnership {
    return 'Eval Cluster owns per-user table shape, validation, deterministic writes, '
        'and row-level provenance. Storage Sync owns envelope encryption, migration '
        'runner, backup, rollback, and physical database opening.';
  }
}

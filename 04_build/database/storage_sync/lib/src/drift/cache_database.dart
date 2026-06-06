import 'package:drift/drift.dart';

import '../migrations/stepwise_migration.dart';
import 'v1_rollback_sql.dart';

part 'cache_database.g.dart';

class CacheStorageMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class CacheMigrationCheckpoints extends Table {
  IntColumn get fromVersion => integer()();
  IntColumn get toVersion => integer()();
  TextColumn get description => text()();
  DateTimeColumn get appliedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {fromVersion, toVersion};
}

class CacheEntries extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get scope => text()();
  BlobColumn get payload => blob()();
  DateTimeColumn get expiresAtUtc => dateTime().nullable()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}

@DriftDatabase(
  tables: [CacheStorageMetadata, CacheMigrationCheckpoints, CacheEntries],
)
class CacheStorageDatabase extends _$CacheStorageDatabase {
  CacheStorageDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  late final StepwiseMigrationPlan stepwiseMigrations = StepwiseMigrationPlan([
    CaliberMigrationStep(
      fromVersion: 1,
      toVersion: 2,
      description: 'Add cache metadata timestamps and migration checkpoints.',
      forward: (database, migrator) async {
        await migrator.addColumn(
          cacheStorageMetadata,
          cacheStorageMetadata.updatedAt,
        );
        await migrator.createTable(cacheMigrationCheckpoints);
        await migrator.createTable(cacheEntries);
        await _recordCheckpoint(
          fromVersion: 1,
          toVersion: 2,
          description:
              'Add cache metadata timestamps and migration checkpoints.',
        );
      },
      rollback: (database) => rollbackMetadataV2ToV1(
        database,
        metadataTable: 'cache_storage_metadata',
        checkpointTable: 'cache_migration_checkpoints',
        extraTables: const ['cache_entries'],
      ),
    ),
  ]);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        await customStatement('PRAGMA foreign_keys = OFF;');
        await stepwiseMigrations.apply(
          database: this,
          migrator: migrator,
          from: from,
          to: to,
        );
        await _assertForeignKeys();
        await customStatement('PRAGMA foreign_keys = ON;');
      },
      beforeOpen: (_) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Stream<List<CacheEntry>> watchEntries(String scope) {
    return (select(
      cacheEntries,
    )..where((table) => table.scope.equals(scope))).watch();
  }

  Future<void> putEntry({
    required String cacheKey,
    required String scope,
    required List<int> payload,
    DateTime? expiresAtUtc,
  }) {
    return into(cacheEntries).insertOnConflictUpdate(
      CacheEntriesCompanion.insert(
        cacheKey: cacheKey,
        scope: scope,
        payload: Uint8List.fromList(payload),
        expiresAtUtc: Value(expiresAtUtc?.toUtc()),
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> putMetadata(String key, String value) {
    return into(cacheStorageMetadata).insertOnConflictUpdate(
      CacheStorageMetadataCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<String?> readMetadata(String key) async {
    final row = await (select(
      cacheStorageMetadata,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _recordCheckpoint({
    required int fromVersion,
    required int toVersion,
    required String description,
  }) {
    return into(cacheMigrationCheckpoints).insertOnConflictUpdate(
      CacheMigrationCheckpointsCompanion.insert(
        fromVersion: fromVersion,
        toVersion: toVersion,
        description: description,
        appliedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _assertForeignKeys() async {
    final violations = await customSelect('PRAGMA foreign_key_check;').get();
    if (violations.isNotEmpty) {
      throw StateError(
        'Cache DB foreign key check failed: ${violations.length}',
      );
    }
  }
}

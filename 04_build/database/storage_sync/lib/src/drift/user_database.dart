import 'package:drift/drift.dart';

import '../migrations/stepwise_migration.dart';
import 'v1_rollback_sql.dart';

part 'user_database.g.dart';

class UserStorageMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class UserMigrationCheckpoints extends Table {
  IntColumn get fromVersion => integer()();
  IntColumn get toVersion => integer()();
  TextColumn get description => text()();
  DateTimeColumn get appliedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {fromVersion, toVersion};
}

@DriftDatabase(tables: [UserStorageMetadata, UserMigrationCheckpoints])
class UserStorageDatabase extends _$UserStorageDatabase {
  UserStorageDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  late final StepwiseMigrationPlan stepwiseMigrations = StepwiseMigrationPlan([
    CaliberMigrationStep(
      fromVersion: 1,
      toVersion: 2,
      description: 'Add user metadata timestamps and migration checkpoints.',
      forward: (database, migrator) async {
        await migrator.addColumn(
          userStorageMetadata,
          userStorageMetadata.updatedAt,
        );
        await migrator.createTable(userMigrationCheckpoints);
        await _recordCheckpoint(
          fromVersion: 1,
          toVersion: 2,
          description:
              'Add user metadata timestamps and migration checkpoints.',
        );
      },
      rollback: (database) => rollbackMetadataV2ToV1(
        database,
        metadataTable: 'user_storage_metadata',
        checkpointTable: 'user_migration_checkpoints',
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

  Stream<List<UserStorageMetadataData>> watchMetadata() {
    return select(userStorageMetadata).watch();
  }

  Future<void> putMetadata(String key, String value) {
    return into(userStorageMetadata).insertOnConflictUpdate(
      UserStorageMetadataCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<String?> readMetadata(String key) async {
    final row = await (select(
      userStorageMetadata,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _recordCheckpoint({
    required int fromVersion,
    required int toVersion,
    required String description,
  }) {
    return into(userMigrationCheckpoints).insertOnConflictUpdate(
      UserMigrationCheckpointsCompanion.insert(
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
        'User DB foreign key check failed: ${violations.length}',
      );
    }
  }
}

import 'package:drift/drift.dart';

import '../migrations/stepwise_migration.dart';
import '../sync/corpus_bundle.dart';
import 'v1_rollback_sql.dart';

part 'corpus_database.g.dart';

class CorpusStorageMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class CorpusMigrationCheckpoints extends Table {
  IntColumn get fromVersion => integer()();
  IntColumn get toVersion => integer()();
  TextColumn get description => text()();
  DateTimeColumn get appliedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {fromVersion, toVersion};
}

class CorpusBundles extends Table {
  IntColumn get corpusBundleVersion => integer()();
  TextColumn get bundleId => text()();
  TextColumn get payloadSha256 => text()();
  IntColumn get payloadSizeBytes => integer()();
  BlobColumn get payload => blob()();
  BlobColumn get signature => blob()();
  BlobColumn get publicKey => blob()();
  TextColumn get manifestJson => text()();
  DateTimeColumn get publishedAtUtc => dateTime()();
  DateTimeColumn get adoptedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {corpusBundleVersion};
}

@DriftDatabase(
  tables: [CorpusStorageMetadata, CorpusMigrationCheckpoints, CorpusBundles],
)
class CorpusStorageDatabase extends _$CorpusStorageDatabase {
  CorpusStorageDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  late final StepwiseMigrationPlan stepwiseMigrations = StepwiseMigrationPlan([
    CaliberMigrationStep(
      fromVersion: 1,
      toVersion: 2,
      description: 'Add corpus metadata timestamps and migration checkpoints.',
      forward: (database, migrator) async {
        await migrator.addColumn(
          corpusStorageMetadata,
          corpusStorageMetadata.updatedAt,
        );
        await migrator.createTable(corpusMigrationCheckpoints);
        await migrator.createTable(corpusBundles);
        await _recordCheckpoint(
          fromVersion: 1,
          toVersion: 2,
          description:
              'Add corpus metadata timestamps and migration checkpoints.',
        );
      },
      rollback: (database) => rollbackMetadataV2ToV1(
        database,
        metadataTable: 'corpus_storage_metadata',
        checkpointTable: 'corpus_migration_checkpoints',
        extraTables: const ['corpus_bundles'],
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

  Stream<List<CorpusBundle>> watchCorpusBundles() {
    return (select(corpusBundles)
          ..orderBy([(table) => OrderingTerm.desc(table.corpusBundleVersion)]))
        .watch();
  }

  Future<int?> latestBundleVersion() async {
    final row = await customSelect(
      'SELECT MAX(corpus_bundle_version) AS version FROM corpus_bundles;',
      readsFrom: {corpusBundles},
    ).getSingle();
    return row.data['version'] as int?;
  }

  Future<void> adoptVerifiedBundle(SignedCorpusBundle bundle) async {
    final latest = await latestBundleVersion();
    final incoming = bundle.manifest.corpusBundleVersion;
    if (latest != null && incoming <= latest) {
      throw StateError(
        'Corpus bundle $incoming is not newer than active bundle $latest.',
      );
    }

    await into(corpusBundles).insert(
      CorpusBundlesCompanion.insert(
        corpusBundleVersion: Value(incoming),
        bundleId: bundle.manifest.bundleId,
        payloadSha256: bundle.manifest.payloadSha256,
        payloadSizeBytes: bundle.manifest.payloadSizeBytes,
        payload: Uint8List.fromList(bundle.payload),
        signature: Uint8List.fromList(bundle.signature),
        publicKey: Uint8List.fromList(bundle.publicKey),
        manifestJson: bundle.manifest.canonicalJson,
        publishedAtUtc: bundle.manifest.publishedAtUtc,
        adoptedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> putMetadata(String key, String value) {
    return into(corpusStorageMetadata).insertOnConflictUpdate(
      CorpusStorageMetadataCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<String?> readMetadata(String key) async {
    final row = await (select(
      corpusStorageMetadata,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _recordCheckpoint({
    required int fromVersion,
    required int toVersion,
    required String description,
  }) {
    return into(corpusMigrationCheckpoints).insertOnConflictUpdate(
      CorpusMigrationCheckpointsCompanion.insert(
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
        'Corpus DB foreign key check failed: ${violations.length}',
      );
    }
  }
}

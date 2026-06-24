import 'dart:io';

import 'package:caliber_storage_sync/src/crypto/database_key_manager.dart';
import 'package:caliber_storage_sync/src/crypto/database_key_vault.dart';
import 'package:caliber_storage_sync/src/crypto/sqlite_encryption.dart';
import 'package:caliber_storage_sync/src/drift/user_database.dart';
import 'package:caliber_storage_sync/src/migrations/migration_backup_manager.dart';
import 'package:caliber_storage_sync/src/testing/fakes.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'migrates v1 to v2, preserves data, and rollback script returns to v1',
    () async {
      final harness = await _MigrationHarness.create();
      addTearDown(harness.dispose);
      await harness.createLegacyUserDatabase('preserved-ledger-value');

      final db = UserStorageDatabase(
        harness.encryption.encryptedNativeDatabase(
          file: harness.userFile,
          key: harness.key,
        ),
      );
      await db.customSelect('SELECT 1 AS migrated;').get();
      expect(await db.readMetadata('ledger'), 'preserved-ledger-value');
      await db.close();

      final raw = sqlite.sqlite3.open(harness.userFile.path);
      addTearDown(raw.dispose);
      harness.encryption.applyKey(raw, harness.key);
      await UserStorageDatabase(
        NativeDatabase.memory(),
      ).stepwiseMigrations.rollback(database: raw, from: 1, to: 2);

      final version =
          raw.select('PRAGMA user_version;').first['user_version'] as int;
      expect(version, 1);
      final columns = raw.select('PRAGMA table_info(user_storage_metadata);');
      expect(columns.map((row) => row['name']), isNot(contains('updated_at')));
      expect(
        raw
            .select(
              "SELECT value FROM user_storage_metadata WHERE key = 'ledger';",
            )
            .first['value'],
        'preserved-ledger-value',
      );
    },
  );

  test('restores pre-upgrade backup when migration action fails', () async {
    final harness = await _MigrationHarness.create();
    addTearDown(harness.dispose);
    await harness.createLegacyUserDatabase('rollback-ledger-value');

    final backupManager = MigrationBackupManager(
      backupRoot: Directory(p.join(harness.root.path, 'backups')),
    );

    await expectLater(
      backupManager.runWithRollback<void>(
        kind: LogicalDatabaseKind.user,
        databaseFile: harness.userFile,
        action: (_) async {
          final raw = sqlite.sqlite3.open(harness.userFile.path);
          try {
            harness.encryption.applyKey(raw, harness.key);
            raw.execute('DROP TABLE user_storage_metadata;');
          } finally {
            raw.dispose();
          }
          throw StateError('forced migration failure');
        },
      ),
      throwsA(isA<MigrationRolledBackException>()),
    );

    final raw = sqlite.sqlite3.open(harness.userFile.path);
    addTearDown(raw.dispose);
    harness.encryption.applyKey(raw, harness.key);
    final row = raw
        .select("SELECT value FROM user_storage_metadata WHERE key = 'ledger';")
        .first;
    expect(row['value'], 'rollback-ledger-value');
  });
}

final class _MigrationHarness {
  _MigrationHarness({
    required this.root,
    required this.userFile,
    required this.key,
    required this.encryption,
  });

  final Directory root;
  final File userFile;
  final DatabaseKey key;
  final SqliteEncryption encryption;

  static Future<_MigrationHarness> create() async {
    final root = await Directory.systemTemp.createTemp('caliber-migration-');
    final file = File(p.join(root.path, 'user.sqlite3'));
    final manager = DatabaseKeyManager(
      vault: MemoryDatabaseKeyVault(),
      generator: FixedDatabaseKeyGenerator(31),
    );
    final key = await manager.getOrCreate(LogicalDatabaseKind.user);
    return _MigrationHarness(
      root: root,
      userFile: file,
      key: key,
      encryption: const SqliteEncryption(
        config: SqliteEncryptionConfig(requireCipherPragma: false),
      ),
    );
  }

  Future<void> createLegacyUserDatabase(String value) async {
    await userFile.parent.create(recursive: true);
    final raw = sqlite.sqlite3.open(userFile.path);
    try {
      encryption.applyKey(raw, key);
      raw.execute('''
CREATE TABLE user_storage_metadata (
  key TEXT NOT NULL PRIMARY KEY,
  value TEXT NOT NULL
);
''');
      raw.execute(
        "INSERT INTO user_storage_metadata (key, value) VALUES ('ledger', '$value');",
      );
      raw.execute('PRAGMA user_version = 1;');
    } finally {
      raw.dispose();
    }
  }

  Future<void> dispose() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }
}

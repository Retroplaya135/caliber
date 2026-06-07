import 'dart:io';

import 'package:drift/drift.dart';

import '../crypto/database_key_manager.dart';
import '../crypto/database_key_vault.dart';
import '../crypto/sqlite_encryption.dart';
import '../drift/cache_database.dart';
import '../drift/corpus_database.dart';
import '../drift/user_database.dart';
import '../migrations/migration_backup_manager.dart';
import '../paths/storage_paths.dart';

final class CaliberStorageFactory {
  CaliberStorageFactory({
    required this._pathResolver,
    required this._keyManager,
    this._encryption = const SqliteEncryption(),
  });

  final CaliberStoragePathResolver _pathResolver;
  final DatabaseKeyManager _keyManager;
  final SqliteEncryption _encryption;

  Future<CaliberStorageHandle> open() async {
    final paths = await _pathResolver.resolve();
    await paths.ensureCreated();
    final backupManager = MigrationBackupManager(
      backupRoot: paths.backupDirectory,
    );

    final user = await _openDatabase<UserStorageDatabase>(
      kind: LogicalDatabaseKind.user,
      paths: paths,
      backupManager: backupManager,
      create: UserStorageDatabase.new,
    );
    final corpus = await _openDatabase<CorpusStorageDatabase>(
      kind: LogicalDatabaseKind.corpus,
      paths: paths,
      backupManager: backupManager,
      create: CorpusStorageDatabase.new,
    );
    final cache = await _openDatabase<CacheStorageDatabase>(
      kind: LogicalDatabaseKind.cache,
      paths: paths,
      backupManager: backupManager,
      create: CacheStorageDatabase.new,
    );

    return CaliberStorageHandle(
      paths: paths,
      user: user,
      corpus: corpus,
      cache: cache,
    );
  }

  Future<T> _openDatabase<T extends GeneratedDatabase>({
    required LogicalDatabaseKind kind,
    required CaliberStoragePaths paths,
    required MigrationBackupManager backupManager,
    required T Function(QueryExecutor executor) create,
  }) async {
    final file = paths.databaseFile(kind);
    await file.parent.create(recursive: true);
    final key = await _keyManager.getOrCreate(kind);

    return backupManager.runWithRollback<T>(
      kind: kind,
      databaseFile: file,
      action: (_) async {
        T? database;
        try {
          final executor = _encryption.encryptedNativeDatabase(
            file: file,
            key: key,
          );
          database = create(executor);
          await database.customSelect('SELECT 1 AS storage_ready;').get();
          return database;
        } catch (_) {
          await database?.close();
          rethrow;
        }
      },
    );
  }
}

final class CaliberStorageHandle {
  const CaliberStorageHandle({
    required this.paths,
    required this.user,
    required this.corpus,
    required this.cache,
  });

  final CaliberStoragePaths paths;
  final UserStorageDatabase user;
  final CorpusStorageDatabase corpus;
  final CacheStorageDatabase cache;

  Map<LogicalDatabaseKind, File> get physicalFiles => {
    LogicalDatabaseKind.user: paths.databaseFile(LogicalDatabaseKind.user),
    LogicalDatabaseKind.corpus: paths.databaseFile(LogicalDatabaseKind.corpus),
    LogicalDatabaseKind.cache: paths.databaseFile(LogicalDatabaseKind.cache),
  };

  Future<void> close() async {
    await user.close();
    await corpus.close();
    await cache.close();
  }
}

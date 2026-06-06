import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../crypto/database_key_vault.dart';

final class MigrationBackup {
  const MigrationBackup({
    required this.kind,
    required this.createdAtUtc,
    required this.originalDatabase,
    required this.backupDirectory,
    required this.copiedFiles,
  });

  final LogicalDatabaseKind kind;
  final DateTime createdAtUtc;
  final File originalDatabase;
  final Directory backupDirectory;
  final Map<String, File> copiedFiles;

  bool get hasBackup => copiedFiles.isNotEmpty;
}

final class MigrationRolledBackException implements Exception {
  const MigrationRolledBackException(this.kind, this.cause);

  final LogicalDatabaseKind kind;
  final Object cause;

  @override
  String toString() {
    return 'Migration for ${kind.storageName} rolled back after failure: $cause';
  }
}

final class MigrationBackupManager {
  const MigrationBackupManager({required this._backupRoot});

  final Directory _backupRoot;

  Future<MigrationBackup> createPreUpgradeBackup({
    required LogicalDatabaseKind kind,
    required File databaseFile,
    DateTime? nowUtc,
  }) async {
    await _backupRoot.create(recursive: true);
    final createdAt = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    final stamp = createdAt.toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final backupDirectory = Directory(
      p.join(_backupRoot.path, kind.storageName, stamp),
    );
    await backupDirectory.create(recursive: true);

    final copied = <String, File>{};
    for (final source in _sqliteSidecarSet(databaseFile)) {
      if (!source.existsSync()) {
        continue;
      }

      final backup = File(
        p.join(backupDirectory.path, p.basename(source.path)),
      );
      await source.copy(backup.path);
      copied[source.path] = backup;
    }

    await _writeManifest(
      backupDirectory: backupDirectory,
      kind: kind,
      createdAt: createdAt,
      copiedFiles: copied,
    );

    return MigrationBackup(
      kind: kind,
      createdAtUtc: createdAt,
      originalDatabase: databaseFile,
      backupDirectory: backupDirectory,
      copiedFiles: Map.unmodifiable(copied),
    );
  }

  Future<T> runWithRollback<T>({
    required LogicalDatabaseKind kind,
    required File databaseFile,
    required Future<T> Function(MigrationBackup backup) action,
  }) async {
    final backup = await createPreUpgradeBackup(
      kind: kind,
      databaseFile: databaseFile,
    );

    try {
      return await action(backup);
    } catch (error) {
      if (backup.hasBackup) {
        await restore(backup);
      }
      throw MigrationRolledBackException(kind, error);
    }
  }

  Future<void> restore(MigrationBackup backup) async {
    for (final original in _sqliteSidecarSet(backup.originalDatabase)) {
      if (original.existsSync()) {
        await original.delete();
      }
    }

    for (final entry in backup.copiedFiles.entries) {
      final original = File(entry.key);
      await original.parent.create(recursive: true);
      await entry.value.copy(original.path);
    }
  }

  Future<void> _writeManifest({
    required Directory backupDirectory,
    required LogicalDatabaseKind kind,
    required DateTime createdAt,
    required Map<String, File> copiedFiles,
  }) async {
    final files = <Map<String, Object?>>[];
    for (final entry in copiedFiles.entries) {
      final bytes = await entry.value.readAsBytes();
      files.add({
        'original_path': entry.key,
        'backup_file': p.basename(entry.value.path),
        'sha256': sha256.convert(bytes).toString(),
        'size_bytes': bytes.length,
      });
    }

    final manifest = {
      'kind': kind.storageName,
      'created_at_utc': createdAt.toIso8601String(),
      'files': files,
    };

    const encoder = JsonEncoder.withIndent('  ');
    await File(
      p.join(backupDirectory.path, 'manifest.json'),
    ).writeAsString(encoder.convert(manifest));
  }

  static List<File> _sqliteSidecarSet(File databaseFile) {
    return [
      databaseFile,
      File('${databaseFile.path}-wal'),
      File('${databaseFile.path}-shm'),
    ];
  }
}

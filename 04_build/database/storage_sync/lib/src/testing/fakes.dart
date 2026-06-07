import 'dart:io';

import 'package:path/path.dart' as p;

import '../crypto/database_key_vault.dart';
import '../paths/storage_paths.dart';

final class MemoryDatabaseKeyVault implements DatabaseKeyVault {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

final class FixedDatabaseKeyGenerator implements DatabaseKeyGenerator {
  FixedDatabaseKeyGenerator(this.seed);

  final int seed;
  int _calls = 0;

  @override
  DatabaseKey generate() {
    final offset = seed + (_calls * DatabaseKey.lengthBytes);
    _calls += 1;
    return DatabaseKey(
      List<int>.generate(
        DatabaseKey.lengthBytes,
        (index) => (offset + index) % 256,
      ),
    );
  }
}

final class FixedStoragePathResolver implements CaliberStoragePathResolver {
  const FixedStoragePathResolver(this.root);

  final Directory root;

  @override
  Future<CaliberStoragePaths> resolve() async {
    return CaliberStoragePaths(
      rootDirectory: root,
      databaseDirectory: Directory(p.join(root.path, 'databases')),
      backupDirectory: Directory(p.join(root.path, 'migration_backups')),
      bundleDirectory: Directory(p.join(root.path, 'corpus_bundles')),
    );
  }
}

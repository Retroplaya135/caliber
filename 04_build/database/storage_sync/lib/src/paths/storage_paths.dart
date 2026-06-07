import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../crypto/database_key_vault.dart';

final class CaliberStoragePaths {
  const CaliberStoragePaths({
    required this.rootDirectory,
    required this.databaseDirectory,
    required this.backupDirectory,
    required this.bundleDirectory,
  });

  final Directory rootDirectory;
  final Directory databaseDirectory;
  final Directory backupDirectory;
  final Directory bundleDirectory;

  File databaseFile(LogicalDatabaseKind kind) {
    return File(p.join(databaseDirectory.path, '${kind.storageName}.sqlite3'));
  }

  Future<void> ensureCreated() async {
    await rootDirectory.create(recursive: true);
    await databaseDirectory.create(recursive: true);
    await backupDirectory.create(recursive: true);
    await bundleDirectory.create(recursive: true);
  }
}

abstract interface class CaliberStoragePathResolver {
  Future<CaliberStoragePaths> resolve();
}

final class PathProviderStoragePathResolver
    implements CaliberStoragePathResolver {
  const PathProviderStoragePathResolver({this.appFolderName = 'caliber'});

  final String appFolderName;

  @override
  Future<CaliberStoragePaths> resolve() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, appFolderName));
    return CaliberStoragePaths(
      rootDirectory: root,
      databaseDirectory: Directory(p.join(root.path, 'databases')),
      backupDirectory: Directory(p.join(root.path, 'migration_backups')),
      bundleDirectory: Directory(p.join(root.path, 'corpus_bundles')),
    );
  }
}

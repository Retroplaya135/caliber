import 'package:sqlite3/sqlite3.dart' as sqlite;

Future<void> rollbackMetadataV2ToV1(
  sqlite.Database database, {
  required String metadataTable,
  required String checkpointTable,
  List<String> extraTables = const [],
}) async {
  database.execute('PRAGMA foreign_keys = OFF;');
  for (final table in extraTables) {
    database.execute('DROP TABLE IF EXISTS $table;');
  }
  database.execute('DROP TABLE IF EXISTS $checkpointTable;');
  database.execute(
    'CREATE TABLE ${metadataTable}_v1 (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);',
  );
  database.execute(
    'INSERT INTO ${metadataTable}_v1 (key, value) SELECT key, value FROM $metadataTable;',
  );
  database.execute('DROP TABLE $metadataTable;');
  database.execute('ALTER TABLE ${metadataTable}_v1 RENAME TO $metadataTable;');
  database.execute('PRAGMA user_version = 1;');
  database.execute('PRAGMA foreign_keys = ON;');
}

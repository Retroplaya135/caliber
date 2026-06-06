import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'database_key_vault.dart';

final class SqliteEncryptionConfig {
  const SqliteEncryptionConfig({this.requireCipherPragma = true});

  final bool requireCipherPragma;
}

final class MissingSqliteCipherException implements Exception {
  const MissingSqliteCipherException();

  @override
  String toString() {
    return 'SQLite3MultipleCiphers is not active; PRAGMA cipher returned no rows.';
  }
}

final class SqliteEncryption {
  const SqliteEncryption({this.config = const SqliteEncryptionConfig()});

  final SqliteEncryptionConfig config;

  QueryExecutor encryptedNativeDatabase({
    required File file,
    required DatabaseKey key,
  }) {
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        applyKey(rawDb, key);
      },
    );
  }

  void applyKey(sqlite.Database rawDb, DatabaseKey key) {
    if (config.requireCipherPragma && !hasCipher(rawDb)) {
      throw const MissingSqliteCipherException();
    }

    rawDb.execute("PRAGMA key = '${_escapeSql(key.hexValue)}';");
    rawDb.execute('PRAGMA foreign_keys = ON;');

    // Force SQLite to touch the schema immediately so a missing or incorrect key
    // fails before drift starts issuing app queries.
    rawDb.select('SELECT count(*) AS table_count FROM sqlite_master;');
  }

  bool hasCipher(sqlite.Database rawDb) {
    try {
      return rawDb.select('PRAGMA cipher;').isNotEmpty;
    } on sqlite.SqliteException {
      return false;
    }
  }

  static String _escapeSql(String value) {
    return value.replaceAll("'", "''");
  }
}

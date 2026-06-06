import 'dart:collection';

import 'memory_models.dart';
import 'user_memory_schema.dart';

final class UserMemorySqlPlan {
  const UserMemorySqlPlan();

  List<UserMemorySqlTablePlan> get tables {
    return UnmodifiableListView<UserMemorySqlTablePlan>(
      <UserMemorySqlTablePlan>[
        for (final table in UserMemoryTable.values) tablePlan(table),
      ],
    );
  }

  UserMemorySqlTablePlan tablePlan(UserMemoryTable table) {
    final columns = UserMemorySchema.requiredColumns(table);
    return UserMemorySqlTablePlan(
      table: table,
      columns: columns,
      columnTypes: <String, String>{
        for (final column in columns) column: _sqliteType(column),
      },
    );
  }
}

final class UserMemorySqlTablePlan {
  UserMemorySqlTablePlan({
    required this.table,
    required Iterable<String> columns,
    required Map<String, String> columnTypes,
  })  : columns = UnmodifiableListView<String>(columns.toList()),
        columnTypes = UnmodifiableMapView<String, String>(
            Map<String, String>.from(columnTypes));

  final UserMemoryTable table;
  final UnmodifiableListView<String> columns;
  final UnmodifiableMapView<String, String> columnTypes;

  String get tableName => table.tableName;

  String get createTableSql {
    final columnLines = <String>[
      for (final column in columns) '  $column ${columnTypes[column]}',
      '  PRIMARY KEY (user_id, row_id)',
    ];
    return 'CREATE TABLE IF NOT EXISTS $tableName (\n'
        '${columnLines.join(',\n')}\n'
        ');';
  }

  String get createUserIndexSql {
    return 'CREATE INDEX IF NOT EXISTS ${tableName}_user_id_idx '
        'ON $tableName (user_id);';
  }

  String get upsertSql {
    final placeholders = List<String>.filled(columns.length, '?').join(', ');
    final updates = columns
        .where((column) => column != 'user_id' && column != 'row_id')
        .map((column) => '$column = excluded.$column')
        .join(', ');
    return 'INSERT INTO $tableName (${columns.join(', ')}) '
        'VALUES ($placeholders) '
        'ON CONFLICT(user_id, row_id) DO UPDATE SET $updates;';
  }

  String get deleteVisibleRowSql {
    return 'DELETE FROM $tableName WHERE user_id = ? AND row_id = ?;';
  }
}

String _sqliteType(String column) {
  return switch (column) {
    'priority' || 'pause_count' => 'INTEGER NOT NULL',
    'words_per_minute' || 'filler_ratio' => 'REAL NOT NULL',
    _ => 'TEXT NOT NULL',
  };
}

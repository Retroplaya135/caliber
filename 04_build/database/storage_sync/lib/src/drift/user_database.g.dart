// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// ignore_for_file: type=lint
class $UserStorageMetadataTable extends UserStorageMetadata
    with TableInfo<$UserStorageMetadataTable, UserStorageMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStorageMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_storage_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserStorageMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserStorageMetadataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStorageMetadataData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UserStorageMetadataTable createAlias(String alias) {
    return $UserStorageMetadataTable(attachedDatabase, alias);
  }
}

class UserStorageMetadataData extends DataClass
    implements Insertable<UserStorageMetadataData> {
  final String key;
  final String value;
  final DateTime? updatedAt;
  const UserStorageMetadataData({
    required this.key,
    required this.value,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UserStorageMetadataCompanion toCompanion(bool nullToAbsent) {
    return UserStorageMetadataCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UserStorageMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStorageMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UserStorageMetadataData copyWith({
    String? key,
    String? value,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => UserStorageMetadataData(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  UserStorageMetadataData copyWithCompanion(UserStorageMetadataCompanion data) {
    return UserStorageMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStorageMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStorageMetadataData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserStorageMetadataCompanion
    extends UpdateCompanion<UserStorageMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UserStorageMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserStorageMetadataCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserStorageMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserStorageMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserStorageMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStorageMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserMigrationCheckpointsTable extends UserMigrationCheckpoints
    with TableInfo<$UserMigrationCheckpointsTable, UserMigrationCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMigrationCheckpointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fromVersionMeta = const VerificationMeta(
    'fromVersion',
  );
  @override
  late final GeneratedColumn<int> fromVersion = GeneratedColumn<int>(
    'from_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toVersionMeta = const VerificationMeta(
    'toVersion',
  );
  @override
  late final GeneratedColumn<int> toVersion = GeneratedColumn<int>(
    'to_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtUtcMeta = const VerificationMeta(
    'appliedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAtUtc = GeneratedColumn<DateTime>(
    'applied_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    fromVersion,
    toVersion,
    description,
    appliedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_migration_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserMigrationCheckpoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('from_version')) {
      context.handle(
        _fromVersionMeta,
        fromVersion.isAcceptableOrUnknown(
          data['from_version']!,
          _fromVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromVersionMeta);
    }
    if (data.containsKey('to_version')) {
      context.handle(
        _toVersionMeta,
        toVersion.isAcceptableOrUnknown(data['to_version']!, _toVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_toVersionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('applied_at_utc')) {
      context.handle(
        _appliedAtUtcMeta,
        appliedAtUtc.isAcceptableOrUnknown(
          data['applied_at_utc']!,
          _appliedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fromVersion, toVersion};
  @override
  UserMigrationCheckpoint map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMigrationCheckpoint(
      fromVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_version'],
      )!,
      toVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_version'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      appliedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at_utc'],
      )!,
    );
  }

  @override
  $UserMigrationCheckpointsTable createAlias(String alias) {
    return $UserMigrationCheckpointsTable(attachedDatabase, alias);
  }
}

class UserMigrationCheckpoint extends DataClass
    implements Insertable<UserMigrationCheckpoint> {
  final int fromVersion;
  final int toVersion;
  final String description;
  final DateTime appliedAtUtc;
  const UserMigrationCheckpoint({
    required this.fromVersion,
    required this.toVersion,
    required this.description,
    required this.appliedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['from_version'] = Variable<int>(fromVersion);
    map['to_version'] = Variable<int>(toVersion);
    map['description'] = Variable<String>(description);
    map['applied_at_utc'] = Variable<DateTime>(appliedAtUtc);
    return map;
  }

  UserMigrationCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return UserMigrationCheckpointsCompanion(
      fromVersion: Value(fromVersion),
      toVersion: Value(toVersion),
      description: Value(description),
      appliedAtUtc: Value(appliedAtUtc),
    );
  }

  factory UserMigrationCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMigrationCheckpoint(
      fromVersion: serializer.fromJson<int>(json['fromVersion']),
      toVersion: serializer.fromJson<int>(json['toVersion']),
      description: serializer.fromJson<String>(json['description']),
      appliedAtUtc: serializer.fromJson<DateTime>(json['appliedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fromVersion': serializer.toJson<int>(fromVersion),
      'toVersion': serializer.toJson<int>(toVersion),
      'description': serializer.toJson<String>(description),
      'appliedAtUtc': serializer.toJson<DateTime>(appliedAtUtc),
    };
  }

  UserMigrationCheckpoint copyWith({
    int? fromVersion,
    int? toVersion,
    String? description,
    DateTime? appliedAtUtc,
  }) => UserMigrationCheckpoint(
    fromVersion: fromVersion ?? this.fromVersion,
    toVersion: toVersion ?? this.toVersion,
    description: description ?? this.description,
    appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
  );
  UserMigrationCheckpoint copyWithCompanion(
    UserMigrationCheckpointsCompanion data,
  ) {
    return UserMigrationCheckpoint(
      fromVersion: data.fromVersion.present
          ? data.fromVersion.value
          : this.fromVersion,
      toVersion: data.toVersion.present ? data.toVersion.value : this.toVersion,
      description: data.description.present
          ? data.description.value
          : this.description,
      appliedAtUtc: data.appliedAtUtc.present
          ? data.appliedAtUtc.value
          : this.appliedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMigrationCheckpoint(')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('description: $description, ')
          ..write('appliedAtUtc: $appliedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(fromVersion, toVersion, description, appliedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMigrationCheckpoint &&
          other.fromVersion == this.fromVersion &&
          other.toVersion == this.toVersion &&
          other.description == this.description &&
          other.appliedAtUtc == this.appliedAtUtc);
}

class UserMigrationCheckpointsCompanion
    extends UpdateCompanion<UserMigrationCheckpoint> {
  final Value<int> fromVersion;
  final Value<int> toVersion;
  final Value<String> description;
  final Value<DateTime> appliedAtUtc;
  final Value<int> rowid;
  const UserMigrationCheckpointsCompanion({
    this.fromVersion = const Value.absent(),
    this.toVersion = const Value.absent(),
    this.description = const Value.absent(),
    this.appliedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserMigrationCheckpointsCompanion.insert({
    required int fromVersion,
    required int toVersion,
    required String description,
    required DateTime appliedAtUtc,
    this.rowid = const Value.absent(),
  }) : fromVersion = Value(fromVersion),
       toVersion = Value(toVersion),
       description = Value(description),
       appliedAtUtc = Value(appliedAtUtc);
  static Insertable<UserMigrationCheckpoint> custom({
    Expression<int>? fromVersion,
    Expression<int>? toVersion,
    Expression<String>? description,
    Expression<DateTime>? appliedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fromVersion != null) 'from_version': fromVersion,
      if (toVersion != null) 'to_version': toVersion,
      if (description != null) 'description': description,
      if (appliedAtUtc != null) 'applied_at_utc': appliedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserMigrationCheckpointsCompanion copyWith({
    Value<int>? fromVersion,
    Value<int>? toVersion,
    Value<String>? description,
    Value<DateTime>? appliedAtUtc,
    Value<int>? rowid,
  }) {
    return UserMigrationCheckpointsCompanion(
      fromVersion: fromVersion ?? this.fromVersion,
      toVersion: toVersion ?? this.toVersion,
      description: description ?? this.description,
      appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fromVersion.present) {
      map['from_version'] = Variable<int>(fromVersion.value);
    }
    if (toVersion.present) {
      map['to_version'] = Variable<int>(toVersion.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (appliedAtUtc.present) {
      map['applied_at_utc'] = Variable<DateTime>(appliedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMigrationCheckpointsCompanion(')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('description: $description, ')
          ..write('appliedAtUtc: $appliedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserStorageDatabase extends GeneratedDatabase {
  _$UserStorageDatabase(QueryExecutor e) : super(e);
  $UserStorageDatabaseManager get managers => $UserStorageDatabaseManager(this);
  late final $UserStorageMetadataTable userStorageMetadata =
      $UserStorageMetadataTable(this);
  late final $UserMigrationCheckpointsTable userMigrationCheckpoints =
      $UserMigrationCheckpointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userStorageMetadata,
    userMigrationCheckpoints,
  ];
}

typedef $$UserStorageMetadataTableCreateCompanionBuilder =
    UserStorageMetadataCompanion Function({
      required String key,
      required String value,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$UserStorageMetadataTableUpdateCompanionBuilder =
    UserStorageMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$UserStorageMetadataTableFilterComposer
    extends Composer<_$UserStorageDatabase, $UserStorageMetadataTable> {
  $$UserStorageMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserStorageMetadataTableOrderingComposer
    extends Composer<_$UserStorageDatabase, $UserStorageMetadataTable> {
  $$UserStorageMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserStorageMetadataTableAnnotationComposer
    extends Composer<_$UserStorageDatabase, $UserStorageMetadataTable> {
  $$UserStorageMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserStorageMetadataTableTableManager
    extends
        RootTableManager<
          _$UserStorageDatabase,
          $UserStorageMetadataTable,
          UserStorageMetadataData,
          $$UserStorageMetadataTableFilterComposer,
          $$UserStorageMetadataTableOrderingComposer,
          $$UserStorageMetadataTableAnnotationComposer,
          $$UserStorageMetadataTableCreateCompanionBuilder,
          $$UserStorageMetadataTableUpdateCompanionBuilder,
          (
            UserStorageMetadataData,
            BaseReferences<
              _$UserStorageDatabase,
              $UserStorageMetadataTable,
              UserStorageMetadataData
            >,
          ),
          UserStorageMetadataData,
          PrefetchHooks Function()
        > {
  $$UserStorageMetadataTableTableManager(
    _$UserStorageDatabase db,
    $UserStorageMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStorageMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStorageMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserStorageMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserStorageMetadataCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserStorageMetadataCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserStorageMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$UserStorageDatabase,
      $UserStorageMetadataTable,
      UserStorageMetadataData,
      $$UserStorageMetadataTableFilterComposer,
      $$UserStorageMetadataTableOrderingComposer,
      $$UserStorageMetadataTableAnnotationComposer,
      $$UserStorageMetadataTableCreateCompanionBuilder,
      $$UserStorageMetadataTableUpdateCompanionBuilder,
      (
        UserStorageMetadataData,
        BaseReferences<
          _$UserStorageDatabase,
          $UserStorageMetadataTable,
          UserStorageMetadataData
        >,
      ),
      UserStorageMetadataData,
      PrefetchHooks Function()
    >;
typedef $$UserMigrationCheckpointsTableCreateCompanionBuilder =
    UserMigrationCheckpointsCompanion Function({
      required int fromVersion,
      required int toVersion,
      required String description,
      required DateTime appliedAtUtc,
      Value<int> rowid,
    });
typedef $$UserMigrationCheckpointsTableUpdateCompanionBuilder =
    UserMigrationCheckpointsCompanion Function({
      Value<int> fromVersion,
      Value<int> toVersion,
      Value<String> description,
      Value<DateTime> appliedAtUtc,
      Value<int> rowid,
    });

class $$UserMigrationCheckpointsTableFilterComposer
    extends Composer<_$UserStorageDatabase, $UserMigrationCheckpointsTable> {
  $$UserMigrationCheckpointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get fromVersion => $composableBuilder(
    column: $table.fromVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toVersion => $composableBuilder(
    column: $table.toVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserMigrationCheckpointsTableOrderingComposer
    extends Composer<_$UserStorageDatabase, $UserMigrationCheckpointsTable> {
  $$UserMigrationCheckpointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get fromVersion => $composableBuilder(
    column: $table.fromVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toVersion => $composableBuilder(
    column: $table.toVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserMigrationCheckpointsTableAnnotationComposer
    extends Composer<_$UserStorageDatabase, $UserMigrationCheckpointsTable> {
  $$UserMigrationCheckpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get fromVersion => $composableBuilder(
    column: $table.fromVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toVersion =>
      $composableBuilder(column: $table.toVersion, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => column,
  );
}

class $$UserMigrationCheckpointsTableTableManager
    extends
        RootTableManager<
          _$UserStorageDatabase,
          $UserMigrationCheckpointsTable,
          UserMigrationCheckpoint,
          $$UserMigrationCheckpointsTableFilterComposer,
          $$UserMigrationCheckpointsTableOrderingComposer,
          $$UserMigrationCheckpointsTableAnnotationComposer,
          $$UserMigrationCheckpointsTableCreateCompanionBuilder,
          $$UserMigrationCheckpointsTableUpdateCompanionBuilder,
          (
            UserMigrationCheckpoint,
            BaseReferences<
              _$UserStorageDatabase,
              $UserMigrationCheckpointsTable,
              UserMigrationCheckpoint
            >,
          ),
          UserMigrationCheckpoint,
          PrefetchHooks Function()
        > {
  $$UserMigrationCheckpointsTableTableManager(
    _$UserStorageDatabase db,
    $UserMigrationCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMigrationCheckpointsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserMigrationCheckpointsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserMigrationCheckpointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> fromVersion = const Value.absent(),
                Value<int> toVersion = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> appliedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserMigrationCheckpointsCompanion(
                fromVersion: fromVersion,
                toVersion: toVersion,
                description: description,
                appliedAtUtc: appliedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int fromVersion,
                required int toVersion,
                required String description,
                required DateTime appliedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => UserMigrationCheckpointsCompanion.insert(
                fromVersion: fromVersion,
                toVersion: toVersion,
                description: description,
                appliedAtUtc: appliedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserMigrationCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserStorageDatabase,
      $UserMigrationCheckpointsTable,
      UserMigrationCheckpoint,
      $$UserMigrationCheckpointsTableFilterComposer,
      $$UserMigrationCheckpointsTableOrderingComposer,
      $$UserMigrationCheckpointsTableAnnotationComposer,
      $$UserMigrationCheckpointsTableCreateCompanionBuilder,
      $$UserMigrationCheckpointsTableUpdateCompanionBuilder,
      (
        UserMigrationCheckpoint,
        BaseReferences<
          _$UserStorageDatabase,
          $UserMigrationCheckpointsTable,
          UserMigrationCheckpoint
        >,
      ),
      UserMigrationCheckpoint,
      PrefetchHooks Function()
    >;

class $UserStorageDatabaseManager {
  final _$UserStorageDatabase _db;
  $UserStorageDatabaseManager(this._db);
  $$UserStorageMetadataTableTableManager get userStorageMetadata =>
      $$UserStorageMetadataTableTableManager(_db, _db.userStorageMetadata);
  $$UserMigrationCheckpointsTableTableManager get userMigrationCheckpoints =>
      $$UserMigrationCheckpointsTableTableManager(
        _db,
        _db.userMigrationCheckpoints,
      );
}

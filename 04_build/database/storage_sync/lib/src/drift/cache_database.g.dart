// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_database.dart';

// ignore_for_file: type=lint
class $CacheStorageMetadataTable extends CacheStorageMetadata
    with TableInfo<$CacheStorageMetadataTable, CacheStorageMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheStorageMetadataTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'cache_storage_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheStorageMetadataData> instance, {
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
  CacheStorageMetadataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheStorageMetadataData(
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
  $CacheStorageMetadataTable createAlias(String alias) {
    return $CacheStorageMetadataTable(attachedDatabase, alias);
  }
}

class CacheStorageMetadataData extends DataClass
    implements Insertable<CacheStorageMetadataData> {
  final String key;
  final String value;
  final DateTime? updatedAt;
  const CacheStorageMetadataData({
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

  CacheStorageMetadataCompanion toCompanion(bool nullToAbsent) {
    return CacheStorageMetadataCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheStorageMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheStorageMetadataData(
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

  CacheStorageMetadataData copyWith({
    String? key,
    String? value,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CacheStorageMetadataData(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheStorageMetadataData copyWithCompanion(
    CacheStorageMetadataCompanion data,
  ) {
    return CacheStorageMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheStorageMetadataData(')
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
      (other is CacheStorageMetadataData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class CacheStorageMetadataCompanion
    extends UpdateCompanion<CacheStorageMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CacheStorageMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheStorageMetadataCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<CacheStorageMetadataData> custom({
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

  CacheStorageMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheStorageMetadataCompanion(
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
    return (StringBuffer('CacheStorageMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheMigrationCheckpointsTable extends CacheMigrationCheckpoints
    with TableInfo<$CacheMigrationCheckpointsTable, CacheMigrationCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMigrationCheckpointsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'cache_migration_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMigrationCheckpoint> instance, {
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
  CacheMigrationCheckpoint map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMigrationCheckpoint(
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
  $CacheMigrationCheckpointsTable createAlias(String alias) {
    return $CacheMigrationCheckpointsTable(attachedDatabase, alias);
  }
}

class CacheMigrationCheckpoint extends DataClass
    implements Insertable<CacheMigrationCheckpoint> {
  final int fromVersion;
  final int toVersion;
  final String description;
  final DateTime appliedAtUtc;
  const CacheMigrationCheckpoint({
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

  CacheMigrationCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return CacheMigrationCheckpointsCompanion(
      fromVersion: Value(fromVersion),
      toVersion: Value(toVersion),
      description: Value(description),
      appliedAtUtc: Value(appliedAtUtc),
    );
  }

  factory CacheMigrationCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMigrationCheckpoint(
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

  CacheMigrationCheckpoint copyWith({
    int? fromVersion,
    int? toVersion,
    String? description,
    DateTime? appliedAtUtc,
  }) => CacheMigrationCheckpoint(
    fromVersion: fromVersion ?? this.fromVersion,
    toVersion: toVersion ?? this.toVersion,
    description: description ?? this.description,
    appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
  );
  CacheMigrationCheckpoint copyWithCompanion(
    CacheMigrationCheckpointsCompanion data,
  ) {
    return CacheMigrationCheckpoint(
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
    return (StringBuffer('CacheMigrationCheckpoint(')
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
      (other is CacheMigrationCheckpoint &&
          other.fromVersion == this.fromVersion &&
          other.toVersion == this.toVersion &&
          other.description == this.description &&
          other.appliedAtUtc == this.appliedAtUtc);
}

class CacheMigrationCheckpointsCompanion
    extends UpdateCompanion<CacheMigrationCheckpoint> {
  final Value<int> fromVersion;
  final Value<int> toVersion;
  final Value<String> description;
  final Value<DateTime> appliedAtUtc;
  final Value<int> rowid;
  const CacheMigrationCheckpointsCompanion({
    this.fromVersion = const Value.absent(),
    this.toVersion = const Value.absent(),
    this.description = const Value.absent(),
    this.appliedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMigrationCheckpointsCompanion.insert({
    required int fromVersion,
    required int toVersion,
    required String description,
    required DateTime appliedAtUtc,
    this.rowid = const Value.absent(),
  }) : fromVersion = Value(fromVersion),
       toVersion = Value(toVersion),
       description = Value(description),
       appliedAtUtc = Value(appliedAtUtc);
  static Insertable<CacheMigrationCheckpoint> custom({
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

  CacheMigrationCheckpointsCompanion copyWith({
    Value<int>? fromVersion,
    Value<int>? toVersion,
    Value<String>? description,
    Value<DateTime>? appliedAtUtc,
    Value<int>? rowid,
  }) {
    return CacheMigrationCheckpointsCompanion(
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
    return (StringBuffer('CacheMigrationCheckpointsCompanion(')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('description: $description, ')
          ..write('appliedAtUtc: $appliedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheEntriesTable extends CacheEntries
    with TableInfo<$CacheEntriesTable, CacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtUtcMeta = const VerificationMeta(
    'expiresAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAtUtc = GeneratedColumn<DateTime>(
    'expires_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    scope,
    payload,
    expiresAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('expires_at_utc')) {
      context.handle(
        _expiresAtUtcMeta,
        expiresAtUtc.isAcceptableOrUnknown(
          data['expires_at_utc']!,
          _expiresAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  CacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheEntry(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
      expiresAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at_utc'],
      ),
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $CacheEntriesTable createAlias(String alias) {
    return $CacheEntriesTable(attachedDatabase, alias);
  }
}

class CacheEntry extends DataClass implements Insertable<CacheEntry> {
  final String cacheKey;
  final String scope;
  final Uint8List payload;
  final DateTime? expiresAtUtc;
  final DateTime updatedAtUtc;
  const CacheEntry({
    required this.cacheKey,
    required this.scope,
    required this.payload,
    this.expiresAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['scope'] = Variable<String>(scope);
    map['payload'] = Variable<Uint8List>(payload);
    if (!nullToAbsent || expiresAtUtc != null) {
      map['expires_at_utc'] = Variable<DateTime>(expiresAtUtc);
    }
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  CacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return CacheEntriesCompanion(
      cacheKey: Value(cacheKey),
      scope: Value(scope),
      payload: Value(payload),
      expiresAtUtc: expiresAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory CacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheEntry(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      scope: serializer.fromJson<String>(json['scope']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
      expiresAtUtc: serializer.fromJson<DateTime?>(json['expiresAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'scope': serializer.toJson<String>(scope),
      'payload': serializer.toJson<Uint8List>(payload),
      'expiresAtUtc': serializer.toJson<DateTime?>(expiresAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  CacheEntry copyWith({
    String? cacheKey,
    String? scope,
    Uint8List? payload,
    Value<DateTime?> expiresAtUtc = const Value.absent(),
    DateTime? updatedAtUtc,
  }) => CacheEntry(
    cacheKey: cacheKey ?? this.cacheKey,
    scope: scope ?? this.scope,
    payload: payload ?? this.payload,
    expiresAtUtc: expiresAtUtc.present ? expiresAtUtc.value : this.expiresAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  CacheEntry copyWithCompanion(CacheEntriesCompanion data) {
    return CacheEntry(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      scope: data.scope.present ? data.scope.value : this.scope,
      payload: data.payload.present ? data.payload.value : this.payload,
      expiresAtUtc: data.expiresAtUtc.present
          ? data.expiresAtUtc.value
          : this.expiresAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntry(')
          ..write('cacheKey: $cacheKey, ')
          ..write('scope: $scope, ')
          ..write('payload: $payload, ')
          ..write('expiresAtUtc: $expiresAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cacheKey,
    scope,
    $driftBlobEquality.hash(payload),
    expiresAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheEntry &&
          other.cacheKey == this.cacheKey &&
          other.scope == this.scope &&
          $driftBlobEquality.equals(other.payload, this.payload) &&
          other.expiresAtUtc == this.expiresAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class CacheEntriesCompanion extends UpdateCompanion<CacheEntry> {
  final Value<String> cacheKey;
  final Value<String> scope;
  final Value<Uint8List> payload;
  final Value<DateTime?> expiresAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const CacheEntriesCompanion({
    this.cacheKey = const Value.absent(),
    this.scope = const Value.absent(),
    this.payload = const Value.absent(),
    this.expiresAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheEntriesCompanion.insert({
    required String cacheKey,
    required String scope,
    required Uint8List payload,
    this.expiresAtUtc = const Value.absent(),
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       scope = Value(scope),
       payload = Value(payload),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CacheEntry> custom({
    Expression<String>? cacheKey,
    Expression<String>? scope,
    Expression<Uint8List>? payload,
    Expression<DateTime>? expiresAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (scope != null) 'scope': scope,
      if (payload != null) 'payload': payload,
      if (expiresAtUtc != null) 'expires_at_utc': expiresAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheEntriesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? scope,
    Value<Uint8List>? payload,
    Value<DateTime?>? expiresAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return CacheEntriesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      scope: scope ?? this.scope,
      payload: payload ?? this.payload,
      expiresAtUtc: expiresAtUtc ?? this.expiresAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    if (expiresAtUtc.present) {
      map['expires_at_utc'] = Variable<DateTime>(expiresAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntriesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('scope: $scope, ')
          ..write('payload: $payload, ')
          ..write('expiresAtUtc: $expiresAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CacheStorageDatabase extends GeneratedDatabase {
  _$CacheStorageDatabase(QueryExecutor e) : super(e);
  $CacheStorageDatabaseManager get managers =>
      $CacheStorageDatabaseManager(this);
  late final $CacheStorageMetadataTable cacheStorageMetadata =
      $CacheStorageMetadataTable(this);
  late final $CacheMigrationCheckpointsTable cacheMigrationCheckpoints =
      $CacheMigrationCheckpointsTable(this);
  late final $CacheEntriesTable cacheEntries = $CacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cacheStorageMetadata,
    cacheMigrationCheckpoints,
    cacheEntries,
  ];
}

typedef $$CacheStorageMetadataTableCreateCompanionBuilder =
    CacheStorageMetadataCompanion Function({
      required String key,
      required String value,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheStorageMetadataTableUpdateCompanionBuilder =
    CacheStorageMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$CacheStorageMetadataTableFilterComposer
    extends Composer<_$CacheStorageDatabase, $CacheStorageMetadataTable> {
  $$CacheStorageMetadataTableFilterComposer({
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

class $$CacheStorageMetadataTableOrderingComposer
    extends Composer<_$CacheStorageDatabase, $CacheStorageMetadataTable> {
  $$CacheStorageMetadataTableOrderingComposer({
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

class $$CacheStorageMetadataTableAnnotationComposer
    extends Composer<_$CacheStorageDatabase, $CacheStorageMetadataTable> {
  $$CacheStorageMetadataTableAnnotationComposer({
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

class $$CacheStorageMetadataTableTableManager
    extends
        RootTableManager<
          _$CacheStorageDatabase,
          $CacheStorageMetadataTable,
          CacheStorageMetadataData,
          $$CacheStorageMetadataTableFilterComposer,
          $$CacheStorageMetadataTableOrderingComposer,
          $$CacheStorageMetadataTableAnnotationComposer,
          $$CacheStorageMetadataTableCreateCompanionBuilder,
          $$CacheStorageMetadataTableUpdateCompanionBuilder,
          (
            CacheStorageMetadataData,
            BaseReferences<
              _$CacheStorageDatabase,
              $CacheStorageMetadataTable,
              CacheStorageMetadataData
            >,
          ),
          CacheStorageMetadataData,
          PrefetchHooks Function()
        > {
  $$CacheStorageMetadataTableTableManager(
    _$CacheStorageDatabase db,
    $CacheStorageMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheStorageMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheStorageMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CacheStorageMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheStorageMetadataCompanion(
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
              }) => CacheStorageMetadataCompanion.insert(
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

typedef $$CacheStorageMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$CacheStorageDatabase,
      $CacheStorageMetadataTable,
      CacheStorageMetadataData,
      $$CacheStorageMetadataTableFilterComposer,
      $$CacheStorageMetadataTableOrderingComposer,
      $$CacheStorageMetadataTableAnnotationComposer,
      $$CacheStorageMetadataTableCreateCompanionBuilder,
      $$CacheStorageMetadataTableUpdateCompanionBuilder,
      (
        CacheStorageMetadataData,
        BaseReferences<
          _$CacheStorageDatabase,
          $CacheStorageMetadataTable,
          CacheStorageMetadataData
        >,
      ),
      CacheStorageMetadataData,
      PrefetchHooks Function()
    >;
typedef $$CacheMigrationCheckpointsTableCreateCompanionBuilder =
    CacheMigrationCheckpointsCompanion Function({
      required int fromVersion,
      required int toVersion,
      required String description,
      required DateTime appliedAtUtc,
      Value<int> rowid,
    });
typedef $$CacheMigrationCheckpointsTableUpdateCompanionBuilder =
    CacheMigrationCheckpointsCompanion Function({
      Value<int> fromVersion,
      Value<int> toVersion,
      Value<String> description,
      Value<DateTime> appliedAtUtc,
      Value<int> rowid,
    });

class $$CacheMigrationCheckpointsTableFilterComposer
    extends Composer<_$CacheStorageDatabase, $CacheMigrationCheckpointsTable> {
  $$CacheMigrationCheckpointsTableFilterComposer({
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

class $$CacheMigrationCheckpointsTableOrderingComposer
    extends Composer<_$CacheStorageDatabase, $CacheMigrationCheckpointsTable> {
  $$CacheMigrationCheckpointsTableOrderingComposer({
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

class $$CacheMigrationCheckpointsTableAnnotationComposer
    extends Composer<_$CacheStorageDatabase, $CacheMigrationCheckpointsTable> {
  $$CacheMigrationCheckpointsTableAnnotationComposer({
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

class $$CacheMigrationCheckpointsTableTableManager
    extends
        RootTableManager<
          _$CacheStorageDatabase,
          $CacheMigrationCheckpointsTable,
          CacheMigrationCheckpoint,
          $$CacheMigrationCheckpointsTableFilterComposer,
          $$CacheMigrationCheckpointsTableOrderingComposer,
          $$CacheMigrationCheckpointsTableAnnotationComposer,
          $$CacheMigrationCheckpointsTableCreateCompanionBuilder,
          $$CacheMigrationCheckpointsTableUpdateCompanionBuilder,
          (
            CacheMigrationCheckpoint,
            BaseReferences<
              _$CacheStorageDatabase,
              $CacheMigrationCheckpointsTable,
              CacheMigrationCheckpoint
            >,
          ),
          CacheMigrationCheckpoint,
          PrefetchHooks Function()
        > {
  $$CacheMigrationCheckpointsTableTableManager(
    _$CacheStorageDatabase db,
    $CacheMigrationCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMigrationCheckpointsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CacheMigrationCheckpointsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CacheMigrationCheckpointsTableAnnotationComposer(
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
              }) => CacheMigrationCheckpointsCompanion(
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
              }) => CacheMigrationCheckpointsCompanion.insert(
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

typedef $$CacheMigrationCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$CacheStorageDatabase,
      $CacheMigrationCheckpointsTable,
      CacheMigrationCheckpoint,
      $$CacheMigrationCheckpointsTableFilterComposer,
      $$CacheMigrationCheckpointsTableOrderingComposer,
      $$CacheMigrationCheckpointsTableAnnotationComposer,
      $$CacheMigrationCheckpointsTableCreateCompanionBuilder,
      $$CacheMigrationCheckpointsTableUpdateCompanionBuilder,
      (
        CacheMigrationCheckpoint,
        BaseReferences<
          _$CacheStorageDatabase,
          $CacheMigrationCheckpointsTable,
          CacheMigrationCheckpoint
        >,
      ),
      CacheMigrationCheckpoint,
      PrefetchHooks Function()
    >;
typedef $$CacheEntriesTableCreateCompanionBuilder =
    CacheEntriesCompanion Function({
      required String cacheKey,
      required String scope,
      required Uint8List payload,
      Value<DateTime?> expiresAtUtc,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$CacheEntriesTableUpdateCompanionBuilder =
    CacheEntriesCompanion Function({
      Value<String> cacheKey,
      Value<String> scope,
      Value<Uint8List> payload,
      Value<DateTime?> expiresAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

class $$CacheEntriesTableFilterComposer
    extends Composer<_$CacheStorageDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAtUtc => $composableBuilder(
    column: $table.expiresAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheEntriesTableOrderingComposer
    extends Composer<_$CacheStorageDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAtUtc => $composableBuilder(
    column: $table.expiresAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheEntriesTableAnnotationComposer
    extends Composer<_$CacheStorageDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAtUtc => $composableBuilder(
    column: $table.expiresAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$CacheEntriesTableTableManager
    extends
        RootTableManager<
          _$CacheStorageDatabase,
          $CacheEntriesTable,
          CacheEntry,
          $$CacheEntriesTableFilterComposer,
          $$CacheEntriesTableOrderingComposer,
          $$CacheEntriesTableAnnotationComposer,
          $$CacheEntriesTableCreateCompanionBuilder,
          $$CacheEntriesTableUpdateCompanionBuilder,
          (
            CacheEntry,
            BaseReferences<
              _$CacheStorageDatabase,
              $CacheEntriesTable,
              CacheEntry
            >,
          ),
          CacheEntry,
          PrefetchHooks Function()
        > {
  $$CacheEntriesTableTableManager(
    _$CacheStorageDatabase db,
    $CacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
                Value<DateTime?> expiresAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion(
                cacheKey: cacheKey,
                scope: scope,
                payload: payload,
                expiresAtUtc: expiresAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String scope,
                required Uint8List payload,
                Value<DateTime?> expiresAtUtc = const Value.absent(),
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion.insert(
                cacheKey: cacheKey,
                scope: scope,
                payload: payload,
                expiresAtUtc: expiresAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CacheStorageDatabase,
      $CacheEntriesTable,
      CacheEntry,
      $$CacheEntriesTableFilterComposer,
      $$CacheEntriesTableOrderingComposer,
      $$CacheEntriesTableAnnotationComposer,
      $$CacheEntriesTableCreateCompanionBuilder,
      $$CacheEntriesTableUpdateCompanionBuilder,
      (
        CacheEntry,
        BaseReferences<_$CacheStorageDatabase, $CacheEntriesTable, CacheEntry>,
      ),
      CacheEntry,
      PrefetchHooks Function()
    >;

class $CacheStorageDatabaseManager {
  final _$CacheStorageDatabase _db;
  $CacheStorageDatabaseManager(this._db);
  $$CacheStorageMetadataTableTableManager get cacheStorageMetadata =>
      $$CacheStorageMetadataTableTableManager(_db, _db.cacheStorageMetadata);
  $$CacheMigrationCheckpointsTableTableManager get cacheMigrationCheckpoints =>
      $$CacheMigrationCheckpointsTableTableManager(
        _db,
        _db.cacheMigrationCheckpoints,
      );
  $$CacheEntriesTableTableManager get cacheEntries =>
      $$CacheEntriesTableTableManager(_db, _db.cacheEntries);
}

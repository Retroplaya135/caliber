// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corpus_database.dart';

// ignore_for_file: type=lint
class $CorpusStorageMetadataTable extends CorpusStorageMetadata
    with TableInfo<$CorpusStorageMetadataTable, CorpusStorageMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorpusStorageMetadataTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'corpus_storage_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<CorpusStorageMetadataData> instance, {
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
  CorpusStorageMetadataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CorpusStorageMetadataData(
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
  $CorpusStorageMetadataTable createAlias(String alias) {
    return $CorpusStorageMetadataTable(attachedDatabase, alias);
  }
}

class CorpusStorageMetadataData extends DataClass
    implements Insertable<CorpusStorageMetadataData> {
  final String key;
  final String value;
  final DateTime? updatedAt;
  const CorpusStorageMetadataData({
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

  CorpusStorageMetadataCompanion toCompanion(bool nullToAbsent) {
    return CorpusStorageMetadataCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CorpusStorageMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CorpusStorageMetadataData(
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

  CorpusStorageMetadataData copyWith({
    String? key,
    String? value,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CorpusStorageMetadataData(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CorpusStorageMetadataData copyWithCompanion(
    CorpusStorageMetadataCompanion data,
  ) {
    return CorpusStorageMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CorpusStorageMetadataData(')
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
      (other is CorpusStorageMetadataData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class CorpusStorageMetadataCompanion
    extends UpdateCompanion<CorpusStorageMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CorpusStorageMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CorpusStorageMetadataCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<CorpusStorageMetadataData> custom({
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

  CorpusStorageMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CorpusStorageMetadataCompanion(
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
    return (StringBuffer('CorpusStorageMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CorpusMigrationCheckpointsTable extends CorpusMigrationCheckpoints
    with
        TableInfo<$CorpusMigrationCheckpointsTable, CorpusMigrationCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorpusMigrationCheckpointsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'corpus_migration_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<CorpusMigrationCheckpoint> instance, {
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
  CorpusMigrationCheckpoint map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CorpusMigrationCheckpoint(
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
  $CorpusMigrationCheckpointsTable createAlias(String alias) {
    return $CorpusMigrationCheckpointsTable(attachedDatabase, alias);
  }
}

class CorpusMigrationCheckpoint extends DataClass
    implements Insertable<CorpusMigrationCheckpoint> {
  final int fromVersion;
  final int toVersion;
  final String description;
  final DateTime appliedAtUtc;
  const CorpusMigrationCheckpoint({
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

  CorpusMigrationCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return CorpusMigrationCheckpointsCompanion(
      fromVersion: Value(fromVersion),
      toVersion: Value(toVersion),
      description: Value(description),
      appliedAtUtc: Value(appliedAtUtc),
    );
  }

  factory CorpusMigrationCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CorpusMigrationCheckpoint(
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

  CorpusMigrationCheckpoint copyWith({
    int? fromVersion,
    int? toVersion,
    String? description,
    DateTime? appliedAtUtc,
  }) => CorpusMigrationCheckpoint(
    fromVersion: fromVersion ?? this.fromVersion,
    toVersion: toVersion ?? this.toVersion,
    description: description ?? this.description,
    appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
  );
  CorpusMigrationCheckpoint copyWithCompanion(
    CorpusMigrationCheckpointsCompanion data,
  ) {
    return CorpusMigrationCheckpoint(
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
    return (StringBuffer('CorpusMigrationCheckpoint(')
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
      (other is CorpusMigrationCheckpoint &&
          other.fromVersion == this.fromVersion &&
          other.toVersion == this.toVersion &&
          other.description == this.description &&
          other.appliedAtUtc == this.appliedAtUtc);
}

class CorpusMigrationCheckpointsCompanion
    extends UpdateCompanion<CorpusMigrationCheckpoint> {
  final Value<int> fromVersion;
  final Value<int> toVersion;
  final Value<String> description;
  final Value<DateTime> appliedAtUtc;
  final Value<int> rowid;
  const CorpusMigrationCheckpointsCompanion({
    this.fromVersion = const Value.absent(),
    this.toVersion = const Value.absent(),
    this.description = const Value.absent(),
    this.appliedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CorpusMigrationCheckpointsCompanion.insert({
    required int fromVersion,
    required int toVersion,
    required String description,
    required DateTime appliedAtUtc,
    this.rowid = const Value.absent(),
  }) : fromVersion = Value(fromVersion),
       toVersion = Value(toVersion),
       description = Value(description),
       appliedAtUtc = Value(appliedAtUtc);
  static Insertable<CorpusMigrationCheckpoint> custom({
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

  CorpusMigrationCheckpointsCompanion copyWith({
    Value<int>? fromVersion,
    Value<int>? toVersion,
    Value<String>? description,
    Value<DateTime>? appliedAtUtc,
    Value<int>? rowid,
  }) {
    return CorpusMigrationCheckpointsCompanion(
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
    return (StringBuffer('CorpusMigrationCheckpointsCompanion(')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('description: $description, ')
          ..write('appliedAtUtc: $appliedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CorpusBundlesTable extends CorpusBundles
    with TableInfo<$CorpusBundlesTable, CorpusBundle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorpusBundlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _corpusBundleVersionMeta =
      const VerificationMeta('corpusBundleVersion');
  @override
  late final GeneratedColumn<int> corpusBundleVersion = GeneratedColumn<int>(
    'corpus_bundle_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bundleIdMeta = const VerificationMeta(
    'bundleId',
  );
  @override
  late final GeneratedColumn<String> bundleId = GeneratedColumn<String>(
    'bundle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadSha256Meta = const VerificationMeta(
    'payloadSha256',
  );
  @override
  late final GeneratedColumn<String> payloadSha256 = GeneratedColumn<String>(
    'payload_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadSizeBytesMeta = const VerificationMeta(
    'payloadSizeBytes',
  );
  @override
  late final GeneratedColumn<int> payloadSizeBytes = GeneratedColumn<int>(
    'payload_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<Uint8List> signature = GeneratedColumn<Uint8List>(
    'signature',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<Uint8List> publicKey = GeneratedColumn<Uint8List>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manifestJsonMeta = const VerificationMeta(
    'manifestJson',
  );
  @override
  late final GeneratedColumn<String> manifestJson = GeneratedColumn<String>(
    'manifest_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtUtcMeta = const VerificationMeta(
    'publishedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAtUtc =
      GeneratedColumn<DateTime>(
        'published_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _adoptedAtUtcMeta = const VerificationMeta(
    'adoptedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> adoptedAtUtc = GeneratedColumn<DateTime>(
    'adopted_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    corpusBundleVersion,
    bundleId,
    payloadSha256,
    payloadSizeBytes,
    payload,
    signature,
    publicKey,
    manifestJson,
    publishedAtUtc,
    adoptedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'corpus_bundles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CorpusBundle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('corpus_bundle_version')) {
      context.handle(
        _corpusBundleVersionMeta,
        corpusBundleVersion.isAcceptableOrUnknown(
          data['corpus_bundle_version']!,
          _corpusBundleVersionMeta,
        ),
      );
    }
    if (data.containsKey('bundle_id')) {
      context.handle(
        _bundleIdMeta,
        bundleId.isAcceptableOrUnknown(data['bundle_id']!, _bundleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bundleIdMeta);
    }
    if (data.containsKey('payload_sha256')) {
      context.handle(
        _payloadSha256Meta,
        payloadSha256.isAcceptableOrUnknown(
          data['payload_sha256']!,
          _payloadSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadSha256Meta);
    }
    if (data.containsKey('payload_size_bytes')) {
      context.handle(
        _payloadSizeBytesMeta,
        payloadSizeBytes.isAcceptableOrUnknown(
          data['payload_size_bytes']!,
          _payloadSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadSizeBytesMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('manifest_json')) {
      context.handle(
        _manifestJsonMeta,
        manifestJson.isAcceptableOrUnknown(
          data['manifest_json']!,
          _manifestJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manifestJsonMeta);
    }
    if (data.containsKey('published_at_utc')) {
      context.handle(
        _publishedAtUtcMeta,
        publishedAtUtc.isAcceptableOrUnknown(
          data['published_at_utc']!,
          _publishedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtUtcMeta);
    }
    if (data.containsKey('adopted_at_utc')) {
      context.handle(
        _adoptedAtUtcMeta,
        adoptedAtUtc.isAcceptableOrUnknown(
          data['adopted_at_utc']!,
          _adoptedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_adoptedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {corpusBundleVersion};
  @override
  CorpusBundle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CorpusBundle(
      corpusBundleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corpus_bundle_version'],
      )!,
      bundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_id'],
      )!,
      payloadSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_sha256'],
      )!,
      payloadSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_size_bytes'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}public_key'],
      )!,
      manifestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_json'],
      )!,
      publishedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at_utc'],
      )!,
      adoptedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}adopted_at_utc'],
      )!,
    );
  }

  @override
  $CorpusBundlesTable createAlias(String alias) {
    return $CorpusBundlesTable(attachedDatabase, alias);
  }
}

class CorpusBundle extends DataClass implements Insertable<CorpusBundle> {
  final int corpusBundleVersion;
  final String bundleId;
  final String payloadSha256;
  final int payloadSizeBytes;
  final Uint8List payload;
  final Uint8List signature;
  final Uint8List publicKey;
  final String manifestJson;
  final DateTime publishedAtUtc;
  final DateTime adoptedAtUtc;
  const CorpusBundle({
    required this.corpusBundleVersion,
    required this.bundleId,
    required this.payloadSha256,
    required this.payloadSizeBytes,
    required this.payload,
    required this.signature,
    required this.publicKey,
    required this.manifestJson,
    required this.publishedAtUtc,
    required this.adoptedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['corpus_bundle_version'] = Variable<int>(corpusBundleVersion);
    map['bundle_id'] = Variable<String>(bundleId);
    map['payload_sha256'] = Variable<String>(payloadSha256);
    map['payload_size_bytes'] = Variable<int>(payloadSizeBytes);
    map['payload'] = Variable<Uint8List>(payload);
    map['signature'] = Variable<Uint8List>(signature);
    map['public_key'] = Variable<Uint8List>(publicKey);
    map['manifest_json'] = Variable<String>(manifestJson);
    map['published_at_utc'] = Variable<DateTime>(publishedAtUtc);
    map['adopted_at_utc'] = Variable<DateTime>(adoptedAtUtc);
    return map;
  }

  CorpusBundlesCompanion toCompanion(bool nullToAbsent) {
    return CorpusBundlesCompanion(
      corpusBundleVersion: Value(corpusBundleVersion),
      bundleId: Value(bundleId),
      payloadSha256: Value(payloadSha256),
      payloadSizeBytes: Value(payloadSizeBytes),
      payload: Value(payload),
      signature: Value(signature),
      publicKey: Value(publicKey),
      manifestJson: Value(manifestJson),
      publishedAtUtc: Value(publishedAtUtc),
      adoptedAtUtc: Value(adoptedAtUtc),
    );
  }

  factory CorpusBundle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CorpusBundle(
      corpusBundleVersion: serializer.fromJson<int>(
        json['corpusBundleVersion'],
      ),
      bundleId: serializer.fromJson<String>(json['bundleId']),
      payloadSha256: serializer.fromJson<String>(json['payloadSha256']),
      payloadSizeBytes: serializer.fromJson<int>(json['payloadSizeBytes']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
      signature: serializer.fromJson<Uint8List>(json['signature']),
      publicKey: serializer.fromJson<Uint8List>(json['publicKey']),
      manifestJson: serializer.fromJson<String>(json['manifestJson']),
      publishedAtUtc: serializer.fromJson<DateTime>(json['publishedAtUtc']),
      adoptedAtUtc: serializer.fromJson<DateTime>(json['adoptedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'corpusBundleVersion': serializer.toJson<int>(corpusBundleVersion),
      'bundleId': serializer.toJson<String>(bundleId),
      'payloadSha256': serializer.toJson<String>(payloadSha256),
      'payloadSizeBytes': serializer.toJson<int>(payloadSizeBytes),
      'payload': serializer.toJson<Uint8List>(payload),
      'signature': serializer.toJson<Uint8List>(signature),
      'publicKey': serializer.toJson<Uint8List>(publicKey),
      'manifestJson': serializer.toJson<String>(manifestJson),
      'publishedAtUtc': serializer.toJson<DateTime>(publishedAtUtc),
      'adoptedAtUtc': serializer.toJson<DateTime>(adoptedAtUtc),
    };
  }

  CorpusBundle copyWith({
    int? corpusBundleVersion,
    String? bundleId,
    String? payloadSha256,
    int? payloadSizeBytes,
    Uint8List? payload,
    Uint8List? signature,
    Uint8List? publicKey,
    String? manifestJson,
    DateTime? publishedAtUtc,
    DateTime? adoptedAtUtc,
  }) => CorpusBundle(
    corpusBundleVersion: corpusBundleVersion ?? this.corpusBundleVersion,
    bundleId: bundleId ?? this.bundleId,
    payloadSha256: payloadSha256 ?? this.payloadSha256,
    payloadSizeBytes: payloadSizeBytes ?? this.payloadSizeBytes,
    payload: payload ?? this.payload,
    signature: signature ?? this.signature,
    publicKey: publicKey ?? this.publicKey,
    manifestJson: manifestJson ?? this.manifestJson,
    publishedAtUtc: publishedAtUtc ?? this.publishedAtUtc,
    adoptedAtUtc: adoptedAtUtc ?? this.adoptedAtUtc,
  );
  CorpusBundle copyWithCompanion(CorpusBundlesCompanion data) {
    return CorpusBundle(
      corpusBundleVersion: data.corpusBundleVersion.present
          ? data.corpusBundleVersion.value
          : this.corpusBundleVersion,
      bundleId: data.bundleId.present ? data.bundleId.value : this.bundleId,
      payloadSha256: data.payloadSha256.present
          ? data.payloadSha256.value
          : this.payloadSha256,
      payloadSizeBytes: data.payloadSizeBytes.present
          ? data.payloadSizeBytes.value
          : this.payloadSizeBytes,
      payload: data.payload.present ? data.payload.value : this.payload,
      signature: data.signature.present ? data.signature.value : this.signature,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      manifestJson: data.manifestJson.present
          ? data.manifestJson.value
          : this.manifestJson,
      publishedAtUtc: data.publishedAtUtc.present
          ? data.publishedAtUtc.value
          : this.publishedAtUtc,
      adoptedAtUtc: data.adoptedAtUtc.present
          ? data.adoptedAtUtc.value
          : this.adoptedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CorpusBundle(')
          ..write('corpusBundleVersion: $corpusBundleVersion, ')
          ..write('bundleId: $bundleId, ')
          ..write('payloadSha256: $payloadSha256, ')
          ..write('payloadSizeBytes: $payloadSizeBytes, ')
          ..write('payload: $payload, ')
          ..write('signature: $signature, ')
          ..write('publicKey: $publicKey, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('publishedAtUtc: $publishedAtUtc, ')
          ..write('adoptedAtUtc: $adoptedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    corpusBundleVersion,
    bundleId,
    payloadSha256,
    payloadSizeBytes,
    $driftBlobEquality.hash(payload),
    $driftBlobEquality.hash(signature),
    $driftBlobEquality.hash(publicKey),
    manifestJson,
    publishedAtUtc,
    adoptedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CorpusBundle &&
          other.corpusBundleVersion == this.corpusBundleVersion &&
          other.bundleId == this.bundleId &&
          other.payloadSha256 == this.payloadSha256 &&
          other.payloadSizeBytes == this.payloadSizeBytes &&
          $driftBlobEquality.equals(other.payload, this.payload) &&
          $driftBlobEquality.equals(other.signature, this.signature) &&
          $driftBlobEquality.equals(other.publicKey, this.publicKey) &&
          other.manifestJson == this.manifestJson &&
          other.publishedAtUtc == this.publishedAtUtc &&
          other.adoptedAtUtc == this.adoptedAtUtc);
}

class CorpusBundlesCompanion extends UpdateCompanion<CorpusBundle> {
  final Value<int> corpusBundleVersion;
  final Value<String> bundleId;
  final Value<String> payloadSha256;
  final Value<int> payloadSizeBytes;
  final Value<Uint8List> payload;
  final Value<Uint8List> signature;
  final Value<Uint8List> publicKey;
  final Value<String> manifestJson;
  final Value<DateTime> publishedAtUtc;
  final Value<DateTime> adoptedAtUtc;
  const CorpusBundlesCompanion({
    this.corpusBundleVersion = const Value.absent(),
    this.bundleId = const Value.absent(),
    this.payloadSha256 = const Value.absent(),
    this.payloadSizeBytes = const Value.absent(),
    this.payload = const Value.absent(),
    this.signature = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.publishedAtUtc = const Value.absent(),
    this.adoptedAtUtc = const Value.absent(),
  });
  CorpusBundlesCompanion.insert({
    this.corpusBundleVersion = const Value.absent(),
    required String bundleId,
    required String payloadSha256,
    required int payloadSizeBytes,
    required Uint8List payload,
    required Uint8List signature,
    required Uint8List publicKey,
    required String manifestJson,
    required DateTime publishedAtUtc,
    required DateTime adoptedAtUtc,
  }) : bundleId = Value(bundleId),
       payloadSha256 = Value(payloadSha256),
       payloadSizeBytes = Value(payloadSizeBytes),
       payload = Value(payload),
       signature = Value(signature),
       publicKey = Value(publicKey),
       manifestJson = Value(manifestJson),
       publishedAtUtc = Value(publishedAtUtc),
       adoptedAtUtc = Value(adoptedAtUtc);
  static Insertable<CorpusBundle> custom({
    Expression<int>? corpusBundleVersion,
    Expression<String>? bundleId,
    Expression<String>? payloadSha256,
    Expression<int>? payloadSizeBytes,
    Expression<Uint8List>? payload,
    Expression<Uint8List>? signature,
    Expression<Uint8List>? publicKey,
    Expression<String>? manifestJson,
    Expression<DateTime>? publishedAtUtc,
    Expression<DateTime>? adoptedAtUtc,
  }) {
    return RawValuesInsertable({
      if (corpusBundleVersion != null)
        'corpus_bundle_version': corpusBundleVersion,
      if (bundleId != null) 'bundle_id': bundleId,
      if (payloadSha256 != null) 'payload_sha256': payloadSha256,
      if (payloadSizeBytes != null) 'payload_size_bytes': payloadSizeBytes,
      if (payload != null) 'payload': payload,
      if (signature != null) 'signature': signature,
      if (publicKey != null) 'public_key': publicKey,
      if (manifestJson != null) 'manifest_json': manifestJson,
      if (publishedAtUtc != null) 'published_at_utc': publishedAtUtc,
      if (adoptedAtUtc != null) 'adopted_at_utc': adoptedAtUtc,
    });
  }

  CorpusBundlesCompanion copyWith({
    Value<int>? corpusBundleVersion,
    Value<String>? bundleId,
    Value<String>? payloadSha256,
    Value<int>? payloadSizeBytes,
    Value<Uint8List>? payload,
    Value<Uint8List>? signature,
    Value<Uint8List>? publicKey,
    Value<String>? manifestJson,
    Value<DateTime>? publishedAtUtc,
    Value<DateTime>? adoptedAtUtc,
  }) {
    return CorpusBundlesCompanion(
      corpusBundleVersion: corpusBundleVersion ?? this.corpusBundleVersion,
      bundleId: bundleId ?? this.bundleId,
      payloadSha256: payloadSha256 ?? this.payloadSha256,
      payloadSizeBytes: payloadSizeBytes ?? this.payloadSizeBytes,
      payload: payload ?? this.payload,
      signature: signature ?? this.signature,
      publicKey: publicKey ?? this.publicKey,
      manifestJson: manifestJson ?? this.manifestJson,
      publishedAtUtc: publishedAtUtc ?? this.publishedAtUtc,
      adoptedAtUtc: adoptedAtUtc ?? this.adoptedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (corpusBundleVersion.present) {
      map['corpus_bundle_version'] = Variable<int>(corpusBundleVersion.value);
    }
    if (bundleId.present) {
      map['bundle_id'] = Variable<String>(bundleId.value);
    }
    if (payloadSha256.present) {
      map['payload_sha256'] = Variable<String>(payloadSha256.value);
    }
    if (payloadSizeBytes.present) {
      map['payload_size_bytes'] = Variable<int>(payloadSizeBytes.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    if (signature.present) {
      map['signature'] = Variable<Uint8List>(signature.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<Uint8List>(publicKey.value);
    }
    if (manifestJson.present) {
      map['manifest_json'] = Variable<String>(manifestJson.value);
    }
    if (publishedAtUtc.present) {
      map['published_at_utc'] = Variable<DateTime>(publishedAtUtc.value);
    }
    if (adoptedAtUtc.present) {
      map['adopted_at_utc'] = Variable<DateTime>(adoptedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CorpusBundlesCompanion(')
          ..write('corpusBundleVersion: $corpusBundleVersion, ')
          ..write('bundleId: $bundleId, ')
          ..write('payloadSha256: $payloadSha256, ')
          ..write('payloadSizeBytes: $payloadSizeBytes, ')
          ..write('payload: $payload, ')
          ..write('signature: $signature, ')
          ..write('publicKey: $publicKey, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('publishedAtUtc: $publishedAtUtc, ')
          ..write('adoptedAtUtc: $adoptedAtUtc')
          ..write(')'))
        .toString();
  }
}

abstract class _$CorpusStorageDatabase extends GeneratedDatabase {
  _$CorpusStorageDatabase(QueryExecutor e) : super(e);
  $CorpusStorageDatabaseManager get managers =>
      $CorpusStorageDatabaseManager(this);
  late final $CorpusStorageMetadataTable corpusStorageMetadata =
      $CorpusStorageMetadataTable(this);
  late final $CorpusMigrationCheckpointsTable corpusMigrationCheckpoints =
      $CorpusMigrationCheckpointsTable(this);
  late final $CorpusBundlesTable corpusBundles = $CorpusBundlesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    corpusStorageMetadata,
    corpusMigrationCheckpoints,
    corpusBundles,
  ];
}

typedef $$CorpusStorageMetadataTableCreateCompanionBuilder =
    CorpusStorageMetadataCompanion Function({
      required String key,
      required String value,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CorpusStorageMetadataTableUpdateCompanionBuilder =
    CorpusStorageMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$CorpusStorageMetadataTableFilterComposer
    extends Composer<_$CorpusStorageDatabase, $CorpusStorageMetadataTable> {
  $$CorpusStorageMetadataTableFilterComposer({
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

class $$CorpusStorageMetadataTableOrderingComposer
    extends Composer<_$CorpusStorageDatabase, $CorpusStorageMetadataTable> {
  $$CorpusStorageMetadataTableOrderingComposer({
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

class $$CorpusStorageMetadataTableAnnotationComposer
    extends Composer<_$CorpusStorageDatabase, $CorpusStorageMetadataTable> {
  $$CorpusStorageMetadataTableAnnotationComposer({
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

class $$CorpusStorageMetadataTableTableManager
    extends
        RootTableManager<
          _$CorpusStorageDatabase,
          $CorpusStorageMetadataTable,
          CorpusStorageMetadataData,
          $$CorpusStorageMetadataTableFilterComposer,
          $$CorpusStorageMetadataTableOrderingComposer,
          $$CorpusStorageMetadataTableAnnotationComposer,
          $$CorpusStorageMetadataTableCreateCompanionBuilder,
          $$CorpusStorageMetadataTableUpdateCompanionBuilder,
          (
            CorpusStorageMetadataData,
            BaseReferences<
              _$CorpusStorageDatabase,
              $CorpusStorageMetadataTable,
              CorpusStorageMetadataData
            >,
          ),
          CorpusStorageMetadataData,
          PrefetchHooks Function()
        > {
  $$CorpusStorageMetadataTableTableManager(
    _$CorpusStorageDatabase db,
    $CorpusStorageMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorpusStorageMetadataTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CorpusStorageMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CorpusStorageMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CorpusStorageMetadataCompanion(
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
              }) => CorpusStorageMetadataCompanion.insert(
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

typedef $$CorpusStorageMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$CorpusStorageDatabase,
      $CorpusStorageMetadataTable,
      CorpusStorageMetadataData,
      $$CorpusStorageMetadataTableFilterComposer,
      $$CorpusStorageMetadataTableOrderingComposer,
      $$CorpusStorageMetadataTableAnnotationComposer,
      $$CorpusStorageMetadataTableCreateCompanionBuilder,
      $$CorpusStorageMetadataTableUpdateCompanionBuilder,
      (
        CorpusStorageMetadataData,
        BaseReferences<
          _$CorpusStorageDatabase,
          $CorpusStorageMetadataTable,
          CorpusStorageMetadataData
        >,
      ),
      CorpusStorageMetadataData,
      PrefetchHooks Function()
    >;
typedef $$CorpusMigrationCheckpointsTableCreateCompanionBuilder =
    CorpusMigrationCheckpointsCompanion Function({
      required int fromVersion,
      required int toVersion,
      required String description,
      required DateTime appliedAtUtc,
      Value<int> rowid,
    });
typedef $$CorpusMigrationCheckpointsTableUpdateCompanionBuilder =
    CorpusMigrationCheckpointsCompanion Function({
      Value<int> fromVersion,
      Value<int> toVersion,
      Value<String> description,
      Value<DateTime> appliedAtUtc,
      Value<int> rowid,
    });

class $$CorpusMigrationCheckpointsTableFilterComposer
    extends
        Composer<_$CorpusStorageDatabase, $CorpusMigrationCheckpointsTable> {
  $$CorpusMigrationCheckpointsTableFilterComposer({
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

class $$CorpusMigrationCheckpointsTableOrderingComposer
    extends
        Composer<_$CorpusStorageDatabase, $CorpusMigrationCheckpointsTable> {
  $$CorpusMigrationCheckpointsTableOrderingComposer({
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

class $$CorpusMigrationCheckpointsTableAnnotationComposer
    extends
        Composer<_$CorpusStorageDatabase, $CorpusMigrationCheckpointsTable> {
  $$CorpusMigrationCheckpointsTableAnnotationComposer({
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

class $$CorpusMigrationCheckpointsTableTableManager
    extends
        RootTableManager<
          _$CorpusStorageDatabase,
          $CorpusMigrationCheckpointsTable,
          CorpusMigrationCheckpoint,
          $$CorpusMigrationCheckpointsTableFilterComposer,
          $$CorpusMigrationCheckpointsTableOrderingComposer,
          $$CorpusMigrationCheckpointsTableAnnotationComposer,
          $$CorpusMigrationCheckpointsTableCreateCompanionBuilder,
          $$CorpusMigrationCheckpointsTableUpdateCompanionBuilder,
          (
            CorpusMigrationCheckpoint,
            BaseReferences<
              _$CorpusStorageDatabase,
              $CorpusMigrationCheckpointsTable,
              CorpusMigrationCheckpoint
            >,
          ),
          CorpusMigrationCheckpoint,
          PrefetchHooks Function()
        > {
  $$CorpusMigrationCheckpointsTableTableManager(
    _$CorpusStorageDatabase db,
    $CorpusMigrationCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorpusMigrationCheckpointsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CorpusMigrationCheckpointsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CorpusMigrationCheckpointsTableAnnotationComposer(
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
              }) => CorpusMigrationCheckpointsCompanion(
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
              }) => CorpusMigrationCheckpointsCompanion.insert(
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

typedef $$CorpusMigrationCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$CorpusStorageDatabase,
      $CorpusMigrationCheckpointsTable,
      CorpusMigrationCheckpoint,
      $$CorpusMigrationCheckpointsTableFilterComposer,
      $$CorpusMigrationCheckpointsTableOrderingComposer,
      $$CorpusMigrationCheckpointsTableAnnotationComposer,
      $$CorpusMigrationCheckpointsTableCreateCompanionBuilder,
      $$CorpusMigrationCheckpointsTableUpdateCompanionBuilder,
      (
        CorpusMigrationCheckpoint,
        BaseReferences<
          _$CorpusStorageDatabase,
          $CorpusMigrationCheckpointsTable,
          CorpusMigrationCheckpoint
        >,
      ),
      CorpusMigrationCheckpoint,
      PrefetchHooks Function()
    >;
typedef $$CorpusBundlesTableCreateCompanionBuilder =
    CorpusBundlesCompanion Function({
      Value<int> corpusBundleVersion,
      required String bundleId,
      required String payloadSha256,
      required int payloadSizeBytes,
      required Uint8List payload,
      required Uint8List signature,
      required Uint8List publicKey,
      required String manifestJson,
      required DateTime publishedAtUtc,
      required DateTime adoptedAtUtc,
    });
typedef $$CorpusBundlesTableUpdateCompanionBuilder =
    CorpusBundlesCompanion Function({
      Value<int> corpusBundleVersion,
      Value<String> bundleId,
      Value<String> payloadSha256,
      Value<int> payloadSizeBytes,
      Value<Uint8List> payload,
      Value<Uint8List> signature,
      Value<Uint8List> publicKey,
      Value<String> manifestJson,
      Value<DateTime> publishedAtUtc,
      Value<DateTime> adoptedAtUtc,
    });

class $$CorpusBundlesTableFilterComposer
    extends Composer<_$CorpusStorageDatabase, $CorpusBundlesTable> {
  $$CorpusBundlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get corpusBundleVersion => $composableBuilder(
    column: $table.corpusBundleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadSizeBytes => $composableBuilder(
    column: $table.payloadSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAtUtc => $composableBuilder(
    column: $table.publishedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get adoptedAtUtc => $composableBuilder(
    column: $table.adoptedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CorpusBundlesTableOrderingComposer
    extends Composer<_$CorpusStorageDatabase, $CorpusBundlesTable> {
  $$CorpusBundlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get corpusBundleVersion => $composableBuilder(
    column: $table.corpusBundleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadSizeBytes => $composableBuilder(
    column: $table.payloadSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAtUtc => $composableBuilder(
    column: $table.publishedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get adoptedAtUtc => $composableBuilder(
    column: $table.adoptedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CorpusBundlesTableAnnotationComposer
    extends Composer<_$CorpusStorageDatabase, $CorpusBundlesTable> {
  $$CorpusBundlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get corpusBundleVersion => $composableBuilder(
    column: $table.corpusBundleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bundleId =>
      $composableBuilder(column: $table.bundleId, builder: (column) => column);

  GeneratedColumn<String> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadSizeBytes => $composableBuilder(
    column: $table.payloadSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<Uint8List> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAtUtc => $composableBuilder(
    column: $table.publishedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get adoptedAtUtc => $composableBuilder(
    column: $table.adoptedAtUtc,
    builder: (column) => column,
  );
}

class $$CorpusBundlesTableTableManager
    extends
        RootTableManager<
          _$CorpusStorageDatabase,
          $CorpusBundlesTable,
          CorpusBundle,
          $$CorpusBundlesTableFilterComposer,
          $$CorpusBundlesTableOrderingComposer,
          $$CorpusBundlesTableAnnotationComposer,
          $$CorpusBundlesTableCreateCompanionBuilder,
          $$CorpusBundlesTableUpdateCompanionBuilder,
          (
            CorpusBundle,
            BaseReferences<
              _$CorpusStorageDatabase,
              $CorpusBundlesTable,
              CorpusBundle
            >,
          ),
          CorpusBundle,
          PrefetchHooks Function()
        > {
  $$CorpusBundlesTableTableManager(
    _$CorpusStorageDatabase db,
    $CorpusBundlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorpusBundlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CorpusBundlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CorpusBundlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> corpusBundleVersion = const Value.absent(),
                Value<String> bundleId = const Value.absent(),
                Value<String> payloadSha256 = const Value.absent(),
                Value<int> payloadSizeBytes = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
                Value<Uint8List> signature = const Value.absent(),
                Value<Uint8List> publicKey = const Value.absent(),
                Value<String> manifestJson = const Value.absent(),
                Value<DateTime> publishedAtUtc = const Value.absent(),
                Value<DateTime> adoptedAtUtc = const Value.absent(),
              }) => CorpusBundlesCompanion(
                corpusBundleVersion: corpusBundleVersion,
                bundleId: bundleId,
                payloadSha256: payloadSha256,
                payloadSizeBytes: payloadSizeBytes,
                payload: payload,
                signature: signature,
                publicKey: publicKey,
                manifestJson: manifestJson,
                publishedAtUtc: publishedAtUtc,
                adoptedAtUtc: adoptedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> corpusBundleVersion = const Value.absent(),
                required String bundleId,
                required String payloadSha256,
                required int payloadSizeBytes,
                required Uint8List payload,
                required Uint8List signature,
                required Uint8List publicKey,
                required String manifestJson,
                required DateTime publishedAtUtc,
                required DateTime adoptedAtUtc,
              }) => CorpusBundlesCompanion.insert(
                corpusBundleVersion: corpusBundleVersion,
                bundleId: bundleId,
                payloadSha256: payloadSha256,
                payloadSizeBytes: payloadSizeBytes,
                payload: payload,
                signature: signature,
                publicKey: publicKey,
                manifestJson: manifestJson,
                publishedAtUtc: publishedAtUtc,
                adoptedAtUtc: adoptedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CorpusBundlesTableProcessedTableManager =
    ProcessedTableManager<
      _$CorpusStorageDatabase,
      $CorpusBundlesTable,
      CorpusBundle,
      $$CorpusBundlesTableFilterComposer,
      $$CorpusBundlesTableOrderingComposer,
      $$CorpusBundlesTableAnnotationComposer,
      $$CorpusBundlesTableCreateCompanionBuilder,
      $$CorpusBundlesTableUpdateCompanionBuilder,
      (
        CorpusBundle,
        BaseReferences<
          _$CorpusStorageDatabase,
          $CorpusBundlesTable,
          CorpusBundle
        >,
      ),
      CorpusBundle,
      PrefetchHooks Function()
    >;

class $CorpusStorageDatabaseManager {
  final _$CorpusStorageDatabase _db;
  $CorpusStorageDatabaseManager(this._db);
  $$CorpusStorageMetadataTableTableManager get corpusStorageMetadata =>
      $$CorpusStorageMetadataTableTableManager(_db, _db.corpusStorageMetadata);
  $$CorpusMigrationCheckpointsTableTableManager
  get corpusMigrationCheckpoints =>
      $$CorpusMigrationCheckpointsTableTableManager(
        _db,
        _db.corpusMigrationCheckpoints,
      );
  $$CorpusBundlesTableTableManager get corpusBundles =>
      $$CorpusBundlesTableTableManager(_db, _db.corpusBundles);
}

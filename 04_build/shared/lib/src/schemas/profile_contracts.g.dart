// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileIdentity _$ProfileIdentityFromJson(Map<String, dynamic> json) =>
    _ProfileIdentity(
      schemaVersion:
          json['schema_version'] as String? ?? kProfileIdentitySchemaVersion,
      profileId: json['profile_id'] as String,
      ownerUserId: json['owner_user_id'] as String,
      displayName: json['display_name'] as String,
      primaryDomain: json['primary_domain'] as String,
      targetLevelBand: json['target_level_band'] as String,
      locale: json['locale'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, Object?>{},
    );

Map<String, dynamic> _$ProfileIdentityToJson(_ProfileIdentity instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'profile_id': instance.profileId,
      'owner_user_id': instance.ownerUserId,
      'display_name': instance.displayName,
      'primary_domain': instance.primaryDomain,
      'target_level_band': instance.targetLevelBand,
      'locale': instance.locale,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

_TargetMatrixCell _$TargetMatrixCellFromJson(
  Map<String, dynamic> json,
) => _TargetMatrixCell(
  schemaVersion:
      json['schema_version'] as String? ?? kTargetMatrixCellSchemaVersion,
  cellId: json['cell_id'] as String,
  profileId: json['profile_id'] as String,
  target: TargetRoleCompany.fromJson(json['target'] as Map<String, dynamic>),
  skillAxis: json['skill_axis'] as String,
  evidenceAtomIds:
      (json['evidence_atom_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  readinessScore: (json['readiness_score'] as num).toDouble(),
  gapScore: (json['gap_score'] as num).toDouble(),
  priority: (json['priority'] as num).toInt(),
  sourceVersion: json['source_version'] as String,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, Object?>{},
);

Map<String, dynamic> _$TargetMatrixCellToJson(_TargetMatrixCell instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'cell_id': instance.cellId,
      'profile_id': instance.profileId,
      'target': instance.target.toJson(),
      'skill_axis': instance.skillAxis,
      'evidence_atom_ids': instance.evidenceAtomIds,
      'readiness_score': instance.readinessScore,
      'gap_score': instance.gapScore,
      'priority': instance.priority,
      'source_version': instance.sourceVersion,
      'metadata': instance.metadata,
    };

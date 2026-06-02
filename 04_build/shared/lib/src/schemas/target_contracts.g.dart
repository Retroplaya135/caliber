// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TargetRoleCompany _$TargetRoleCompanyFromJson(Map<String, dynamic> json) =>
    _TargetRoleCompany(
      schemaVersion:
          json['schema_version'] as String? ?? kTargetRoleCompanySchemaVersion,
      roleId: json['role_id'] as String,
      domain: json['domain'] as String,
      levelBand: json['level_band'] as String,
      companyArchetype: json['company_archetype'] as String,
      title: json['title'] as String?,
      market: json['market'] as String?,
      seniorityOrder: (json['seniority_order'] as num?)?.toInt(),
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, Object?>{},
    );

Map<String, dynamic> _$TargetRoleCompanyToJson(_TargetRoleCompany instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'role_id': instance.roleId,
      'domain': instance.domain,
      'level_band': instance.levelBand,
      'company_archetype': instance.companyArchetype,
      'title': instance.title,
      'market': instance.market,
      'seniority_order': instance.seniorityOrder,
      'metadata': instance.metadata,
    };

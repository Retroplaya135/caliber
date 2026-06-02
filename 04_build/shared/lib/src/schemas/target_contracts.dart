import 'package:freezed_annotation/freezed_annotation.dart';

import '../schema_versions.dart';

part 'target_contracts.freezed.dart';
part 'target_contracts.g.dart';

@freezed
abstract class TargetRoleCompany with _$TargetRoleCompany {
  @JsonSerializable(explicitToJson: true)
  const factory TargetRoleCompany({
    @JsonKey(name: 'schema_version')
    @Default(kTargetRoleCompanySchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'role_id') required String roleId,
    required String domain,
    @JsonKey(name: 'level_band') required String levelBand,
    @JsonKey(name: 'company_archetype') required String companyArchetype,
    String? title,
    String? market,
    @JsonKey(name: 'seniority_order') int? seniorityOrder,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _TargetRoleCompany;

  factory TargetRoleCompany.fromJson(Map<String, Object?> json) =>
      _$TargetRoleCompanyFromJson(json);
}

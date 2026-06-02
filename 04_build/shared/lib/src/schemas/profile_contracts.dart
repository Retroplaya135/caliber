import 'package:freezed_annotation/freezed_annotation.dart';

import '../schema_versions.dart';
import 'target_contracts.dart';

part 'profile_contracts.freezed.dart';
part 'profile_contracts.g.dart';

@freezed
abstract class ProfileIdentity with _$ProfileIdentity {
  @JsonSerializable(explicitToJson: true)
  const factory ProfileIdentity({
    @JsonKey(name: 'schema_version')
    @Default(kProfileIdentitySchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'profile_id') required String profileId,
    @JsonKey(name: 'owner_user_id') required String ownerUserId,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'primary_domain') required String primaryDomain,
    @JsonKey(name: 'target_level_band') required String targetLevelBand,
    required String locale,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _ProfileIdentity;

  factory ProfileIdentity.fromJson(Map<String, Object?> json) =>
      _$ProfileIdentityFromJson(json);
}

@freezed
abstract class TargetMatrixCell with _$TargetMatrixCell {
  @Assert(
    'readinessScore >= 0 && readinessScore <= 1',
    'readinessScore must be between 0 and 1',
  )
  @Assert(
    'gapScore >= 0 && gapScore <= 1',
    'gapScore must be between 0 and 1',
  )
  @JsonSerializable(explicitToJson: true)
  const factory TargetMatrixCell({
    @JsonKey(name: 'schema_version')
    @Default(kTargetMatrixCellSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'cell_id') required String cellId,
    @JsonKey(name: 'profile_id') required String profileId,
    @JsonKey(name: 'target') required TargetRoleCompany target,
    @JsonKey(name: 'skill_axis') required String skillAxis,
    @JsonKey(name: 'evidence_atom_ids')
    @Default(<String>[])
    List<String> evidenceAtomIds,
    @JsonKey(name: 'readiness_score') required double readinessScore,
    @JsonKey(name: 'gap_score') required double gapScore,
    required int priority,
    @JsonKey(name: 'source_version') required String sourceVersion,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _TargetMatrixCell;

  factory TargetMatrixCell.fromJson(Map<String, Object?> json) =>
      _$TargetMatrixCellFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../schema_versions.dart';
import 'ai_output_contracts.dart';
import 'common_contracts.dart';

part 'document_contracts.freezed.dart';
part 'document_contracts.g.dart';

@freezed
abstract class EvidenceAtom with _$EvidenceAtom {
  @Assert(
    'confidence >= 0 && confidence <= 1',
    'confidence must be between 0 and 1',
  )
  @Assert('evidenceSpans.isNotEmpty', 'evidenceSpans must not be empty')
  @JsonSerializable(explicitToJson: true)
  factory EvidenceAtom({
    @JsonKey(name: 'schema_version')
    @Default(kEvidenceAtomSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'atom_id') required String atomId,
    @JsonKey(name: 'profile_id') required String profileId,
    @JsonKey(name: 'source_id') required String sourceId,
    @JsonKey(name: 'source_type') required String sourceType,
    required String text,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'captured_at') required DateTime capturedAt,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
    required double confidence,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _EvidenceAtom;

  factory EvidenceAtom.fromJson(Map<String, Object?> json) =>
      _$EvidenceAtomFromJson(json);
}

@freezed
abstract class RenderContract with _$RenderContract {
  @JsonSerializable(explicitToJson: true)
  const factory RenderContract({
    @JsonKey(name: 'schema_version')
    @Default(kRenderContractSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'renderer_id') required String rendererId,
    @JsonKey(name: 'renderer_version') required String rendererVersion,
    @JsonKey(name: 'template_id') required String templateId,
    @JsonKey(name: 'template_version') required String templateVersion,
    @JsonKey(name: 'page_size') required String pageSize,
    @JsonKey(name: 'margin_profile') required String marginProfile,
    @JsonKey(name: 'allowed_formats')
    @Default(<String>[])
    List<String> allowedFormats,
    @JsonKey(name: 'layout_policy_version') required String layoutPolicyVersion,
  }) = _RenderContract;

  factory RenderContract.fromJson(Map<String, Object?> json) =>
      _$RenderContractFromJson(json);
}

@freezed
abstract class ResumeSection with _$ResumeSection {
  @JsonSerializable(explicitToJson: true)
  const factory ResumeSection({
    @JsonKey(name: 'schema_version')
    @Default(kResumeSectionSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'section_id') required String sectionId,
    @JsonKey(name: 'section_type') required String sectionType,
    required String heading,
    required int order,
    @Default(<ResumeBullet>[]) List<ResumeBullet> bullets,
    @JsonKey(name: 'evidence_atom_ids')
    @Default(<String>[])
    List<String> evidenceAtomIds,
  }) = _ResumeSection;

  factory ResumeSection.fromJson(Map<String, Object?> json) =>
      _$ResumeSectionFromJson(json);
}

@freezed
abstract class ResumeDocument with _$ResumeDocument {
  @JsonSerializable(explicitToJson: true)
  const factory ResumeDocument({
    @JsonKey(name: 'schema_version')
    @Default(kResumeDocumentSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'document_id') required String documentId,
    @JsonKey(name: 'profile_id') required String profileId,
    required String title,
    @JsonKey(name: 'template_id') required String templateId,
    @JsonKey(name: 'template_version') required String templateVersion,
    @JsonKey(name: 'render_contract') required RenderContract renderContract,
    required List<ResumeSection> sections,
    @JsonKey(name: 'evidence_atoms') required List<EvidenceAtom> evidenceAtoms,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ResumeDocument;

  factory ResumeDocument.fromJson(Map<String, Object?> json) =>
      _$ResumeDocumentFromJson(json);
}

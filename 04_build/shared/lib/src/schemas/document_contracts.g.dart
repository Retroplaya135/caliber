// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvidenceAtom _$EvidenceAtomFromJson(Map<String, dynamic> json) =>
    _EvidenceAtom(
      schemaVersion:
          json['schema_version'] as String? ?? kEvidenceAtomSchemaVersion,
      atomId: json['atom_id'] as String,
      profileId: json['profile_id'] as String,
      sourceId: json['source_id'] as String,
      sourceType: json['source_type'] as String,
      text: json['text'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      capturedAt: DateTime.parse(json['captured_at'] as String),
      evidenceSpans: (json['evidence_spans'] as List<dynamic>)
          .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, Object?>{},
    );

Map<String, dynamic> _$EvidenceAtomToJson(_EvidenceAtom instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'atom_id': instance.atomId,
      'profile_id': instance.profileId,
      'source_id': instance.sourceId,
      'source_type': instance.sourceType,
      'text': instance.text,
      'tags': instance.tags,
      'captured_at': instance.capturedAt.toIso8601String(),
      'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
      'confidence': instance.confidence,
      'metadata': instance.metadata,
    };

_RenderContract _$RenderContractFromJson(Map<String, dynamic> json) =>
    _RenderContract(
      schemaVersion:
          json['schema_version'] as String? ?? kRenderContractSchemaVersion,
      rendererId: json['renderer_id'] as String,
      rendererVersion: json['renderer_version'] as String,
      templateId: json['template_id'] as String,
      templateVersion: json['template_version'] as String,
      pageSize: json['page_size'] as String,
      marginProfile: json['margin_profile'] as String,
      allowedFormats:
          (json['allowed_formats'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      layoutPolicyVersion: json['layout_policy_version'] as String,
    );

Map<String, dynamic> _$RenderContractToJson(_RenderContract instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'renderer_id': instance.rendererId,
      'renderer_version': instance.rendererVersion,
      'template_id': instance.templateId,
      'template_version': instance.templateVersion,
      'page_size': instance.pageSize,
      'margin_profile': instance.marginProfile,
      'allowed_formats': instance.allowedFormats,
      'layout_policy_version': instance.layoutPolicyVersion,
    };

_ResumeSection _$ResumeSectionFromJson(Map<String, dynamic> json) =>
    _ResumeSection(
      schemaVersion:
          json['schema_version'] as String? ?? kResumeSectionSchemaVersion,
      sectionId: json['section_id'] as String,
      sectionType: json['section_type'] as String,
      heading: json['heading'] as String,
      order: (json['order'] as num).toInt(),
      bullets:
          (json['bullets'] as List<dynamic>?)
              ?.map((e) => ResumeBullet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ResumeBullet>[],
      evidenceAtomIds:
          (json['evidence_atom_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$ResumeSectionToJson(_ResumeSection instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'section_id': instance.sectionId,
      'section_type': instance.sectionType,
      'heading': instance.heading,
      'order': instance.order,
      'bullets': instance.bullets.map((e) => e.toJson()).toList(),
      'evidence_atom_ids': instance.evidenceAtomIds,
    };

_ResumeDocument _$ResumeDocumentFromJson(Map<String, dynamic> json) =>
    _ResumeDocument(
      schemaVersion:
          json['schema_version'] as String? ?? kResumeDocumentSchemaVersion,
      documentId: json['document_id'] as String,
      profileId: json['profile_id'] as String,
      title: json['title'] as String,
      templateId: json['template_id'] as String,
      templateVersion: json['template_version'] as String,
      renderContract: RenderContract.fromJson(
        json['render_contract'] as Map<String, dynamic>,
      ),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ResumeSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      evidenceAtoms: (json['evidence_atoms'] as List<dynamic>)
          .map((e) => EvidenceAtom.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ResumeDocumentToJson(_ResumeDocument instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'document_id': instance.documentId,
      'profile_id': instance.profileId,
      'title': instance.title,
      'template_id': instance.templateId,
      'template_version': instance.templateVersion,
      'render_contract': instance.renderContract.toJson(),
      'sections': instance.sections.map((e) => e.toJson()).toList(),
      'evidence_atoms': instance.evidenceAtoms.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

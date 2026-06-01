// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_output_contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InterviewContentJudgment _$InterviewContentJudgmentFromJson(
  Map<String, dynamic> json,
) => _InterviewContentJudgment(
  schemaVersion:
      json['schema_version'] as String? ??
      kInterviewContentJudgmentSchemaVersion,
  judgmentId: json['judgment_id'] as String,
  profileId: json['profile_id'] as String,
  target: TargetRoleCompany.fromJson(json['target'] as Map<String, dynamic>),
  questionId: json['question_id'] as String,
  answerTranscriptId: json['answer_transcript_id'] as String,
  rubricVersion: json['rubric_version'] as String,
  promptVersion: json['prompt_version'] as String,
  modelId: json['model_id'] as String,
  levelBand: json['level_band'] as String,
  strengths:
      (json['strengths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  risks:
      (json['risks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  recommendedActions:
      (json['recommended_actions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  evidenceSpans: (json['evidence_spans'] as List<dynamic>)
      .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InterviewContentJudgmentToJson(
  _InterviewContentJudgment instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'judgment_id': instance.judgmentId,
  'profile_id': instance.profileId,
  'target': instance.target.toJson(),
  'question_id': instance.questionId,
  'answer_transcript_id': instance.answerTranscriptId,
  'rubric_version': instance.rubricVersion,
  'prompt_version': instance.promptVersion,
  'model_id': instance.modelId,
  'level_band': instance.levelBand,
  'strengths': instance.strengths,
  'risks': instance.risks,
  'recommended_actions': instance.recommendedActions,
  'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt.toIso8601String(),
};

_ResumeBullet _$ResumeBulletFromJson(Map<String, dynamic> json) =>
    _ResumeBullet(
      schemaVersion:
          json['schema_version'] as String? ?? kResumeBulletSchemaVersion,
      bulletId: json['bullet_id'] as String,
      documentId: json['document_id'] as String,
      text: json['text'] as String,
      evidenceAtomIds: (json['evidence_atom_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      evidenceSpans: (json['evidence_spans'] as List<dynamic>)
          .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewritePolicyVersion: json['rewrite_policy_version'] as String,
      promptVersion: json['prompt_version'] as String,
      modelId: json['model_id'] as String,
      sourceBulletId: json['source_bullet_id'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$ResumeBulletToJson(_ResumeBullet instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'bullet_id': instance.bulletId,
      'document_id': instance.documentId,
      'text': instance.text,
      'evidence_atom_ids': instance.evidenceAtomIds,
      'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
      'rewrite_policy_version': instance.rewritePolicyVersion,
      'prompt_version': instance.promptVersion,
      'model_id': instance.modelId,
      'source_bullet_id': instance.sourceBulletId,
      'confidence': instance.confidence,
    };

_ATSExtractableField _$ATSExtractableFieldFromJson(Map<String, dynamic> json) =>
    _ATSExtractableField(
      schemaVersion:
          json['schema_version'] as String? ??
          kAtsExtractableFieldSchemaVersion,
      fieldKey: json['field_key'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      evidenceSpans: (json['evidence_spans'] as List<dynamic>)
          .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ATSExtractableFieldToJson(
  _ATSExtractableField instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'field_key': instance.fieldKey,
  'label': instance.label,
  'value': instance.value,
  'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
};

_ATSCoverageGap _$ATSCoverageGapFromJson(Map<String, dynamic> json) =>
    _ATSCoverageGap(
      schemaVersion:
          json['schema_version'] as String? ?? kAtsCoverageGapSchemaVersion,
      gapId: json['gap_id'] as String,
      keyword: json['keyword'] as String,
      reason: json['reason'] as String,
      severity: json['severity'] as String,
      evidenceSpans: (json['evidence_spans'] as List<dynamic>)
          .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ATSCoverageGapToJson(_ATSCoverageGap instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'gap_id': instance.gapId,
      'keyword': instance.keyword,
      'reason': instance.reason,
      'severity': instance.severity,
      'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
    };

_ATSReportV2 _$ATSReportV2FromJson(Map<String, dynamic> json) => _ATSReportV2(
  schemaVersion: json['schema_version'] as String? ?? kAtsReportV2SchemaVersion,
  reportId: json['report_id'] as String,
  documentId: json['document_id'] as String,
  target: TargetRoleCompany.fromJson(json['target'] as Map<String, dynamic>),
  atsTestMatrixVersion: json['ats_test_matrix_version'] as String,
  keywordMatchVersion: json['keyword_match_version'] as String,
  extractableFields: (json['extractable_fields'] as List<dynamic>)
      .map((e) => ATSExtractableField.fromJson(e as Map<String, dynamic>))
      .toList(),
  matchedKeywords:
      (json['matched_keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  coverageGaps: (json['coverage_gaps'] as List<dynamic>)
      .map((e) => ATSCoverageGap.fromJson(e as Map<String, dynamic>))
      .toList(),
  reasoning: json['reasoning'] as String,
  evidenceSpans: (json['evidence_spans'] as List<dynamic>)
      .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ATSReportV2ToJson(_ATSReportV2 instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'report_id': instance.reportId,
      'document_id': instance.documentId,
      'target': instance.target.toJson(),
      'ats_test_matrix_version': instance.atsTestMatrixVersion,
      'keyword_match_version': instance.keywordMatchVersion,
      'extractable_fields': instance.extractableFields
          .map((e) => e.toJson())
          .toList(),
      'matched_keywords': instance.matchedKeywords,
      'coverage_gaps': instance.coverageGaps.map((e) => e.toJson()).toList(),
      'reasoning': instance.reasoning,
      'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
    };

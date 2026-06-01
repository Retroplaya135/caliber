import 'package:freezed_annotation/freezed_annotation.dart';

import '../schema_versions.dart';
import 'common_contracts.dart';
import 'target_contracts.dart';

part 'ai_output_contracts.freezed.dart';
part 'ai_output_contracts.g.dart';

@freezed
abstract class InterviewContentJudgment with _$InterviewContentJudgment {
  @Assert('evidenceSpans.isNotEmpty', 'evidenceSpans must not be empty')
  @JsonSerializable(explicitToJson: true)
  factory InterviewContentJudgment({
    @JsonKey(name: 'schema_version')
    @Default(kInterviewContentJudgmentSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'judgment_id') required String judgmentId,
    @JsonKey(name: 'profile_id') required String profileId,
    required TargetRoleCompany target,
    @JsonKey(name: 'question_id') required String questionId,
    @JsonKey(name: 'answer_transcript_id') required String answerTranscriptId,
    @JsonKey(name: 'rubric_version') required String rubricVersion,
    @JsonKey(name: 'prompt_version') required String promptVersion,
    @JsonKey(name: 'model_id') required String modelId,
    @JsonKey(name: 'level_band') required String levelBand,
    @Default(<String>[]) List<String> strengths,
    @Default(<String>[]) List<String> risks,
    @JsonKey(name: 'recommended_actions')
    @Default(<String>[])
    List<String> recommendedActions,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InterviewContentJudgment;

  factory InterviewContentJudgment.fromJson(Map<String, Object?> json) =>
      _$InterviewContentJudgmentFromJson(json);
}

@freezed
abstract class ResumeBullet with _$ResumeBullet {
  @Assert(
    'confidence >= 0 && confidence <= 1',
    'confidence must be between 0 and 1',
  )
  @Assert('evidenceSpans.isNotEmpty', 'evidenceSpans must not be empty')
  @Assert('evidenceAtomIds.isNotEmpty', 'evidenceAtomIds must not be empty')
  @JsonSerializable(explicitToJson: true)
  factory ResumeBullet({
    @JsonKey(name: 'schema_version')
    @Default(kResumeBulletSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'bullet_id') required String bulletId,
    @JsonKey(name: 'document_id') required String documentId,
    required String text,
    @JsonKey(name: 'evidence_atom_ids') required List<String> evidenceAtomIds,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
    @JsonKey(name: 'rewrite_policy_version')
    required String rewritePolicyVersion,
    @JsonKey(name: 'prompt_version') required String promptVersion,
    @JsonKey(name: 'model_id') required String modelId,
    @JsonKey(name: 'source_bullet_id') String? sourceBulletId,
    required double confidence,
  }) = _ResumeBullet;

  factory ResumeBullet.fromJson(Map<String, Object?> json) =>
      _$ResumeBulletFromJson(json);
}

@freezed
abstract class ATSExtractableField with _$ATSExtractableField {
  @Assert('evidenceSpans.isNotEmpty', 'evidenceSpans must not be empty')
  @JsonSerializable(explicitToJson: true)
  factory ATSExtractableField({
    @JsonKey(name: 'schema_version')
    @Default(kAtsExtractableFieldSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'field_key') required String fieldKey,
    required String label,
    required String value,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
  }) = _ATSExtractableField;

  factory ATSExtractableField.fromJson(Map<String, Object?> json) =>
      _$ATSExtractableFieldFromJson(json);
}

@freezed
abstract class ATSCoverageGap with _$ATSCoverageGap {
  @Assert('evidenceSpans.isNotEmpty', 'evidenceSpans must not be empty')
  @JsonSerializable(explicitToJson: true)
  factory ATSCoverageGap({
    @JsonKey(name: 'schema_version')
    @Default(kAtsCoverageGapSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'gap_id') required String gapId,
    required String keyword,
    required String reason,
    required String severity,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
  }) = _ATSCoverageGap;

  factory ATSCoverageGap.fromJson(Map<String, Object?> json) =>
      _$ATSCoverageGapFromJson(json);
}

@freezed
abstract class ATSReportV2 with _$ATSReportV2 {
  @Assert('extractableFields.isNotEmpty', 'extractableFields must not be empty')
  @Assert('coverageGaps.isNotEmpty', 'coverageGaps must not be empty')
  @Assert('evidenceSpans.isNotEmpty', 'evidenceSpans must not be empty')
  @JsonSerializable(explicitToJson: true)
  factory ATSReportV2({
    @JsonKey(name: 'schema_version')
    @Default(kAtsReportV2SchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'report_id') required String reportId,
    @JsonKey(name: 'document_id') required String documentId,
    required TargetRoleCompany target,
    @JsonKey(name: 'ats_test_matrix_version')
    required String atsTestMatrixVersion,
    @JsonKey(name: 'keyword_match_version') required String keywordMatchVersion,
    @JsonKey(name: 'extractable_fields')
    required List<ATSExtractableField> extractableFields,
    @JsonKey(name: 'matched_keywords')
    @Default(<String>[])
    List<String> matchedKeywords,
    @JsonKey(name: 'coverage_gaps') required List<ATSCoverageGap> coverageGaps,
    required String reasoning,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ATSReportV2;

  factory ATSReportV2.fromJson(Map<String, Object?> json) =>
      _$ATSReportV2FromJson(json);
}

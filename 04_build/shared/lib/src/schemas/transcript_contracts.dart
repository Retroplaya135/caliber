import 'package:freezed_annotation/freezed_annotation.dart';

import '../schema_versions.dart';
import 'common_contracts.dart';

part 'transcript_contracts.freezed.dart';
part 'transcript_contracts.g.dart';

@freezed
abstract class TranscriptSegment with _$TranscriptSegment {
  @Assert('startMs >= 0', 'startMs must be non-negative')
  @Assert('endMs >= startMs', 'endMs must be >= startMs')
  @Assert(
    'confidence == null || (confidence >= 0 && confidence <= 1)',
    'confidence must be null or between 0 and 1',
  )
  @JsonSerializable(explicitToJson: true)
  const factory TranscriptSegment({
    @JsonKey(name: 'schema_version')
    @Default(kTranscriptSegmentSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'segment_id') required String segmentId,
    @JsonKey(name: 'speaker_label') required String speakerLabel,
    @JsonKey(name: 'start_ms') required int startMs,
    @JsonKey(name: 'end_ms') required int endMs,
    required String text,
    double? confidence,
    @JsonKey(name: 'word_ids') @Default(<String>[]) List<String> wordIds,
    @JsonKey(name: 'evidence_spans')
    @Default(<EvidenceSpan>[])
    List<EvidenceSpan> evidenceSpans,
  }) = _TranscriptSegment;

  factory TranscriptSegment.fromJson(Map<String, Object?> json) =>
      _$TranscriptSegmentFromJson(json);
}

@freezed
abstract class TranscriptWord with _$TranscriptWord {
  @Assert('startMs >= 0', 'startMs must be non-negative')
  @Assert('endMs >= startMs', 'endMs must be >= startMs')
  @Assert(
    'confidence == null || (confidence >= 0 && confidence <= 1)',
    'confidence must be null or between 0 and 1',
  )
  @JsonSerializable(explicitToJson: true)
  const factory TranscriptWord({
    @JsonKey(name: 'schema_version')
    @Default(kTranscriptWordSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'word_id') required String wordId,
    @JsonKey(name: 'segment_id') required String segmentId,
    required String text,
    @JsonKey(name: 'start_ms') required int startMs,
    @JsonKey(name: 'end_ms') required int endMs,
    double? confidence,
  }) = _TranscriptWord;

  factory TranscriptWord.fromJson(Map<String, Object?> json) =>
      _$TranscriptWordFromJson(json);
}

@freezed
abstract class GlossaryHit with _$GlossaryHit {
  @Assert(
    'confidence == null || (confidence >= 0 && confidence <= 1)',
    'confidence must be null or between 0 and 1',
  )
  @JsonSerializable(explicitToJson: true)
  const factory GlossaryHit({
    @JsonKey(name: 'schema_version')
    @Default(kGlossaryHitSchemaVersion)
    String schemaVersion,
    required String term,
    @JsonKey(name: 'normalized_term') required String normalizedTerm,
    @JsonKey(name: 'word_ids') @Default(<String>[]) List<String> wordIds,
    double? confidence,
    String? source,
  }) = _GlossaryHit;

  factory GlossaryHit.fromJson(Map<String, Object?> json) =>
      _$GlossaryHitFromJson(json);
}

@freezed
abstract class Transcript with _$Transcript {
  @Assert('durationMs >= 0', 'durationMs must be non-negative')
  @JsonSerializable(explicitToJson: true)
  const factory Transcript({
    @JsonKey(name: 'schema_version')
    @Default(kTranscriptSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'transcript_id') required String transcriptId,
    required List<TranscriptSegment> segments,
    required List<TranscriptWord> words,
    @JsonKey(name: 'engine_id') required String engineId,
    @JsonKey(name: 'engine_version') required String engineVersion,
    @JsonKey(name: 'glossary_hits') required List<GlossaryHit> glossaryHits,
    @JsonKey(name: 'transcript_policy_version')
    required String transcriptPolicyVersion,
    required String locale,
    @JsonKey(name: 'recorded_at') required DateTime recordedAt,
    @JsonKey(name: 'source_uri') required String sourceUri,
    @JsonKey(name: 'duration_ms') required int durationMs,
  }) = _Transcript;

  factory Transcript.fromJson(Map<String, Object?> json) =>
      _$TranscriptFromJson(json);
}

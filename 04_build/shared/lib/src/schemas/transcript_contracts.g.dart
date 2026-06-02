// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranscriptSegment _$TranscriptSegmentFromJson(Map<String, dynamic> json) =>
    _TranscriptSegment(
      schemaVersion:
          json['schema_version'] as String? ?? kTranscriptSegmentSchemaVersion,
      segmentId: json['segment_id'] as String,
      speakerLabel: json['speaker_label'] as String,
      startMs: (json['start_ms'] as num).toInt(),
      endMs: (json['end_ms'] as num).toInt(),
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
      wordIds:
          (json['word_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      evidenceSpans:
          (json['evidence_spans'] as List<dynamic>?)
              ?.map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EvidenceSpan>[],
    );

Map<String, dynamic> _$TranscriptSegmentToJson(_TranscriptSegment instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'segment_id': instance.segmentId,
      'speaker_label': instance.speakerLabel,
      'start_ms': instance.startMs,
      'end_ms': instance.endMs,
      'text': instance.text,
      'confidence': instance.confidence,
      'word_ids': instance.wordIds,
      'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
    };

_TranscriptWord _$TranscriptWordFromJson(Map<String, dynamic> json) =>
    _TranscriptWord(
      schemaVersion:
          json['schema_version'] as String? ?? kTranscriptWordSchemaVersion,
      wordId: json['word_id'] as String,
      segmentId: json['segment_id'] as String,
      text: json['text'] as String,
      startMs: (json['start_ms'] as num).toInt(),
      endMs: (json['end_ms'] as num).toInt(),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TranscriptWordToJson(_TranscriptWord instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'word_id': instance.wordId,
      'segment_id': instance.segmentId,
      'text': instance.text,
      'start_ms': instance.startMs,
      'end_ms': instance.endMs,
      'confidence': instance.confidence,
    };

_GlossaryHit _$GlossaryHitFromJson(Map<String, dynamic> json) => _GlossaryHit(
  schemaVersion: json['schema_version'] as String? ?? kGlossaryHitSchemaVersion,
  term: json['term'] as String,
  normalizedTerm: json['normalized_term'] as String,
  wordIds:
      (json['word_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  confidence: (json['confidence'] as num?)?.toDouble(),
  source: json['source'] as String?,
);

Map<String, dynamic> _$GlossaryHitToJson(_GlossaryHit instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'term': instance.term,
      'normalized_term': instance.normalizedTerm,
      'word_ids': instance.wordIds,
      'confidence': instance.confidence,
      'source': instance.source,
    };

_Transcript _$TranscriptFromJson(Map<String, dynamic> json) => _Transcript(
  schemaVersion: json['schema_version'] as String? ?? kTranscriptSchemaVersion,
  transcriptId: json['transcript_id'] as String,
  segments: (json['segments'] as List<dynamic>)
      .map((e) => TranscriptSegment.fromJson(e as Map<String, dynamic>))
      .toList(),
  words: (json['words'] as List<dynamic>)
      .map((e) => TranscriptWord.fromJson(e as Map<String, dynamic>))
      .toList(),
  engineId: json['engine_id'] as String,
  engineVersion: json['engine_version'] as String,
  glossaryHits: (json['glossary_hits'] as List<dynamic>)
      .map((e) => GlossaryHit.fromJson(e as Map<String, dynamic>))
      .toList(),
  transcriptPolicyVersion: json['transcript_policy_version'] as String,
  locale: json['locale'] as String,
  recordedAt: DateTime.parse(json['recorded_at'] as String),
  sourceUri: json['source_uri'] as String,
  durationMs: (json['duration_ms'] as num).toInt(),
);

Map<String, dynamic> _$TranscriptToJson(_Transcript instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'transcript_id': instance.transcriptId,
      'segments': instance.segments.map((e) => e.toJson()).toList(),
      'words': instance.words.map((e) => e.toJson()).toList(),
      'engine_id': instance.engineId,
      'engine_version': instance.engineVersion,
      'glossary_hits': instance.glossaryHits.map((e) => e.toJson()).toList(),
      'transcript_policy_version': instance.transcriptPolicyVersion,
      'locale': instance.locale,
      'recorded_at': instance.recordedAt.toIso8601String(),
      'source_uri': instance.sourceUri,
      'duration_ms': instance.durationMs,
    };

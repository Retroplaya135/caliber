class TranscriptPolicy {
  const TranscriptPolicy._();

  static const String currentVersion = 'transcript_policy_v1';
  static const String transcriptSchemaVersion = 'transcript.v1';
  static const String transcriptSegmentSchemaVersion = 'transcript_segment.v1';
  static const String transcriptWordSchemaVersion = 'transcript_word.v1';
  static const String glossaryHitSchemaVersion = 'glossary_hit.v1';
}

class Transcript {
  const Transcript({
    required this.transcriptId,
    required this.segments,
    required this.words,
    required this.engineId,
    required this.engineVersion,
    required this.glossaryHits,
    required this.transcriptPolicyVersion,
    required this.locale,
    required this.recordedAt,
    required this.sourceUri,
    required this.durationMs,
    this.schemaVersion = TranscriptPolicy.transcriptSchemaVersion,
  });

  final String schemaVersion;
  final String transcriptId;
  final List<TranscriptSegment> segments;
  final List<TranscriptWord> words;
  final String engineId;
  final String engineVersion;
  final List<GlossaryHit> glossaryHits;
  final String transcriptPolicyVersion;
  final String locale;
  final DateTime recordedAt;
  final String sourceUri;
  final int durationMs;

  String get text => segments.map((segment) => segment.text).join(' ').trim();

  Map<String, Object?> toJson() => {
    'schema_version': schemaVersion,
    'transcript_id': transcriptId,
    'segments': segments.map((segment) => segment.toJson()).toList(),
    'words': words.map((word) => word.toJson()).toList(),
    'engine_id': engineId,
    'engine_version': engineVersion,
    'glossary_hits': glossaryHits.map((hit) => hit.toJson()).toList(),
    'transcript_policy_version': transcriptPolicyVersion,
    'locale': locale,
    'recorded_at': recordedAt.toIso8601String(),
    'source_uri': sourceUri,
    'duration_ms': durationMs,
  };

  Map<String, Object?> toCanonicalContentJson() => {
    'schema_version': schemaVersion,
    'transcript_id': transcriptId,
    'segments': segments.map((segment) => segment.toJson()).toList(),
    'words': words.map((word) => word.toJson()).toList(),
    'glossary_hits': glossaryHits.map((hit) => hit.toJson()).toList(),
    'transcript_policy_version': transcriptPolicyVersion,
    'locale': locale,
    'recorded_at': recordedAt.toIso8601String(),
    'source_uri': sourceUri,
    'duration_ms': durationMs,
  };
}

class TranscriptSegment {
  const TranscriptSegment({
    required this.segmentId,
    required this.startMs,
    required this.endMs,
    required this.text,
    required this.speakerLabel,
    this.wordIds = const <String>[],
    this.confidence,
    this.schemaVersion = TranscriptPolicy.transcriptSegmentSchemaVersion,
  });

  final String schemaVersion;
  final String segmentId;
  final int startMs;
  final int endMs;
  final String text;
  final double? confidence;
  final String speakerLabel;
  final List<String> wordIds;

  Map<String, Object?> toJson() => {
    'schema_version': schemaVersion,
    'segment_id': segmentId,
    'speaker_label': speakerLabel,
    'start_ms': startMs,
    'end_ms': endMs,
    'text': text,
    if (confidence != null) 'confidence': confidence,
    'word_ids': wordIds,
    'evidence_spans': const <Object>[],
  };
}

class TranscriptWord {
  const TranscriptWord({
    required this.wordId,
    required this.text,
    required this.startMs,
    required this.endMs,
    required this.segmentId,
    this.confidence,
    this.schemaVersion = TranscriptPolicy.transcriptWordSchemaVersion,
  });

  final String schemaVersion;
  final String wordId;
  final String text;
  final int startMs;
  final int endMs;
  final String segmentId;
  final double? confidence;

  Map<String, Object?> toJson() => {
    'schema_version': schemaVersion,
    'word_id': wordId,
    'text': text,
    'start_ms': startMs,
    'end_ms': endMs,
    'segment_id': segmentId,
    if (confidence != null) 'confidence': confidence,
  };
}

class GlossaryHit {
  const GlossaryHit({
    required this.term,
    required this.normalizedTerm,
    this.wordIds = const <String>[],
    this.confidence,
    this.source,
    this.schemaVersion = TranscriptPolicy.glossaryHitSchemaVersion,
  });

  final String schemaVersion;
  final String term;
  final String normalizedTerm;
  final List<String> wordIds;
  final double? confidence;
  final String? source;

  GlossaryHit withWordIds(List<String> ids) {
    return GlossaryHit(
      term: term,
      normalizedTerm: normalizedTerm,
      wordIds: List<String>.unmodifiable(ids),
      confidence: confidence,
      source: source,
      schemaVersion: schemaVersion,
    );
  }

  Map<String, Object?> toJson() => {
    'schema_version': schemaVersion,
    'term': term,
    'normalized_term': normalizedTerm,
    'word_ids': wordIds,
    if (confidence != null) 'confidence': confidence,
    if (source != null) 'source': source,
  };
}

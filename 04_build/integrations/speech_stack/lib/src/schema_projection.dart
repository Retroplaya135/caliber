import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'transcript_contract.dart' as local;

extension TranscriptSchemaProjection on local.Transcript {
  schema.Transcript toFrozenTranscriptSchema() {
    return schema.Transcript(
      transcriptId: transcriptId,
      segments: segments
          .map(
            (segment) => schema.TranscriptSegment(
              schemaVersion: segment.schemaVersion,
              segmentId: segment.segmentId,
              speakerLabel: segment.speakerLabel,
              startMs: segment.startMs,
              endMs: segment.endMs,
              text: segment.text,
              confidence: segment.confidence,
              wordIds: segment.wordIds,
            ),
          )
          .toList(growable: false),
      words: words
          .map(
            (word) => schema.TranscriptWord(
              schemaVersion: word.schemaVersion,
              wordId: word.wordId,
              segmentId: word.segmentId,
              text: word.text,
              startMs: word.startMs,
              endMs: word.endMs,
              confidence: word.confidence,
            ),
          )
          .toList(growable: false),
      engineId: engineId,
      engineVersion: engineVersion,
      glossaryHits: glossaryHits
          .map(
            (hit) => schema.GlossaryHit(
              schemaVersion: hit.schemaVersion,
              term: hit.term,
              normalizedTerm: hit.normalizedTerm,
              wordIds: hit.wordIds,
              confidence: hit.confidence,
              source: hit.source,
            ),
          )
          .toList(growable: false),
      transcriptPolicyVersion: transcriptPolicyVersion,
      locale: locale,
      recordedAt: recordedAt,
      sourceUri: sourceUri,
      durationMs: durationMs,
    );
  }
}

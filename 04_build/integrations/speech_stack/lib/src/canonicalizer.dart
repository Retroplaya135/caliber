import 'glossary.dart';
import 'raw_transcript.dart';
import 'transcript_contract.dart';

class TranscriptCanonicalizer {
  const TranscriptCanonicalizer();

  Transcript canonicalize({
    required RawTranscriptionResult raw,
    required String engineId,
    required String engineVersion,
    required JargonGlossary glossary,
    required String locale,
    required String sourceUri,
  }) {
    final sourceSegments = raw.segments.isEmpty
        ? <RawTranscriptSegment>[
            RawTranscriptSegment(
              text: raw.text,
              startMs: 0,
              endMs: _estimateDurationMs(raw.text),
            ),
          ]
        : raw.segments;

    final segments = <TranscriptSegment>[];
    final words = <TranscriptWord>[];
    for (var index = 0; index < sourceSegments.length; index += 1) {
      final rawSegment = sourceSegments[index];
      final segmentId =
          rawSegment.id ?? 'seg_${(index + 1).toString().padLeft(4, '0')}';
      final repairedText = glossary.repairText(rawSegment.text);
      final segmentWords = _wordsForSegment(
        segmentId,
        repairedText,
        rawSegment,
      );
      segments.add(
        TranscriptSegment(
          segmentId: segmentId,
          startMs: rawSegment.startMs,
          endMs: rawSegment.endMs,
          text: repairedText,
          confidence: rawSegment.confidence,
          speakerLabel: rawSegment.speakerLabel ?? 'speaker_1',
          wordIds: segmentWords.map((word) => word.wordId).toList(),
        ),
      );
      words.addAll(segmentWords);
    }
    final repairedTranscriptText = segments
        .map((segment) => segment.text)
        .join(' ')
        .trim();
    final glossaryHits = glossary.findHits(repairedTranscriptText);

    return Transcript(
      transcriptId: _stableTranscriptId(
        text: repairedTranscriptText,
        locale: locale,
        sourceUri: sourceUri,
      ),
      segments: List<TranscriptSegment>.unmodifiable(segments),
      words: List<TranscriptWord>.unmodifiable(words),
      engineId: engineId,
      engineVersion: engineVersion,
      glossaryHits: List<GlossaryHit>.unmodifiable(
        glossaryHits.map((hit) => hit.withWordIds(_wordIdsForHit(hit, words))),
      ),
      transcriptPolicyVersion: TranscriptPolicy.currentVersion,
      locale: locale,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      sourceUri: sourceUri,
      durationMs: _durationMs(sourceSegments),
    );
  }

  static int _estimateDurationMs(String text) {
    final words = _tokenize(text).length;
    return words == 0 ? 0 : words * 420;
  }

  static List<TranscriptWord> _wordsForSegment(
    String segmentId,
    String text,
    RawTranscriptSegment segment,
  ) {
    final tokens = _tokenize(text);
    if (tokens.isEmpty) {
      return const <TranscriptWord>[];
    }
    final duration = (segment.endMs - segment.startMs).clamp(0, 1 << 31);
    final slice = duration == 0 ? 0 : duration / tokens.length;
    return <TranscriptWord>[
      for (var index = 0; index < tokens.length; index += 1)
        TranscriptWord(
          wordId: '${segmentId}_w_${(index + 1).toString().padLeft(4, '0')}',
          text: tokens[index],
          startMs: segment.startMs + (slice * index).round(),
          endMs: segment.startMs + (slice * (index + 1)).round(),
          segmentId: segmentId,
          confidence: segment.confidence,
        ),
    ];
  }

  static List<String> _tokenize(String text) {
    return RegExp(
      r'[A-Za-z0-9][A-Za-z0-9._+#/-]*',
    ).allMatches(text).map((match) => match.group(0)!).toList(growable: false);
  }

  static int _durationMs(List<RawTranscriptSegment> segments) {
    if (segments.isEmpty) {
      return 0;
    }
    return segments
        .map((segment) => segment.endMs)
        .reduce((a, b) => a > b ? a : b);
  }

  static String _stableTranscriptId({
    required String text,
    required String locale,
    required String sourceUri,
  }) {
    var hash = 0x811c9dc5;
    final input = '$locale|$sourceUri|$text';
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'tr_${hash.toRadixString(16).padLeft(16, '0')}';
  }

  static List<String> _wordIdsForHit(
    GlossaryHit hit,
    List<TranscriptWord> words,
  ) {
    final termTokens = _tokenize(
      hit.term,
    ).map((token) => token.toLowerCase()).toList();
    if (termTokens.isEmpty) {
      return const <String>[];
    }
    for (var start = 0; start <= words.length - termTokens.length; start += 1) {
      final window = words
          .skip(start)
          .take(termTokens.length)
          .map((word) => word.text.toLowerCase())
          .toList();
      if (_listEquals(window, termTokens)) {
        return words
            .skip(start)
            .take(termTokens.length)
            .map((word) => word.wordId)
            .toList();
      }
    }
    return const <String>[];
  }

  static bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }
}

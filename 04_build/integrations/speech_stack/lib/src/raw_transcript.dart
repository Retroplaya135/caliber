class RawTranscriptionResult {
  const RawTranscriptionResult({
    required this.text,
    this.segments = const <RawTranscriptSegment>[],
  });

  final String text;
  final List<RawTranscriptSegment> segments;
}

class RawTranscriptSegment {
  const RawTranscriptSegment({
    required this.text,
    required this.startMs,
    required this.endMs,
    this.id,
    this.confidence,
    this.speakerLabel,
  });

  final String? id;
  final String text;
  final int startMs;
  final int endMs;
  final double? confidence;
  final String? speakerLabel;
}

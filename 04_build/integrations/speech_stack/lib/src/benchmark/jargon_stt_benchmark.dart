import '../audio_pipeline.dart';
import '../engine_registry.dart';
import '../glossary.dart';
import '../transcript_contract.dart';
import '../transcription_engine.dart';

class JargonBenchmarkClip {
  const JargonBenchmarkClip({
    required this.id,
    required this.audioFile,
    required this.expectedTerms,
  });

  final String id;
  final AudioFile audioFile;
  final Set<String> expectedTerms;
}

class JargonBenchmarkHarness {
  const JargonBenchmarkHarness({
    required this.engines,
    required this.normalizer,
    required this.platform,
    required this.locale,
    required this.glossary,
    required this.privacyMode,
  });

  final List<SpeechEngineAdapter> engines;
  final AudioNormalizer normalizer;
  final SpeechPlatform platform;
  final SpeechLocale locale;
  final JargonGlossary glossary;
  final PrivacyMode privacyMode;

  Future<JargonBenchmarkReport> run(List<JargonBenchmarkClip> clips) async {
    final results = <JargonBenchmarkResult>[];
    for (final engine in engines) {
      final registry = TranscriptionEngineRegistry()..register(engine);
      final transcriptionEngine = CapabilityAwareTranscriptionEngine(
        normalizer: normalizer,
        registry: registry,
        platform: platform,
      );
      for (final clip in clips) {
        final stopwatch = Stopwatch()..start();
        final transcript = await transcriptionEngine.transcribe(
          clip.audioFile,
          locale: locale,
          glossary: glossary,
          privacyMode: privacyMode,
        );
        stopwatch.stop();
        results.add(
          JargonBenchmarkResult.fromTranscript(
            clip: clip,
            engineId: transcript.engineId,
            elapsed: stopwatch.elapsed,
            transcript: transcript,
          ),
        );
      }
    }
    return JargonBenchmarkReport(results);
  }
}

class JargonBenchmarkResult {
  const JargonBenchmarkResult({
    required this.clipId,
    required this.engineId,
    required this.expectedTerms,
    required this.hitTerms,
    required this.latencyMs,
    required this.glossaryRecall,
    required this.transcriptPolicyVersion,
  });

  factory JargonBenchmarkResult.fromTranscript({
    required JargonBenchmarkClip clip,
    required String engineId,
    required Duration elapsed,
    required Transcript transcript,
  }) {
    final hitTerms = transcript.glossaryHits.map((hit) => hit.term).toSet();
    final expectedHits = clip.expectedTerms.where(hitTerms.contains).length;
    final recall = clip.expectedTerms.isEmpty
        ? 1.0
        : expectedHits / clip.expectedTerms.length;
    return JargonBenchmarkResult(
      clipId: clip.id,
      engineId: engineId,
      expectedTerms: Set<String>.unmodifiable(clip.expectedTerms),
      hitTerms: Set<String>.unmodifiable(hitTerms),
      latencyMs: elapsed.inMilliseconds,
      glossaryRecall: recall,
      transcriptPolicyVersion: transcript.transcriptPolicyVersion,
    );
  }

  final String clipId;
  final String engineId;
  final Set<String> expectedTerms;
  final Set<String> hitTerms;
  final int latencyMs;
  final double glossaryRecall;
  final String transcriptPolicyVersion;

  Map<String, Object?> toJson() => {
    'clip_id': clipId,
    'engine_id': engineId,
    'expected_terms': expectedTerms.toList()..sort(),
    'hit_terms': hitTerms.toList()..sort(),
    'latency_ms': latencyMs,
    'glossary_recall': glossaryRecall,
    'transcript_policy_version': transcriptPolicyVersion,
  };
}

class JargonBenchmarkReport {
  const JargonBenchmarkReport(this.results);

  final List<JargonBenchmarkResult> results;

  double get averageGlossaryRecall {
    if (results.isEmpty) {
      return 0;
    }
    final total = results.fold<double>(
      0,
      (sum, result) => sum + result.glossaryRecall,
    );
    return total / results.length;
  }

  Map<String, Object?> toJson() => {
    'policy_version': TranscriptPolicy.currentVersion,
    'average_glossary_recall': averageGlossaryRecall,
    'results': results.map((result) => result.toJson()).toList(),
  };
}

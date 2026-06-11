import 'package:caliber_speech_stack/speech_stack.dart';
import 'package:test/test.dart' as package_test;

import '_test_support.dart';

void main() {
  package_test.test(
    'speech recognition pipeline',
    runSpeechRecognitionPipelineTests,
  );
}

Future<void> runSpeechRecognitionPipelineTests() async {
  await runTest(
    'recording pipeline reaches ffmpeg, platform policy, and canonical transcript',
    () async {
      final capture = _ScriptedAudioCapture();
      final ffmpeg = _RecordingFfmpegRunner();
      final glossary = JargonGlossary.threeLayer(
        foundation: <GlossaryTerm>[
          GlossaryTerm(
            canonical: 'BM25',
            layer: GlossaryLayer.foundation,
            aliases: const <String>['BM twenty five'],
          ),
        ],
      );
      final backend = ScriptedSpeechBackend(<String, RawTranscriptionResult>{
        'captured/interview.m4a': const RawTranscriptionResult(
          text: 'BM twenty five should survive the pipeline.',
          segments: <RawTranscriptSegment>[
            RawTranscriptSegment(
              text: 'BM twenty five should survive the pipeline.',
              startMs: 0,
              endMs: 2800,
            ),
          ],
        ),
      });
      final registry = TranscriptionEngineRegistry()
        ..register(WhisperCppEngine(backend: backend));
      final engine = CapabilityAwareTranscriptionEngine(
        normalizer: FfmpegAudioNormalizer(
          runner: ffmpeg,
          outputPathFor: (input) => '${input.path}.normalized.wav',
        ),
        registry: registry,
        platform: SpeechPlatform.macos,
      );
      final pipeline = SpeechRecognitionPipeline(
        capture: capture,
        transcriptionEngine: engine,
      );

      final transcript = await pipeline.recordAndTranscribe(
        outputPath: 'captured/interview.m4a',
        maxDuration: const Duration(minutes: 30),
        locale: const SpeechLocale('en-US'),
        glossary: glossary,
        privacyMode: PrivacyMode.localOnly(),
      );

      check(
        capture.outputPath == 'captured/interview.m4a',
        'capture receives target output path',
      );
      check(
        capture.maxDuration == const Duration(minutes: 30),
        'capture receives max duration',
      );
      check(
        ffmpeg.arguments.join(' ') ==
            '-y -i captured/interview.m4a -ar 16000 -ac 1 -c:a pcm_s16le captured/interview.m4a.normalized.wav',
        'ffmpeg normalizes captured audio before STT',
      );
      check(
        backend.calls.single == 'whisper.cpp',
        'platform policy selects registered whisper engine',
      );
      check(
        transcript.text.contains('BM25'),
        'canonical transcript includes glossary-repaired jargon',
      );
      check(
        transcript.sourceUri == 'captured/interview.m4a',
        'canonical transcript source remains original recording path',
      );
    },
  );
}

class _ScriptedAudioCapture implements AudioCapture {
  String? outputPath;
  Duration? maxDuration;

  @override
  Future<AudioFile> record({
    required String outputPath,
    required Duration maxDuration,
  }) async {
    this.outputPath = outputPath;
    this.maxDuration = maxDuration;
    return AudioFile(path: outputPath, durationMs: maxDuration.inMilliseconds);
  }
}

class _RecordingFfmpegRunner implements FfmpegRunner {
  var arguments = <String>[];

  @override
  Future<FfmpegResult> run(List<String> arguments) async {
    this.arguments = List<String>.unmodifiable(arguments);
    return FfmpegResult(exitCode: 0, outputPath: arguments.last);
  }
}

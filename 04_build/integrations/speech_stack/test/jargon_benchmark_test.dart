import 'package:caliber_speech_stack/speech_stack.dart';
import 'package:test/test.dart' as package_test;

import '_test_support.dart';

void main() {
  package_test.test('jargon benchmark harness', runJargonBenchmarkTests);
}

Future<void> runJargonBenchmarkTests() async {
  await runTest(
    'jargon benchmark harness runs and reports glossary recall',
    () async {
      final glossary = JargonGlossary.threeLayer(
        foundation: <GlossaryTerm>[
          GlossaryTerm(canonical: 'Flutter', layer: GlossaryLayer.foundation),
          GlossaryTerm(canonical: 'Riverpod', layer: GlossaryLayer.foundation),
        ],
        session: <GlossaryTerm>[
          GlossaryTerm(
            canonical: 'whisper.cpp',
            layer: GlossaryLayer.session,
            aliases: const <String>['whisper cpp'],
          ),
        ],
      );
      final backend = ScriptedSpeechBackend(<String, RawTranscriptionResult>{
        'fixture.wav': const RawTranscriptionResult(
          text: 'Flutter and Riverpod can use whisper cpp for offline ASR.',
          segments: <RawTranscriptSegment>[
            RawTranscriptSegment(
              text: 'Flutter and Riverpod can use whisper cpp for offline ASR.',
              startMs: 0,
              endMs: 4400,
            ),
          ],
        ),
      });
      final harness = JargonBenchmarkHarness(
        engines: <SpeechEngineAdapter>[WhisperCppEngine(backend: backend)],
        normalizer: const PassthroughAudioNormalizer(),
        platform: SpeechPlatform.macos,
        locale: const SpeechLocale('en-US'),
        glossary: glossary,
        privacyMode: PrivacyMode.localOnly(),
      );

      final report = await harness.run(const <JargonBenchmarkClip>[
        JargonBenchmarkClip(
          id: 'clip-001',
          audioFile: AudioFile(path: 'fixture.wav'),
          expectedTerms: <String>{'Flutter', 'Riverpod', 'whisper.cpp'},
        ),
      ]);

      check(report.results.length == 1, 'one benchmark result emitted');
      check(
        report.averageGlossaryRecall == 1.0,
        'all expected jargon terms hit',
      );
      check(
        report.toJson()['policy_version'] == TranscriptPolicy.currentVersion,
        'benchmark output carries transcript policy version',
      );
    },
  );
}

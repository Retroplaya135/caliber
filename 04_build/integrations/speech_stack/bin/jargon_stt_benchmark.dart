import 'dart:convert';

import 'package:caliber_speech_stack/speech_stack.dart';

Future<void> main() async {
  final glossary = JargonGlossary.threeLayer(
    foundation: <GlossaryTerm>[
      GlossaryTerm(canonical: 'Flutter', layer: GlossaryLayer.foundation),
      GlossaryTerm(canonical: 'Riverpod', layer: GlossaryLayer.foundation),
      GlossaryTerm(
        canonical: 'BM25',
        layer: GlossaryLayer.foundation,
        aliases: const <String>['BM twenty five', 'best matching 25'],
      ),
    ],
    session: <GlossaryTerm>[
      GlossaryTerm(
        canonical: 'whisper.cpp',
        layer: GlossaryLayer.session,
        aliases: const <String>['whisper cpp'],
      ),
    ],
  );

  const transcript = RawTranscriptionResult(
    text:
        'The candidate explained Flutter, Riverpod, BM twenty five, and whisper cpp.',
    segments: <RawTranscriptSegment>[
      RawTranscriptSegment(
        text:
            'The candidate explained Flutter, Riverpod, BM twenty five, and whisper cpp.',
        startMs: 0,
        endMs: 5200,
      ),
    ],
  );
  final backend = ScriptedSpeechBackend(<String, RawTranscriptionResult>{
    'fixtures/jargon_interview.wav': transcript,
  });

  final harness = JargonBenchmarkHarness(
    engines: <SpeechEngineAdapter>[
      WhisperCppEngine(backend: backend),
      SherpaOnnxEngine(backend: backend),
    ],
    normalizer: const PassthroughAudioNormalizer(),
    platform: SpeechPlatform.macos,
    locale: const SpeechLocale('en-US'),
    glossary: glossary,
    privacyMode: PrivacyMode.localOnly(),
  );

  final report = await harness.run(const <JargonBenchmarkClip>[
    JargonBenchmarkClip(
      id: 'jargon_interview_001',
      audioFile: AudioFile(path: 'fixtures/jargon_interview.wav'),
      expectedTerms: <String>{'Flutter', 'Riverpod', 'BM25', 'whisper.cpp'},
    ),
  ]);

  const encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(report.toJson()));
}

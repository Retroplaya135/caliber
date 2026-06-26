import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:caliber_speech_stack/speech_stack.dart';
import 'package:test/test.dart' as package_test;

import '_test_support.dart';

void main() {
  package_test.test(
    'transcription engine contracts',
    runTranscriptionEngineContractTests,
  );
}

Future<void> runTranscriptionEngineContractTests() async {
  await runTest(
    'canonical content is identical across on-device engines',
    () async {
      final glossary = _glossary();
      final raw = _rawTranscript();
      final file = const AudioFile(path: 'fixture.wav');

      final whisper =
          await _engineFor(
            WhisperCppEngine(
              backend: ScriptedSpeechBackend(<String, RawTranscriptionResult>{
                file.path: raw,
              }),
            ),
          ).transcribe(
            file,
            locale: const SpeechLocale('en-US'),
            glossary: glossary,
            privacyMode: PrivacyMode.localOnly(),
          );
      final sherpa =
          await _engineFor(
            SherpaOnnxEngine(
              backend: ScriptedSpeechBackend(<String, RawTranscriptionResult>{
                file.path: raw,
              }),
            ),
          ).transcribe(
            file,
            locale: const SpeechLocale('en-US'),
            glossary: glossary,
            privacyMode: PrivacyMode.localOnly(),
          );

      check(
        whisper.engineId == 'whisper.cpp',
        'whisper engine provenance kept',
      );
      check(sherpa.engineId == 'sherpa-onnx', 'sherpa engine provenance kept');
      check(
        _mapsEqual(
          whisper.toCanonicalContentJson(),
          sherpa.toCanonicalContentJson(),
        ),
        'canonical transcript content must not leak engine-specific shape',
      );
      check(
        whisper.glossaryHits.map((hit) => hit.term).contains('BM25'),
        'glossary repair records BM25 hit',
      );
      check(
        whisper.toJson()['schema_version'] ==
            TranscriptPolicy.transcriptSchemaVersion,
        'transcript schema version is explicit',
      );
      check(
        whisper.toJson()['locale'] == 'en-US',
        'transcript locale mirrors request locale',
      );
      check(
        whisper.toJson()['source_uri'] == file.path,
        'transcript source URI mirrors original audio path',
      );
      check(
        whisper.toJson()['duration_ms'] == 4200,
        'transcript duration comes from segment envelope',
      );
      check(
        whisper.segments.single.segmentId == 'seg_0001',
        'segment id is deterministic',
      );
      check(
        whisper.segments.single.wordIds.length == whisper.words.length,
        'segment carries word ids for all canonical words',
      );
      check(
        whisper.words.first.wordId == 'seg_0001_w_0001',
        'word id is deterministic and schema-compatible',
      );
      final bm25Hit = whisper.glossaryHits.firstWhere(
        (hit) => hit.term == 'BM25',
      );
      check(
        bm25Hit.wordIds.isNotEmpty,
        'glossary hit links back to canonical word ids',
      );
      check(
        bm25Hit.source == GlossaryLayer.foundation.name,
        'glossary hit records source layer',
      );
      final frozenSchemaTranscript = whisper.toFrozenTranscriptSchema();
      check(
        frozenSchemaTranscript.schemaVersion == schema.kTranscriptSchemaVersion,
        'frozen schema transcript version imported from Schema Core',
      );
      check(
        frozenSchemaTranscript.segments.single.segmentId ==
            whisper.segments.single.segmentId,
        'frozen schema segment mirrors canonical segment id',
      );
      check(
        frozenSchemaTranscript.words.first.wordId == whisper.words.first.wordId,
        'frozen schema word mirrors canonical word id',
      );
      check(
        frozenSchemaTranscript.glossaryHits.first.wordIds.isNotEmpty,
        'frozen schema glossary hit mirrors canonical word links',
      );
      check(
        schema.Transcript.fromJson(
              frozenSchemaTranscript.toJson(),
            ).transcriptId ==
            whisper.transcriptId,
        'frozen schema transcript round-trips through generated JSON',
      );
    },
  );

  await runTest(
    'registration keeps call sites unchanged and picks whisper first',
    () async {
      final backend = ScriptedSpeechBackend(<String, RawTranscriptionResult>{
        'fixture.wav': _rawTranscript(),
      });
      final registry = TranscriptionEngineRegistry()
        ..register(SherpaOnnxEngine(backend: backend))
        ..register(WhisperCppEngine(backend: backend));
      final engine = CapabilityAwareTranscriptionEngine(
        normalizer: const PassthroughAudioNormalizer(),
        registry: registry,
        platform: SpeechPlatform.macos,
      );

      final transcript = await engine.transcribe(
        const AudioFile(path: 'fixture.wav'),
        locale: const SpeechLocale('en-US'),
        glossary: _glossary(),
        privacyMode: PrivacyMode.localOnly(),
      );

      check(
        transcript.engineId == 'whisper.cpp',
        'whisper.cpp is primary on-device',
      );
      check(backend.calls.length == 1, 'only selected engine is invoked');
    },
  );

  await runTest(
    'cloud fallback is not called without explicit consent',
    () async {
      final cloudBackend = ScriptedSpeechBackend(
        <String, RawTranscriptionResult>{'fixture.wav': _rawTranscript()},
      );
      final registry = TranscriptionEngineRegistry()
        ..register(CloudFallbackSpeechEngine.deepgram(backend: cloudBackend));
      final engine = CapabilityAwareTranscriptionEngine(
        normalizer: const PassthroughAudioNormalizer(),
        registry: registry,
        platform: SpeechPlatform.macos,
      );

      await checkThrows<CloudConsentRequiredException>(
        () => engine.transcribe(
          const AudioFile(path: 'fixture.wav'),
          locale: const SpeechLocale('en-US'),
          glossary: _glossary(),
          privacyMode: PrivacyMode.localOnly(),
        ),
        'cloud must be opt-in only',
      );
      check(cloudBackend.calls.isEmpty, 'cloud backend was not called');

      final transcript = await engine.transcribe(
        const AudioFile(path: 'fixture.wav'),
        locale: const SpeechLocale('en-US'),
        glossary: _glossary(),
        privacyMode: PrivacyMode.cloudOptIn(
          consentArtifactId: 'consent-audio-001',
        ),
      );
      check(
        transcript.engineId == 'deepgram.cloud',
        'cloud fallback works after consent',
      );
      check(
        cloudBackend.calls.length == 1,
        'cloud backend called exactly once',
      );
    },
  );
}

JargonGlossary _glossary() {
  return JargonGlossary.threeLayer(
    foundation: <GlossaryTerm>[
      GlossaryTerm(
        canonical: 'BM25',
        layer: GlossaryLayer.foundation,
        aliases: const <String>['BM twenty five'],
      ),
      GlossaryTerm(canonical: 'Riverpod', layer: GlossaryLayer.foundation),
    ],
  );
}

RawTranscriptionResult _rawTranscript() {
  return const RawTranscriptionResult(
    text: 'We used Riverpod and BM twenty five for retrieval.',
    segments: <RawTranscriptSegment>[
      RawTranscriptSegment(
        text: 'We used Riverpod and BM twenty five for retrieval.',
        startMs: 0,
        endMs: 4200,
      ),
    ],
  );
}

TranscriptionEngine _engineFor(SpeechEngineAdapter adapter) {
  final registry = TranscriptionEngineRegistry()..register(adapter);
  return CapabilityAwareTranscriptionEngine(
    normalizer: const PassthroughAudioNormalizer(),
    registry: registry,
    platform: SpeechPlatform.macos,
  );
}

bool _mapsEqual(Map<String, Object?> left, Map<String, Object?> right) {
  return left.toString() == right.toString();
}

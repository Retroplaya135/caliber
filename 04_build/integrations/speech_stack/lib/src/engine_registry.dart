import 'audio_pipeline.dart';
import 'canonicalizer.dart';
import 'glossary.dart';
import 'raw_transcript.dart';
import 'transcript_contract.dart';
import 'transcription_engine.dart';

abstract interface class SpeechEngineAdapter {
  EngineDescriptor get descriptor;

  Future<bool> isAvailable(TranscriptionRequest request);

  Future<RawTranscriptionResult> transcribeNormalized(
    NormalizedAudio audio,
    TranscriptionRequest request,
  );
}

class TranscriptionEngineRegistry {
  final Map<String, SpeechEngineAdapter> _engines =
      <String, SpeechEngineAdapter>{};

  void register(SpeechEngineAdapter engine) {
    final id = engine.descriptor.id;
    if (_engines.containsKey(id)) {
      throw StateError('speech engine already registered: $id');
    }
    _engines[id] = engine;
  }

  List<SpeechEngineAdapter> registered() {
    final engines = _engines.values.toList(growable: false);
    engines.sort(
      (left, right) =>
          left.descriptor.priority.compareTo(right.descriptor.priority),
    );
    return engines;
  }

  bool get isEmpty => _engines.isEmpty;
}

class CapabilityAwareTranscriptionEngine implements TranscriptionEngine {
  CapabilityAwareTranscriptionEngine({
    required AudioNormalizer normalizer,
    required TranscriptionEngineRegistry registry,
    required SpeechPlatform platform,
    TranscriptCanonicalizer canonicalizer = const TranscriptCanonicalizer(),
    PlatformEnginePolicy enginePolicy = const PlatformEnginePolicy(),
  }) : _normalizer = normalizer,
       _registry = registry,
       _platform = platform,
       _canonicalizer = canonicalizer,
       _enginePolicy = enginePolicy;

  final AudioNormalizer _normalizer;
  final TranscriptionEngineRegistry _registry;
  final SpeechPlatform _platform;
  final TranscriptCanonicalizer _canonicalizer;
  final PlatformEnginePolicy _enginePolicy;

  @override
  Future<Transcript> transcribe(
    AudioFile file, {
    required SpeechLocale locale,
    required JargonGlossary glossary,
    required PrivacyMode privacyMode,
  }) async {
    if (_registry.isEmpty) {
      throw const TranscriptionEngineUnavailableException(
        'no engines registered',
      );
    }

    final request = TranscriptionRequest(
      locale: locale,
      glossary: glossary,
      privacyMode: privacyMode,
      platform: _platform,
    );
    final audio = await _normalizer.normalize(file);
    final selection = await _enginePolicy.eligibleEngines(
      engines: _registry.registered(),
      request: request,
    );
    final candidates = selection.engines;
    if (candidates.isEmpty) {
      if (selection.cloudBlockedByConsent) {
        throw const CloudConsentRequiredException(
          'cloud STT fallback requires privacy_mode cloud opt-in consent',
        );
      }
      throw const TranscriptionEngineUnavailableException(
        'no speech engine available for platform/privacy policy',
      );
    }

    final engine = candidates.first;
    final raw = await engine.transcribeNormalized(audio, request);
    return _canonicalizer.canonicalize(
      raw: raw,
      engineId: engine.descriptor.id,
      engineVersion: engine.descriptor.version,
      glossary: glossary,
      locale: request.locale.tag,
      sourceUri: audio.source.path,
    );
  }
}

class PlatformEnginePolicy {
  const PlatformEnginePolicy();

  Future<EngineSelection> eligibleEngines({
    required List<SpeechEngineAdapter> engines,
    required TranscriptionRequest request,
  }) async {
    final result = <SpeechEngineAdapter>[];
    var cloudBlockedByConsent = false;
    for (final engine in engines) {
      final descriptor = engine.descriptor;
      if (!descriptor.supports(request.platform)) {
        continue;
      }
      if (descriptor.location == EngineLocation.cloud &&
          !request.privacyMode.canUseCloud) {
        cloudBlockedByConsent = true;
        continue;
      }
      if (await engine.isAvailable(request)) {
        result.add(engine);
      }
    }
    return EngineSelection(
      engines: List<SpeechEngineAdapter>.unmodifiable(result),
      cloudBlockedByConsent: cloudBlockedByConsent,
    );
  }
}

class EngineSelection {
  const EngineSelection({
    required this.engines,
    required this.cloudBlockedByConsent,
  });

  final List<SpeechEngineAdapter> engines;
  final bool cloudBlockedByConsent;
}

class TranscriptionEngineUnavailableException implements Exception {
  const TranscriptionEngineUnavailableException(this.message);

  final String message;

  @override
  String toString() => 'TranscriptionEngineUnavailableException: $message';
}

class CloudConsentRequiredException implements Exception {
  const CloudConsentRequiredException(this.message);

  final String message;

  @override
  String toString() => 'CloudConsentRequiredException: $message';
}

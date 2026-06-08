import 'audio_pipeline.dart';
import 'glossary.dart';
import 'transcript_contract.dart';

abstract interface class TranscriptionEngine {
  Future<Transcript> transcribe(
    AudioFile file, {
    required SpeechLocale locale,
    required JargonGlossary glossary,
    required PrivacyMode privacyMode,
  });
}

class SpeechLocale {
  const SpeechLocale(this.tag);

  final String tag;
}

class PrivacyMode {
  const PrivacyMode._({
    required this.allowCloudFallback,
    required this.explicitCloudConsent,
    this.consentArtifactId,
  });

  factory PrivacyMode.localOnly() => const PrivacyMode._(
    allowCloudFallback: false,
    explicitCloudConsent: false,
  );

  factory PrivacyMode.cloudOptIn({required String consentArtifactId}) {
    if (consentArtifactId.trim().isEmpty) {
      throw ArgumentError.value(
        consentArtifactId,
        'consentArtifactId',
        'cloud consent must be auditable',
      );
    }
    return PrivacyMode._(
      allowCloudFallback: true,
      explicitCloudConsent: true,
      consentArtifactId: consentArtifactId,
    );
  }

  final bool allowCloudFallback;
  final bool explicitCloudConsent;
  final String? consentArtifactId;

  bool get canUseCloud => allowCloudFallback && explicitCloudConsent;
}

enum SpeechPlatform { ios, android, macos, linux, windows, web, unknown }

enum EngineLocation { onDevice, cloud }

class EngineDescriptor {
  const EngineDescriptor({
    required this.id,
    required this.version,
    required this.location,
    required this.supportedPlatforms,
    required this.priority,
    this.requiresNormalizedWav = true,
  });

  final String id;
  final String version;
  final EngineLocation location;
  final Set<SpeechPlatform> supportedPlatforms;
  final int priority;
  final bool requiresNormalizedWav;

  bool supports(SpeechPlatform platform) {
    return supportedPlatforms.contains(platform) ||
        supportedPlatforms.contains(SpeechPlatform.unknown);
  }
}

class TranscriptionRequest {
  const TranscriptionRequest({
    required this.locale,
    required this.glossary,
    required this.privacyMode,
    required this.platform,
  });

  final SpeechLocale locale;
  final JargonGlossary glossary;
  final PrivacyMode privacyMode;
  final SpeechPlatform platform;
}

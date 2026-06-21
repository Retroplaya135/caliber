import 'package:caliber_speech_stack/speech_stack.dart' as speech;

abstract interface class InterviewVoiceInput {
  Future<bool> isAvailable();

  Future<String> recordAndTranscribeAnswer();

  String get unavailableMessage;
}

final class NoConfiguredInterviewVoiceInput implements InterviewVoiceInput {
  const NoConfiguredInterviewVoiceInput();

  @override
  String get unavailableMessage =>
      'Voice input is not configured on this device yet. Type your answer below.';

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<String> recordAndTranscribeAnswer() {
    throw const SpeechInputUnavailableException(
      'No speech engine is configured.',
    );
  }
}

final class SpeechStackInterviewVoiceInput implements InterviewVoiceInput {
  const SpeechStackInterviewVoiceInput({
    required this.pipeline,
    required this.outputPath,
    this.maxDuration = const Duration(seconds: 90),
    this.locale = const speech.SpeechLocale('en-US'),
    this.glossary,
    this.privacyMode,
  });

  final speech.SpeechRecognitionPipeline pipeline;
  final String outputPath;
  final Duration maxDuration;
  final speech.SpeechLocale locale;
  final speech.JargonGlossary? glossary;
  final speech.PrivacyMode? privacyMode;

  @override
  String get unavailableMessage =>
      'No local speech engine is available. Type your answer below.';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> recordAndTranscribeAnswer() async {
    final transcript = await pipeline.recordAndTranscribe(
      outputPath: outputPath,
      maxDuration: maxDuration,
      locale: locale,
      glossary: glossary ?? speech.JargonGlossary.empty(),
      privacyMode: privacyMode ?? speech.PrivacyMode.localOnly(),
    );
    final text = transcript.text;
    if (text.isEmpty) {
      throw const SpeechInputUnavailableException(
        'Speech engine returned an empty transcript.',
      );
    }
    return text;
  }
}

final class SpeechInputUnavailableException implements Exception {
  const SpeechInputUnavailableException(this.message);

  final String message;

  @override
  String toString() => 'SpeechInputUnavailableException: $message';
}

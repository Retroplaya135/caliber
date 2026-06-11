import 'audio_pipeline.dart';
import 'glossary.dart';
import 'transcript_contract.dart';
import 'transcription_engine.dart';

class SpeechRecognitionPipeline {
  const SpeechRecognitionPipeline({
    required AudioCapture capture,
    required TranscriptionEngine transcriptionEngine,
  }) : _capture = capture,
       _transcriptionEngine = transcriptionEngine;

  final AudioCapture _capture;
  final TranscriptionEngine _transcriptionEngine;

  Future<Transcript> recordAndTranscribe({
    required String outputPath,
    required Duration maxDuration,
    required SpeechLocale locale,
    required JargonGlossary glossary,
    required PrivacyMode privacyMode,
  }) async {
    final recording = await _capture.record(
      outputPath: outputPath,
      maxDuration: maxDuration,
    );
    return _transcriptionEngine.transcribe(
      recording,
      locale: locale,
      glossary: glossary,
      privacyMode: privacyMode,
    );
  }
}

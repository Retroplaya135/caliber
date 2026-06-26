import 'audio_pipeline_test.dart' hide main;
import 'jargon_benchmark_test.dart' hide main;
import 'speech_recognition_pipeline_test.dart' hide main;
import 'transcription_engine_contract_test.dart' hide main;

Future<void> main() async {
  await runAudioPipelineTests();
  await runSpeechRecognitionPipelineTests();
  await runTranscriptionEngineContractTests();
  await runJargonBenchmarkTests();
}

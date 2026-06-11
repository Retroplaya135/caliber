import '../audio_pipeline.dart';
import '../engine_registry.dart';
import '../raw_transcript.dart';
import '../transcription_engine.dart';

abstract interface class SpeechBackend {
  Future<RawTranscriptionResult> transcribe(
    NormalizedAudio audio,
    TranscriptionRequest request,
    EngineDescriptor descriptor,
  );
}

class BackendSpeechEngine implements SpeechEngineAdapter {
  const BackendSpeechEngine({
    required this.descriptor,
    required SpeechBackend backend,
    bool Function(TranscriptionRequest request)? availability,
  }) : _backend = backend,
       _availability = availability;

  @override
  final EngineDescriptor descriptor;

  final SpeechBackend _backend;
  final bool Function(TranscriptionRequest request)? _availability;

  @override
  Future<bool> isAvailable(TranscriptionRequest request) async {
    return _availability?.call(request) ?? true;
  }

  @override
  Future<RawTranscriptionResult> transcribeNormalized(
    NormalizedAudio audio,
    TranscriptionRequest request,
  ) {
    return _backend.transcribe(audio, request, descriptor);
  }
}

class WhisperCppEngine extends BackendSpeechEngine {
  WhisperCppEngine({
    required SpeechBackend backend,
    String version = 'whisper.cpp-v1.8.5',
  }) : super(
         descriptor: EngineDescriptor(
           id: 'whisper.cpp',
           version: version,
           location: EngineLocation.onDevice,
           supportedPlatforms: const <SpeechPlatform>{
             SpeechPlatform.ios,
             SpeechPlatform.android,
             SpeechPlatform.macos,
             SpeechPlatform.linux,
             SpeechPlatform.windows,
             SpeechPlatform.unknown,
           },
           priority: 0,
         ),
         backend: backend,
       );
}

class AppleNativeSpeechEngine extends BackendSpeechEngine {
  AppleNativeSpeechEngine({
    required SpeechBackend backend,
    String version = 'apple-speech-os',
  }) : super(
         descriptor: EngineDescriptor(
           id: 'apple.native',
           version: version,
           location: EngineLocation.onDevice,
           supportedPlatforms: const <SpeechPlatform>{SpeechPlatform.ios},
           priority: 10,
         ),
         backend: backend,
       );
}

class AndroidOnDeviceSpeechEngine extends BackendSpeechEngine {
  AndroidOnDeviceSpeechEngine({
    required SpeechBackend backend,
    String version = 'android-speechrecognizer-on-device',
    bool Function(TranscriptionRequest request)? availability,
  }) : super(
         descriptor: EngineDescriptor(
           id: 'android.on_device',
           version: version,
           location: EngineLocation.onDevice,
           supportedPlatforms: const <SpeechPlatform>{SpeechPlatform.android},
           priority: 10,
         ),
         backend: backend,
         availability: availability,
       );
}

class SherpaOnnxEngine extends BackendSpeechEngine {
  SherpaOnnxEngine({
    required SpeechBackend backend,
    String version = 'sherpa-onnx',
  }) : super(
         descriptor: EngineDescriptor(
           id: 'sherpa-onnx',
           version: version,
           location: EngineLocation.onDevice,
           supportedPlatforms: const <SpeechPlatform>{
             SpeechPlatform.ios,
             SpeechPlatform.android,
             SpeechPlatform.macos,
             SpeechPlatform.linux,
             SpeechPlatform.unknown,
           },
           priority: 20,
         ),
         backend: backend,
       );
}

class CloudFallbackSpeechEngine extends BackendSpeechEngine {
  CloudFallbackSpeechEngine.deepgram({
    required SpeechBackend backend,
    String version = 'deepgram-nova-3',
  }) : super(
         descriptor: EngineDescriptor(
           id: 'deepgram.cloud',
           version: version,
           location: EngineLocation.cloud,
           supportedPlatforms: const <SpeechPlatform>{
             SpeechPlatform.ios,
             SpeechPlatform.android,
             SpeechPlatform.macos,
             SpeechPlatform.linux,
             SpeechPlatform.windows,
             SpeechPlatform.web,
             SpeechPlatform.unknown,
           },
           priority: 100,
         ),
         backend: backend,
       );

  CloudFallbackSpeechEngine.google({
    required SpeechBackend backend,
    String version = 'google-stt-v2',
  }) : super(
         descriptor: EngineDescriptor(
           id: 'google.cloud',
           version: version,
           location: EngineLocation.cloud,
           supportedPlatforms: const <SpeechPlatform>{
             SpeechPlatform.ios,
             SpeechPlatform.android,
             SpeechPlatform.macos,
             SpeechPlatform.linux,
             SpeechPlatform.windows,
             SpeechPlatform.web,
             SpeechPlatform.unknown,
           },
           priority: 101,
         ),
         backend: backend,
       );
}

class ScriptedSpeechBackend implements SpeechBackend {
  ScriptedSpeechBackend(this.results);

  final Map<String, RawTranscriptionResult> results;
  final calls = <String>[];

  @override
  Future<RawTranscriptionResult> transcribe(
    NormalizedAudio audio,
    TranscriptionRequest request,
    EngineDescriptor descriptor,
  ) async {
    calls.add(descriptor.id);
    return results[audio.source.path] ??
        results[audio.path] ??
        (throw StateError('no scripted transcript for ${audio.source.path}'));
  }
}

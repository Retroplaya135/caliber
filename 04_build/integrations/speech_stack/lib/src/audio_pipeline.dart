import 'dart:async';

class AudioFile {
  const AudioFile({required this.path, this.mimeType, this.durationMs});

  final String path;
  final String? mimeType;
  final int? durationMs;
}

class NormalizedAudio {
  const NormalizedAudio({
    required this.source,
    required this.path,
    required this.sampleRateHz,
    required this.channels,
    required this.encoding,
  });

  final AudioFile source;
  final String path;
  final int sampleRateHz;
  final int channels;
  final String encoding;

  Map<String, Object?> toJson() => {
    'source_path': source.path,
    'path': path,
    'sample_rate_hz': sampleRateHz,
    'channels': channels,
    'encoding': encoding,
  };
}

abstract interface class AudioCapture {
  Future<AudioFile> record({
    required String outputPath,
    required Duration maxDuration,
  });
}

abstract interface class AudioNormalizer {
  Future<NormalizedAudio> normalize(AudioFile input);
}

abstract interface class FfmpegRunner {
  Future<FfmpegResult> run(List<String> arguments);
}

class FfmpegResult {
  const FfmpegResult({
    required this.exitCode,
    required this.outputPath,
    this.logs = const <String>[],
  });

  final int exitCode;
  final String outputPath;
  final List<String> logs;

  bool get isSuccess => exitCode == 0;
}

class FfmpegNormalizeException implements Exception {
  const FfmpegNormalizeException(this.message, this.logs);

  final String message;
  final List<String> logs;

  @override
  String toString() => 'FfmpegNormalizeException: $message';
}

class FfmpegAudioNormalizer implements AudioNormalizer {
  FfmpegAudioNormalizer({
    required FfmpegRunner runner,
    required String Function(AudioFile input) outputPathFor,
  }) : _runner = runner,
       _outputPathFor = outputPathFor;

  final FfmpegRunner _runner;
  final String Function(AudioFile input) _outputPathFor;

  static const int canonicalSampleRateHz = 16000;
  static const int canonicalChannels = 1;
  static const String canonicalEncoding = 'pcm_s16le_wav';

  @override
  Future<NormalizedAudio> normalize(AudioFile input) async {
    final outputPath = _outputPathFor(input);
    final result = await _runner.run(<String>[
      '-y',
      '-i',
      input.path,
      '-ar',
      '$canonicalSampleRateHz',
      '-ac',
      '$canonicalChannels',
      '-c:a',
      'pcm_s16le',
      outputPath,
    ]);

    if (!result.isSuccess) {
      throw FfmpegNormalizeException(
        'ffmpeg normalization failed for ${input.path}',
        result.logs,
      );
    }

    return NormalizedAudio(
      source: input,
      path: result.outputPath,
      sampleRateHz: canonicalSampleRateHz,
      channels: canonicalChannels,
      encoding: canonicalEncoding,
    );
  }
}

class PassthroughAudioNormalizer implements AudioNormalizer {
  const PassthroughAudioNormalizer();

  @override
  Future<NormalizedAudio> normalize(AudioFile input) async {
    return NormalizedAudio(
      source: input,
      path: input.path,
      sampleRateHz: FfmpegAudioNormalizer.canonicalSampleRateHz,
      channels: FfmpegAudioNormalizer.canonicalChannels,
      encoding: FfmpegAudioNormalizer.canonicalEncoding,
    );
  }
}

class RecordingPipeline {
  const RecordingPipeline({
    required AudioCapture capture,
    required AudioNormalizer normalizer,
  }) : _capture = capture,
       _normalizer = normalizer;

  final AudioCapture _capture;
  final AudioNormalizer _normalizer;

  Future<NormalizedAudio> recordAndNormalize({
    required String outputPath,
    required Duration maxDuration,
  }) async {
    final recording = await _capture.record(
      outputPath: outputPath,
      maxDuration: maxDuration,
    );
    return _normalizer.normalize(recording);
  }
}

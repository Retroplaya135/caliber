import 'package:caliber_speech_stack/speech_stack.dart';
import 'package:test/test.dart' as package_test;

import '_test_support.dart';

void main() {
  package_test.test('audio pipeline', runAudioPipelineTests);
}

Future<void> runAudioPipelineTests() async {
  await runTest(
    'ffmpeg normalizer builds canonical 16 kHz mono PCM WAV command',
    () async {
      final runner = _RecordingFfmpegRunner();
      final normalizer = FfmpegAudioNormalizer(
        runner: runner,
        outputPathFor: (input) => '${input.path}.normalized.wav',
      );

      final audio = await normalizer.normalize(
        const AudioFile(path: 'input.m4a'),
      );

      check(audio.path == 'input.m4a.normalized.wav', 'normalized output path');
      check(audio.sampleRateHz == 16000, 'sample rate is 16 kHz');
      check(audio.channels == 1, 'mono channel output');
      check(
        runner.arguments.join(' ') ==
            '-y -i input.m4a -ar 16000 -ac 1 -c:a pcm_s16le input.m4a.normalized.wav',
        'ffmpeg args match whisper.cpp 16-bit WAV requirement',
      );
    },
  );
}

class _RecordingFfmpegRunner implements FfmpegRunner {
  var arguments = <String>[];

  @override
  Future<FfmpegResult> run(List<String> arguments) async {
    this.arguments = List<String>.unmodifiable(arguments);
    return FfmpegResult(exitCode: 0, outputPath: arguments.last);
  }
}

import 'dart:io';

import 'package:caliber_interview/interview.dart';

Future<void> main(List<String> args) async {
  final output = File(
    _argValue(args, '--out') ?? 'build/backend_verdicts.jsonl',
  );
  final limitText = _argValue(args, '--limit');
  final limit = limitText == null ? null : int.parse(limitText);
  final written = await writeBackendVerdictBenchmarkJsonl(
    outputFile: output,
    limit: limit,
  );
  stdout.writeln('Wrote ${written.path}');
}

String? _argValue(List<String> args, String key) {
  final index = args.indexOf(key);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}

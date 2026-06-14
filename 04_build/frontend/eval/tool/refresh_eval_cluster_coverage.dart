import 'dart:io';

Future<void> main() async {
  final dart = Platform.resolvedExecutable;
  final coverageRoot = Directory('coverage');
  final refreshRoot = Directory('${coverageRoot.path}/lcov_trio_refresh');
  final canonicalLcov = File('${coverageRoot.path}/lcov_trio.info');
  final refreshedLcov = File('${refreshRoot.path}/lcov.info');
  final env = <String, String>{
    ...Platform.environment,
    'DART_SUPPRESS_ANALYTICS': 'true',
    'PUB_CACHE': Platform.environment['PUB_CACHE'] ??
        '${Directory.systemTemp.path}/caliber-pub-cache',
  };

  if (refreshRoot.existsSync()) {
    refreshRoot.deleteSync(recursive: true);
  }
  coverageRoot.createSync(recursive: true);

  final coverage = await _run(
    dart,
    const <String>[
      'run',
      'coverage:test_with_coverage',
      '--function-coverage',
      '--branch-coverage',
      '--scope-output=caliber_eval_frontend',
      '--scope-output=caliber_eval_backend',
      '--scope-output=caliber_eval_database',
      '--out=coverage/lcov_trio_refresh',
      '--',
      'test',
    ],
    env,
  );
  if (coverage.exitCode != 0) {
    _writeResult(coverage);
    stderr.writeln(
      'Coverage refresh failed. Dart VM-service coverage collection requires '
      'local socket access; run this command outside sandboxed shells if needed.',
    );
    exitCode = coverage.exitCode;
    return;
  }
  if (!refreshedLcov.existsSync()) {
    stderr.writeln('Coverage refresh did not produce ${refreshedLcov.path}.');
    exitCode = 66;
    return;
  }

  canonicalLcov.writeAsStringSync(refreshedLcov.readAsStringSync());
  refreshRoot.deleteSync(recursive: true);

  final verification = await _run(
    dart,
    const <String>[
      'run',
      'tool/verify_eval_cluster_coverage.dart',
      'coverage/lcov_trio.info',
      '80',
    ],
    env,
  );
  _writeResult(verification);
  if (verification.exitCode != 0) {
    exitCode = verification.exitCode;
  }
}

Future<ProcessResult> _run(
  String executable,
  List<String> arguments,
  Map<String, String> environment,
) {
  return Process.run(executable, arguments, environment: environment);
}

void _writeResult(ProcessResult result) {
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}

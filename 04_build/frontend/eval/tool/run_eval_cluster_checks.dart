import 'dart:io';

Future<void> main(List<String> args) async {
  final refreshCoverage = args.contains('--refresh-coverage');
  final unknownArgs =
      args.where((arg) => arg != '--refresh-coverage').toList(growable: false);
  if (unknownArgs.isNotEmpty) {
    stderr.writeln(
      'Usage: dart run tool/run_eval_cluster_checks.dart [--refresh-coverage]',
    );
    exitCode = 64;
    return;
  }

  final buildRoot = Directory.current.parent.parent;
  final dart = Platform.resolvedExecutable;
  final env = <String, String>{
    ...Platform.environment,
    'DART_SUPPRESS_ANALYTICS': 'true',
    'PUB_CACHE': Platform.environment['PUB_CACHE'] ??
        '${Directory.systemTemp.path}/caliber-pub-cache',
  };

  final checks = <_CommandCheck>[
    _CommandCheck(
      label: 'backend analyze',
      workingDirectory: Directory('${buildRoot.path}/backend'),
      executable: dart,
      arguments: const <String>['analyze', '.'],
      environment: env,
    ),
    _CommandCheck(
      label: 'database analyze',
      workingDirectory: Directory('${buildRoot.path}/database/eval_database'),
      executable: dart,
      arguments: const <String>['analyze', '.'],
      environment: env,
    ),
    _CommandCheck(
      label: 'frontend analyze',
      workingDirectory: Directory.current,
      executable: dart,
      arguments: const <String>['analyze', '.'],
      environment: env,
    ),
    _CommandCheck(
      label: 'custom contract runner',
      workingDirectory: Directory.current,
      executable: dart,
      arguments: const <String>['run', 'test/eval_cluster_test_runner.dart'],
      environment: env,
    ),
    _CommandCheck(
      label: 'package tests',
      workingDirectory: Directory.current,
      executable: dart,
      arguments: const <String>['run', 'test'],
      environment: env,
    ),
    _CommandCheck(
      label: refreshCoverage
          ? 'coverage refresh, freshness, and threshold'
          : 'coverage freshness and threshold from existing LCOV',
      workingDirectory: Directory.current,
      executable: dart,
      arguments: refreshCoverage
          ? const <String>['run', 'tool/refresh_eval_cluster_coverage.dart']
          : const <String>[
              'run',
              'tool/verify_eval_cluster_coverage.dart',
              'coverage/lcov_trio.info',
              '80',
            ],
      environment: env,
    ),
    _CommandCheck(
      label: 'scoped guardrails',
      workingDirectory: Directory.current,
      executable: dart,
      arguments: const <String>[
        'run',
        'tool/verify_eval_cluster_guardrails.dart',
      ],
      environment: env,
    ),
  ];

  final failures = <String>[];
  for (final check in checks) {
    final result = await check.run();
    if (result.exitCode == 0) {
      stdout.writeln('PASS ${check.label}');
    } else {
      stdout.writeln('FAIL ${check.label}');
      stdout.write(result.stdout);
      stderr.write(result.stderr);
      failures.add(check.label);
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln('Eval Cluster checks failed: ${failures.join(', ')}');
    exitCode = 1;
    return;
  }

  final mode = refreshCoverage ? 'coverage-refresh' : 'non-socket';
  stdout.writeln('Eval Cluster $mode checks passed: '
      '${checks.length}/${checks.length}');
}

final class _CommandCheck {
  const _CommandCheck({
    required this.label,
    required this.workingDirectory,
    required this.executable,
    required this.arguments,
    required this.environment,
  });

  final String label;
  final Directory workingDirectory;
  final String executable;
  final List<String> arguments;
  final Map<String, String> environment;

  Future<ProcessResult> run() {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory.path,
      environment: environment,
    );
  }
}

import 'dart:io';

void main() {
  final workspaceRoot = _findWorkspaceRoot();
  final checks = <_GuardrailCheck>[
    _GuardrailCheck(
      name: 'changed files remain inside Eval Cluster scope',
      run: () => _checkChangedFileScope(workspaceRoot),
    ),
    _GuardrailCheck(
      name: 'required handoff artifacts exist',
      run: () => _checkRequiredArtifacts(workspaceRoot),
    ),
    _GuardrailCheck(
      name: 'checkpoint handoff references are recorded',
      run: () => _checkCheckpointReferences(workspaceRoot),
    ),
    _GuardrailCheck(
      name: 'production code has no ad-hoc LLM or network calls',
      run: () => _checkForbiddenProductionPatterns(workspaceRoot),
    ),
    _GuardrailCheck(
      name: 'StructuredJudge remains the only evaluation gateway',
      run: () => _checkStructuredJudgeBoundary(workspaceRoot),
    ),
    _GuardrailCheck(
      name: 'product model pin stays out of production Eval Cluster code',
      run: () => _checkModelPins(workspaceRoot),
    ),
  ];

  final failures = <String>[];
  for (final check in checks) {
    final result = check.run();
    if (result == null) {
      stdout.writeln('PASS ${check.name}');
    } else {
      failures.add('${check.name}: $result');
      stdout.writeln('FAIL ${check.name}');
      stdout.writeln('  $result');
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln('Eval Cluster guardrails failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Eval Cluster guardrails passed: ${checks.length}/${checks.length}',
  );
}

Directory _findWorkspaceRoot() {
  var cursor = Directory.current.absolute;
  while (true) {
    final hasBackend = Directory(
      '${cursor.path}/04_build/backend',
    ).existsSync();
    final hasEval = Directory(
      '${cursor.path}/04_build/frontend/eval',
    ).existsSync();
    if (hasBackend && hasEval) {
      return cursor;
    }

    final parent = cursor.parent;
    if (parent.path == cursor.path) {
      return Directory.current.absolute;
    }
    cursor = parent;
  }
}

String? _checkChangedFileScope(Directory workspaceRoot) {
  final guardrailBase = Platform.environment['CALIBER_GUARDRAIL_BASE']?.trim();
  final diffArgs = _changedFileDiffArgs(workspaceRoot, guardrailBase);
  final result = Process.runSync(
    'git',
    diffArgs,
    workingDirectory: workspaceRoot.path,
  );
  if (result.exitCode != 0) {
    return 'git diff failed: ${result.stderr}';
  }

  final changedFiles = (result.stdout as String)
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  final outsideScope = changedFiles.where((file) {
    if (file == 'pubspec.yaml' || file == 'pubspec.lock') {
      return false;
    }
    if (_isAllowedIntegrationTool(file)) {
      return false;
    }
    return !file.startsWith('04_build/ai_gateway/') &&
        !file.startsWith('04_build/backend/') &&
        !file.startsWith('04_build/database/') &&
        !file.startsWith('04_build/frontend/');
  }).toList();

  if (outsideScope.isNotEmpty) {
    return 'files outside allowed scope: ${outsideScope.join(', ')}';
  }
  return null;
}

bool _isAllowedIntegrationTool(String file) {
  return const <String>{
    'tool/build_web_for_public_gateway.sh',
    'tool/run_public_funnel_demo.sh',
    'tool/read_funnel_readout.sh',
    'tool/run_gate0_benchmark_suite.sh',
    'tool/run_gate0_blind_benchmark.sh',
    'tool/run_web_app_with_gateway.sh',
    'tool/stop_public_funnel_demo.sh',
  }.contains(file);
}

List<String> _changedFileDiffArgs(Directory workspaceRoot, String? base) {
  if (base == null || base.isEmpty || base == 'HEAD') {
    return <String>['diff', '--name-only', 'HEAD'];
  }
  final mergeBase = Process.runSync('git', <String>[
    'merge-base',
    base,
    'HEAD',
  ], workingDirectory: workspaceRoot.path);
  if (mergeBase.exitCode != 0) {
    return <String>['diff', '--name-only', '$base...HEAD'];
  }
  final resolved = (mergeBase.stdout as String).trim();
  if (resolved.isEmpty) {
    return <String>['diff', '--name-only', '$base...HEAD'];
  }
  return <String>['diff', '--name-only', resolved, 'HEAD'];
}

String? _checkRequiredArtifacts(Directory workspaceRoot) {
  final required = <String>[
    '04_build/backend/CHECKPOINT.md',
    '04_build/backend/decisions/'
        'caliber_eval_cluster_dependency_and_contract_decisions_31-05-2026_01_PM_v001_s09_p01_st05_itr01.md',
    '04_build/backend/lib/src/bm25_corpus_retriever.dart',
    '04_build/backend/lib/src/corpus_retriever.dart',
    '04_build/backend/lib/src/corpus_sqlite_bundle_plan.dart',
    '04_build/database/eval_database/CHECKPOINT.md',
    '04_build/database/eval_database/lib/src/user_memory_row_codec.dart',
    '04_build/database/eval_database/lib/src/user_memory_schema.dart',
    '04_build/database/eval_database/lib/src/user_memory_sql_plan.dart',
    '04_build/database/eval_database/lib/src/user_memory_store.dart',
    '04_build/frontend/eval/CHECKPOINT.md',
    '04_build/frontend/eval/MERGE_READINESS.md',
    '04_build/frontend/eval/lib/src/gateway_judge_request_envelope.dart',
    '04_build/frontend/eval/lib/src/interview_engine.dart',
    '04_build/frontend/eval/lib/src/structured_judge.dart',
    '04_build/frontend/eval/test/eval_cluster_test.dart',
    '04_build/frontend/eval/test/eval_cluster_test_runner.dart',
    '04_build/frontend/eval/test/goldens/interview_judgment.md',
    '04_build/frontend/eval/fixtures/adjudication/README.md',
    '04_build/frontend/eval/tool/refresh_eval_cluster_coverage.dart',
    '04_build/frontend/eval/tool/verify_eval_cluster_coverage.dart',
    '04_build/frontend/eval/tool/verify_eval_cluster_guardrails.dart',
  ];

  final missing = required.where((path) {
    return !File('${workspaceRoot.path}/$path').existsSync();
  }).toList();
  if (missing.isNotEmpty) {
    return 'missing required artifacts: ${missing.join(', ')}';
  }
  return null;
}

String? _checkCheckpointReferences(Directory workspaceRoot) {
  final required = <String, List<String>>{
    '04_build/backend/CHECKPOINT.md': <String>[
      'DSAinDart `algorithm_map.md`',
      'sqlite3/drift docs',
      'Storage Sync',
      '`CorpusRetriever`',
    ],
    '04_build/database/eval_database/CHECKPOINT.md': <String>[
      'per-user schema tables',
      '`target_matrix`',
      '`deletion_tombstone`',
      'Drift docs',
      'Fork 09',
    ],
    '04_build/frontend/eval/CHECKPOINT.md': <String>[
      'OpenAI structured-output docs',
      'Riverpod docs',
      'Deep Analysis inverse lessons',
      'Fork 03',
      'Lane AU',
      'Root/Lane G',
    ],
    '04_build/frontend/eval/MERGE_READINESS.md': <String>[
      'Per-user schema',
      'CorpusRetriever contract',
      'Lane AU setup',
      'Eval Cluster subpackages',
      'Fork 09 owns encryption and migration',
    ],
    '04_build/frontend/eval/fixtures/adjudication/README.md': <String>[
      '200 total adjudication cases',
      'Lane AU owns certification',
    ],
  };

  final missing = <String>[];
  for (final entry in required.entries) {
    final file = File('${workspaceRoot.path}/${entry.key}');
    if (!file.existsSync()) {
      missing.add('${entry.key} is missing');
      continue;
    }
    final text = file.readAsStringSync();
    for (final needle in entry.value) {
      if (!text.contains(needle)) {
        missing.add('${entry.key} missing "$needle"');
      }
    }
  }

  if (missing.isNotEmpty) {
    return missing.join('; ');
  }
  return null;
}

String? _checkForbiddenProductionPatterns(Directory workspaceRoot) {
  final productionFiles = <File>[
    ..._dartFiles(Directory('${workspaceRoot.path}/04_build/backend/lib')),
    ..._dartFiles(
      Directory('${workspaceRoot.path}/04_build/database/eval_database/lib'),
    ),
    ..._dartFiles(
      Directory('${workspaceRoot.path}/04_build/frontend/eval/lib'),
    ),
  ];
  final forbidden = <Pattern>[
    RegExp("import\\s+['\\\"]dart:io['\\\"]"),
    RegExp("import\\s+['\\\"]package:http/"),
    RegExp(r'\bOpenAI\b', caseSensitive: false),
    RegExp(r'\bProviderAdapter\b'),
    RegExp(r'\bapiKey\b'),
    RegExp(r'\bbaseUrl\b'),
    RegExp(r'\bchat\.completions\b'),
    RegExp(r'\bresponses\.create\b'),
  ];

  final hits = <String>[];
  for (final file in productionFiles) {
    final text = file.readAsStringSync();
    for (final pattern in forbidden) {
      if (pattern.allMatches(text).isNotEmpty) {
        hits.add('${_relative(workspaceRoot, file)} matches $pattern');
      }
    }
  }

  if (hits.isNotEmpty) {
    return hits.join('; ');
  }
  return null;
}

String? _checkStructuredJudgeBoundary(Directory workspaceRoot) {
  final frontendLib = Directory(
    '${workspaceRoot.path}/04_build/frontend/eval/lib',
  );
  final libText = _dartFiles(
    frontendLib,
  ).map((file) => file.readAsStringSync()).join('\n');

  final requestCalls = RegExp(
    r'\.judgeInterviewContent\s*\(',
  ).allMatches(libText).length;
  if (requestCalls != 1) {
    return 'expected exactly one production StructuredJudge call, '
        'found $requestCalls';
  }

  final productionImplementations = RegExp(
    r'implements\s+StructuredJudge',
  ).allMatches(libText).length;
  if (productionImplementations != 0) {
    return 'production code must not implement StructuredJudge provider calls';
  }

  final testText = _dartFiles(
    Directory('${workspaceRoot.path}/04_build/frontend/eval/test'),
  ).map((file) => file.readAsStringSync()).join('\n');
  if (!testText.contains('implements StructuredJudge')) {
    return 'tests must keep a fake StructuredJudge implementation '
        'for contract proof';
  }
  return null;
}

String? _checkModelPins(Directory workspaceRoot) {
  final productionText = <Directory>[
    Directory('${workspaceRoot.path}/04_build/backend/lib'),
    Directory('${workspaceRoot.path}/04_build/database/eval_database/lib'),
    Directory('${workspaceRoot.path}/04_build/frontend/eval/lib'),
  ].expand(_dartFiles).map((file) => file.readAsStringSync()).join('\n');

  if (productionText.contains('gpt-5.4-mini') ||
      productionText.contains('gpt-5.5')) {
    return 'model ids must remain behind StructuredJudge/Product ProviderAdapter, '
        'not production Eval Cluster code';
  }

  final testText = _dartFiles(
    Directory('${workspaceRoot.path}/04_build/frontend/eval/test'),
  ).map((file) => file.readAsStringSync()).join('\n');
  if (!testText.contains('gpt-5.4-mini')) {
    return 'tests must preserve the product model pin evidence';
  }
  if (testText.contains('gpt-5.5')) {
    return 'tests must not conflate harness gpt-5.5 with product runtime model';
  }
  return null;
}

List<File> _dartFiles(Directory directory) {
  if (!directory.existsSync()) return const <File>[];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
}

String _relative(Directory root, File file) {
  final prefix = '${root.path}/';
  return file.path.startsWith(prefix)
      ? file.path.substring(prefix.length)
      : file.path;
}

final class _GuardrailCheck {
  const _GuardrailCheck({required this.name, required this.run});

  final String name;
  final String? Function() run;
}

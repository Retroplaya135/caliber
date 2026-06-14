import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/verify_eval_cluster_coverage.dart <lcov.info> <minimum_percent>',
    );
    exitCode = 64;
    return;
  }

  final report = File(args[0]);
  if (!report.existsSync()) {
    stderr.writeln('Coverage report not found: ${args[0]}');
    exitCode = 66;
    return;
  }

  final minimum = double.tryParse(args[1]);
  if (minimum == null || minimum < 0 || minimum > 100) {
    stderr.writeln('Coverage minimum must be a number from 0 to 100.');
    exitCode = 64;
    return;
  }

  late final _CoverageReport coverage;
  try {
    coverage = _readLcov(report.readAsLinesSync());
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 65;
    return;
  }

  if (coverage.totals.found == 0) {
    stderr.writeln('Coverage report has no executable lines.');
    exitCode = 65;
    return;
  }

  late final List<String> missingSources;
  try {
    missingSources = _missingProductionSources(coverage.sources);
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 66;
    return;
  }
  if (missingSources.isNotEmpty) {
    stderr.writeln(
      'Coverage report is stale or incomplete; missing source files:',
    );
    for (final source in missingSources) {
      stderr.writeln('- $source');
    }
    exitCode = 65;
    return;
  }

  final percent = coverage.totals.percent;
  if (percent < minimum) {
    stderr.writeln(
      'Coverage FAIL: ${percent.toStringAsFixed(2)}% < ${minimum.toStringAsFixed(2)}% '
      '(${coverage.totals.hit}/${coverage.totals.found})',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Coverage PASS: ${percent.toStringAsFixed(2)}% >= ${minimum.toStringAsFixed(2)}% '
    'across ${coverage.totals.files} files '
    '(${coverage.totals.hit}/${coverage.totals.found})',
  );
}

_CoverageReport _readLcov(List<String> lines) {
  var files = 0;
  var hit = 0;
  var found = 0;
  final sources = <String>{};

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      files += 1;
      final source = _normalizeSourcePath(line.substring(3));
      if (source.isNotEmpty) {
        sources.add(source);
      }
      continue;
    }
    if (line.startsWith('LH:')) {
      hit += _parsePositiveInt(line, 'LH');
      continue;
    }
    if (line.startsWith('LF:')) {
      found += _parsePositiveInt(line, 'LF');
    }
  }

  return _CoverageReport(
    totals: _CoverageTotals(files: files, hit: hit, found: found),
    sources: sources,
  );
}

int _parsePositiveInt(String line, String prefix) {
  final value = int.tryParse(line.substring(prefix.length + 1));
  if (value == null || value < 0) {
    throw FormatException('Invalid $prefix coverage line: $line');
  }
  return value;
}

List<String> _missingProductionSources(Set<String> coveredSources) {
  final buildRoot = _findBuildRoot();
  final expectedSources = <String>[
    ..._moduleSourceFiles(buildRoot, 'backend/lib/src'),
    ..._moduleSourceFiles(buildRoot, 'database/eval_database/lib/src'),
    ..._moduleSourceFiles(buildRoot, 'frontend/eval/lib/src'),
  ]..sort();

  return expectedSources
      .where((source) => !coveredSources.contains(source))
      .toList();
}

Directory _findBuildRoot() {
  var directory = Directory.current;
  for (var depth = 0; depth < 6; depth += 1) {
    if (_hasEvalClusterModules(directory)) {
      return directory;
    }

    final buildCandidate = Directory('${directory.path}/04_build');
    if (_hasEvalClusterModules(buildCandidate)) {
      return buildCandidate;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      break;
    }
    directory = parent;
  }

  throw StateError(
    'Could not locate Eval Cluster build root from ${Directory.current.path}.',
  );
}

bool _hasEvalClusterModules(Directory directory) {
  return Directory('${directory.path}/backend/lib/src').existsSync() &&
      Directory('${directory.path}/database/eval_database/lib/src')
          .existsSync() &&
      Directory('${directory.path}/frontend/eval/lib/src').existsSync();
}

List<String> _moduleSourceFiles(Directory buildRoot, String sourcePath) {
  final sourceRoot = Directory('${buildRoot.path}/$sourcePath');
  if (!sourceRoot.existsSync()) {
    return const <String>[];
  }

  return sourceRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => _relativeSourcePath(buildRoot, file))
      .toList();
}

String _relativeSourcePath(Directory buildRoot, File file) {
  final buildRootPath = _normalizePath(buildRoot.path);
  final filePath = _normalizePath(file.path);
  final prefix = '$buildRootPath/';
  if (filePath.startsWith(prefix)) {
    return filePath.substring(prefix.length);
  }
  return _normalizeSourcePath(filePath);
}

String _normalizeSourcePath(String path) {
  var normalized = _normalizePath(path.trim());
  while (normalized.startsWith('./')) {
    normalized = normalized.substring(2);
  }

  const buildMarker = '/04_build/';
  final buildIndex = normalized.indexOf(buildMarker);
  if (buildIndex >= 0) {
    normalized = normalized.substring(buildIndex + buildMarker.length);
  }

  for (final module in const <String>['backend', 'database', 'frontend']) {
    final moduleMarker = '$module/lib/';
    final moduleIndex = normalized.indexOf(moduleMarker);
    if (moduleIndex >= 0) {
      return normalized.substring(moduleIndex);
    }
  }

  return normalized;
}

String _normalizePath(String path) => path.replaceAll('\\', '/');

final class _CoverageReport {
  const _CoverageReport({required this.totals, required this.sources});

  final _CoverageTotals totals;
  final Set<String> sources;
}

final class _CoverageTotals {
  const _CoverageTotals({
    required this.files,
    required this.hit,
    required this.found,
  });

  final int files;
  final int hit;
  final int found;

  double get percent => hit * 100 / found;
}

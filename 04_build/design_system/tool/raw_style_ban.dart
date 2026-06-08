import 'dart:io';

const _excludedPathParts = {'src/tokens'};

final _bannedPatterns = <String, RegExp>{
  'raw Color constructor': RegExp(r'\bColor\s*\('),
  'Material Colors token': RegExp(r'\bColors\.'),
  'raw EdgeInsets': RegExp(r'\bEdgeInsets\.[^(]*\([^)]*\d'),
  'raw BorderRadius': RegExp(r'\bBorderRadius\.'),
  'raw Radius': RegExp(r'\bRadius\.'),
  'raw Duration': RegExp(r'\bDuration\s*\('),
  'raw SizedBox dimension': RegExp(r'SizedBox\s*\([^)]*(height|width)\s*:\s*\d'),
};

void main() {
  final lib = Directory('lib');
  if (!lib.existsSync()) {
    stderr.writeln('raw-style-ban: lib/ directory not found.');
    exitCode = 1;
    return;
  }

  final violations = <String>[];
  for (final entity in lib.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    if (_excludedPathParts.any(entity.path.contains)) {
      continue;
    }
    final lines = entity.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      for (final entry in _bannedPatterns.entries) {
        if (entry.value.hasMatch(line)) {
          violations.add(
            '${entity.path}:${index + 1}: ${entry.key}: ${line.trim()}',
          );
        }
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Raw style values are only allowed in lib/src/tokens.');
    stderr.writeln(violations.join('\n'));
    exitCode = 1;
  }
}

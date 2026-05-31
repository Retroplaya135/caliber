import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

typedef DriftMigrationForward =
    Future<void> Function(GeneratedDatabase database, Migrator migrator);

typedef RawSqlRollback = Future<void> Function(sqlite.Database database);

final class CaliberMigrationStep {
  const CaliberMigrationStep({
    required this.fromVersion,
    required this.toVersion,
    required this.description,
    required this.forward,
    required this.rollback,
  });

  final int fromVersion;
  final int toVersion;
  final String description;
  final DriftMigrationForward forward;
  final RawSqlRollback rollback;
}

final class StepwiseMigrationPlan {
  const StepwiseMigrationPlan(this.steps);

  final List<CaliberMigrationStep> steps;

  Future<void> apply({
    required GeneratedDatabase database,
    required Migrator migrator,
    required int from,
    required int to,
  }) async {
    final ordered = stepsForUpgrade(from: from, to: to);
    for (final step in ordered) {
      await step.forward(database, migrator);
    }
  }

  Future<void> rollback({
    required sqlite.Database database,
    required int from,
    required int to,
  }) async {
    final ordered = stepsForUpgrade(from: from, to: to).reversed;
    for (final step in ordered) {
      await step.rollback(database);
    }
  }

  List<CaliberMigrationStep> stepsForUpgrade({
    required int from,
    required int to,
  }) {
    if (from == to) {
      return const [];
    }
    if (from > to) {
      throw ArgumentError.value(from, 'from', 'must be <= to');
    }

    final selected = <CaliberMigrationStep>[];
    var cursor = from;
    while (cursor < to) {
      final step = steps.where((candidate) {
        return candidate.fromVersion == cursor &&
            candidate.toVersion == cursor + 1;
      }).singleOrNull;

      if (step == null) {
        throw StateError(
          'Missing migration step from $cursor to ${cursor + 1}.',
        );
      }

      selected.add(step);
      cursor = step.toVersion;
    }

    return selected;
  }
}

extension _SingleOrNull<T> on Iterable<T> {
  T? get singleOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    final value = iterator.current;
    if (iterator.moveNext()) {
      throw StateError('More than one matching migration step.');
    }
    return value;
  }
}

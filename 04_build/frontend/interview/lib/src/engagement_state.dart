import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'calibration_policy.dart';
import 'interview_memory.dart';
import 'interview_question.dart';

const kBackendEngagementStateVersion = 'backend_calibration_engagement.v0.1';
const kPrepSprintPolicyVersion = 'prep_sprint_90_day.v0.1';
const kShareWinRedactionPolicyVersion = 'share_win_redacted_archetype.v0.1';

final class CalibrationEngagementEvent {
  const CalibrationEngagementEvent({
    required this.eventId,
    required this.type,
    required this.profileId,
    required this.questionId,
    required this.judgmentId,
    required this.levelBand,
    required this.createdAt,
    required this.policy,
    this.comparisonSummary = const <String>[],
    this.shareOptIn = false,
  });

  factory CalibrationEngagementEvent.verdictRecorded({
    required schema.InterviewContentJudgment judgment,
    InterviewRoundComparison? comparison,
    bool shareOptIn = false,
  }) {
    return CalibrationEngagementEvent(
      eventId: 'verdict:${judgment.judgmentId}',
      type: 'verdict_recorded',
      profileId: judgment.profileId,
      questionId: judgment.questionId,
      judgmentId: judgment.judgmentId,
      levelBand: _normalizedBand(judgment.levelBand),
      createdAt: judgment.createdAt,
      policy: CalibrationPolicyTuple.fromJudgment(judgment),
      comparisonSummary: comparison?.summaryBullets ?? const <String>[],
      shareOptIn: shareOptIn,
    );
  }

  final String eventId;
  final String type;
  final String profileId;
  final String questionId;
  final String judgmentId;
  final String levelBand;
  final DateTime createdAt;
  final CalibrationPolicyTuple policy;
  final List<String> comparisonSummary;
  final bool shareOptIn;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'event_id': eventId,
      'type': type,
      'profile_id': profileId,
      'question_id': questionId,
      'judgment_id': judgmentId,
      'level_band': levelBand,
      'created_at': createdAt.toIso8601String(),
      'policy': policy.toJson(),
      'comparison_summary': comparisonSummary,
      'share_opt_in': shareOptIn,
    };
  }
}

final class ArchetypeProgressViewModel {
  const ArchetypeProgressViewModel({
    required this.questionId,
    required this.title,
    required this.levelBand,
    required this.attemptCount,
    required this.lastAttemptAt,
    required this.clearedAt,
    required this.policy,
  });

  final String questionId;
  final String title;
  final String levelBand;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final DateTime? clearedAt;
  final CalibrationPolicyTuple? policy;

  bool get isClearedAtBar => levelBand == 'at_bar';

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'title': title,
      'level_band': levelBand,
      'attempt_count': attemptCount,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'cleared_at': clearedAt?.toIso8601String(),
      'is_cleared_at_bar': isClearedAtBar,
      'policy': policy?.toJson(),
    };
  }
}

final class MasteryMapViewModel {
  const MasteryMapViewModel({required this.cells});

  final List<ArchetypeProgressViewModel> cells;

  int get totalArchetypes => cells.length;
  int get clearedAtBarCount =>
      cells.where((cell) => cell.isClearedAtBar).length;
  int get remainingAtBarCount => totalArchetypes - clearedAtBarCount;

  String? get nudge {
    if (remainingAtBarCount == 1) {
      return '1 archetype from completing the Backend map.';
    }
    return null;
  }

  String get completionLabel =>
      '$clearedAtBarCount of $totalArchetypes Backend archetypes at the bar.';

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'total_archetypes': totalArchetypes,
      'cleared_at_bar_count': clearedAtBarCount,
      'remaining_at_bar_count': remainingAtBarCount,
      'completion_label': completionLabel,
      'nudge': nudge,
      'cells': cells.map((cell) => cell.toJson()).toList(growable: false),
    };
  }
}

final class BreakthroughViewModel {
  const BreakthroughViewModel({
    required this.questionId,
    required this.title,
    required this.judgmentId,
    required this.achievedAt,
    required this.message,
  });

  final String questionId;
  final String title;
  final String judgmentId;
  final DateTime achievedAt;
  final String message;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'title': title,
      'judgment_id': judgmentId,
      'achieved_at': achievedAt.toIso8601String(),
      'message': message,
    };
  }
}

final class EngagementDeltaViewModel {
  const EngagementDeltaViewModel({
    required this.previousJudgmentId,
    required this.currentJudgmentId,
    required this.message,
  });

  factory EngagementDeltaViewModel.fromComparison(
    InterviewRoundComparison comparison,
  ) {
    final message = _deltaMessage(comparison);
    return EngagementDeltaViewModel(
      previousJudgmentId: comparison.previousJudgmentId,
      currentJudgmentId: comparison.currentJudgmentId,
      message: message,
    );
  }

  final String previousJudgmentId;
  final String currentJudgmentId;
  final String message;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'previous_judgment_id': previousJudgmentId,
      'current_judgment_id': currentJudgmentId,
      'message': message,
    };
  }
}

final class RetestRecommendationViewModel {
  const RetestRecommendationViewModel({
    required this.questionId,
    required this.title,
    required this.reason,
    required this.dueAt,
  });

  final String questionId;
  final String title;
  final String reason;
  final DateTime dueAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'title': title,
      'reason': reason,
      'due_at': dueAt.toIso8601String(),
    };
  }
}

final class PrepSprintViewModel {
  const PrepSprintViewModel({
    required this.policyVersion,
    required this.startedAt,
    required this.endsAt,
    required this.interviewDate,
    required this.daysRemaining,
    required this.nextRetestAt,
    required this.message,
  });

  factory PrepSprintViewModel.forNinetyDayPass({
    required DateTime now,
    required RetestRecommendationViewModel nextRetest,
    DateTime? passStartedAt,
    DateTime? interviewDate,
  }) {
    final start = passStartedAt ?? now;
    final end = start.add(const Duration(days: 90));
    final target = interviewDate ?? end;
    final remaining = target.difference(now).inDays.clamp(0, 90).toInt();
    final nextRetestAt = _minDateTime(
      nextRetest.dueAt,
      now.add(const Duration(days: 3)),
      target,
    );
    return PrepSprintViewModel(
      policyVersion: kPrepSprintPolicyVersion,
      startedAt: start,
      endsAt: end,
      interviewDate: target,
      daysRemaining: remaining,
      nextRetestAt: nextRetestAt,
      message:
          'Retest ${nextRetest.title} next; it is the current weakest Backend archetype.',
    );
  }

  final String policyVersion;
  final DateTime startedAt;
  final DateTime endsAt;
  final DateTime interviewDate;
  final int daysRemaining;
  final DateTime nextRetestAt;
  final String message;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'policy_version': policyVersion,
      'started_at': startedAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'interview_date': interviewDate.toIso8601String(),
      'days_remaining': daysRemaining,
      'next_retest_at': nextRetestAt.toIso8601String(),
      'message': message,
    };
  }
}

final class ShareableWinViewModel {
  const ShareableWinViewModel({
    required this.questionId,
    required this.judgmentId,
    required this.createdAt,
    required this.text,
    required this.redactionPolicyVersion,
  });

  final String questionId;
  final String judgmentId;
  final DateTime createdAt;
  final String text;
  final String redactionPolicyVersion;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'judgment_id': judgmentId,
      'created_at': createdAt.toIso8601String(),
      'text': text,
      'redaction_policy_version': redactionPolicyVersion,
    };
  }
}

final class BackendEngagementStateViewModel {
  const BackendEngagementStateViewModel({
    required this.schemaVersion,
    required this.profileId,
    required this.masteryMap,
    required this.breakthroughs,
    required this.latestDelta,
    required this.nextRetest,
    required this.prepSprint,
    required this.shareableWins,
    required this.updatedAt,
  });

  final String schemaVersion;
  final String profileId;
  final MasteryMapViewModel masteryMap;
  final List<BreakthroughViewModel> breakthroughs;
  final EngagementDeltaViewModel? latestDelta;
  final RetestRecommendationViewModel nextRetest;
  final PrepSprintViewModel prepSprint;
  final List<ShareableWinViewModel> shareableWins;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schema_version': schemaVersion,
      'profile_id': profileId,
      'mastery_map': masteryMap.toJson(),
      'breakthroughs': breakthroughs
          .map((breakthrough) => breakthrough.toJson())
          .toList(growable: false),
      'latest_delta': latestDelta?.toJson(),
      'next_retest': nextRetest.toJson(),
      'prep_sprint': prepSprint.toJson(),
      'shareable_wins': shareableWins
          .map((win) => win.toJson())
          .toList(growable: false),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

BackendEngagementStateViewModel buildBackendEngagementState({
  required String profileId,
  required Iterable<CalibrationEngagementEvent> events,
  DateTime? now,
  DateTime? passStartedAt,
  DateTime? interviewDate,
  List<InterviewPracticeQuestion>? catalog,
}) {
  final currentTime = now ?? DateTime.now().toUtc();
  final questions = List<InterviewPracticeQuestion>.unmodifiable(
    catalog ?? kBackendDepthPracticeQuestions,
  );
  final questionById = <String, InterviewPracticeQuestion>{
    for (final question in questions) question.questionId: question,
  };
  final sortedEvents =
      events
          .where((event) => event.profileId == profileId)
          .toList(growable: false)
        ..sort(_compareEvents);
  final eventsByQuestion = <String, List<CalibrationEngagementEvent>>{};
  for (final event in sortedEvents) {
    eventsByQuestion
        .putIfAbsent(event.questionId, () => <CalibrationEngagementEvent>[])
        .add(event);
  }
  final cells = <ArchetypeProgressViewModel>[
    for (final question in questions)
      _progressCell(question, eventsByQuestion[question.questionId]),
  ];
  final masteryMap = MasteryMapViewModel(
    cells: List<ArchetypeProgressViewModel>.unmodifiable(cells),
  );
  final nextRetest = _nextRetest(cells: cells, now: currentTime);
  final prepSprint = PrepSprintViewModel.forNinetyDayPass(
    now: currentTime,
    nextRetest: nextRetest,
    passStartedAt: passStartedAt,
    interviewDate: interviewDate,
  );
  return BackendEngagementStateViewModel(
    schemaVersion: kBackendEngagementStateVersion,
    profileId: profileId,
    masteryMap: masteryMap,
    breakthroughs: List<BreakthroughViewModel>.unmodifiable(
      _breakthroughs(sortedEvents, questionById),
    ),
    latestDelta: _latestDelta(sortedEvents),
    nextRetest: nextRetest,
    prepSprint: prepSprint,
    shareableWins: List<ShareableWinViewModel>.unmodifiable(
      _shareableWins(sortedEvents, questionById),
    ),
    updatedAt: currentTime,
  );
}

ArchetypeProgressViewModel _progressCell(
  InterviewPracticeQuestion question,
  List<CalibrationEngagementEvent>? events,
) {
  final items = events ?? const <CalibrationEngagementEvent>[];
  CalibrationEngagementEvent? best;
  CalibrationEngagementEvent? latest;
  CalibrationEngagementEvent? firstCleared;
  for (final event in items) {
    if (latest == null || event.createdAt.isAfter(latest.createdAt)) {
      latest = event;
    }
    if (best == null ||
        _bandRank(event.levelBand) > _bandRank(best.levelBand)) {
      best = event;
    }
    if (event.levelBand == 'at_bar' && firstCleared == null) {
      firstCleared = event;
    }
  }
  return ArchetypeProgressViewModel(
    questionId: question.questionId,
    title: _displayTitle(question.title),
    levelBand: best?.levelBand ?? 'not_attempted',
    attemptCount: items.length,
    lastAttemptAt: latest?.createdAt,
    clearedAt: firstCleared?.createdAt,
    policy: latest?.policy,
  );
}

RetestRecommendationViewModel _nextRetest({
  required List<ArchetypeProgressViewModel> cells,
  required DateTime now,
}) {
  final sorted = cells.toList(growable: false)
    ..sort((left, right) {
      final rank = _bandRank(
        left.levelBand,
      ).compareTo(_bandRank(right.levelBand));
      if (rank != 0) return rank;
      final leftLast = left.lastAttemptAt;
      final rightLast = right.lastAttemptAt;
      if (leftLast == null && rightLast == null) {
        return left.questionId.compareTo(right.questionId);
      }
      if (leftLast == null) return -1;
      if (rightLast == null) return 1;
      return leftLast.compareTo(rightLast);
    });
  final weakest = sorted.first;
  return RetestRecommendationViewModel(
    questionId: weakest.questionId,
    title: weakest.title,
    reason: switch (weakest.levelBand) {
      'not_attempted' => 'No recorded attempt yet.',
      'below_bar' => 'Lowest current calibration band.',
      'approaching' => 'Closest non-cleared archetype.',
      _ => 'Oldest cleared archetype scheduled for maintenance.',
    },
    dueAt: _nextDueAt(weakest, now),
  );
}

List<BreakthroughViewModel> _breakthroughs(
  List<CalibrationEngagementEvent> events,
  Map<String, InterviewPracticeQuestion> questionById,
) {
  final seenAtBar = <String>{};
  final breakthroughs = <BreakthroughViewModel>[];
  for (final event in events) {
    if (event.levelBand != 'at_bar' || !seenAtBar.add(event.questionId)) {
      continue;
    }
    final title = _displayTitle(
      questionById[event.questionId]?.title ?? event.questionId,
    );
    breakthroughs.add(
      BreakthroughViewModel(
        questionId: event.questionId,
        title: title,
        judgmentId: event.judgmentId,
        achievedAt: event.createdAt,
        message: 'First at-bar verdict on $title.',
      ),
    );
  }
  return breakthroughs;
}

EngagementDeltaViewModel? _latestDelta(
  List<CalibrationEngagementEvent> events,
) {
  for (final event in events.reversed) {
    if (event.comparisonSummary.isEmpty) continue;
    final previousId = _extractJudgmentId(event.comparisonSummary, 'previous');
    return EngagementDeltaViewModel(
      previousJudgmentId: previousId ?? 'previous:${event.questionId}',
      currentJudgmentId: event.judgmentId,
      message: _firstSpecificDelta(event.comparisonSummary),
    );
  }
  return null;
}

List<ShareableWinViewModel> _shareableWins(
  List<CalibrationEngagementEvent> events,
  Map<String, InterviewPracticeQuestion> questionById,
) {
  final wins = <ShareableWinViewModel>[];
  final emittedByQuestion = <String>{};
  for (final event in events) {
    if (!event.shareOptIn ||
        event.levelBand != 'at_bar' ||
        !emittedByQuestion.add(event.questionId)) {
      continue;
    }
    final title = _displayTitle(
      questionById[event.questionId]?.title ?? event.questionId,
    );
    wins.add(
      ShareableWinViewModel(
        questionId: event.questionId,
        judgmentId: event.judgmentId,
        createdAt: event.createdAt,
        text: 'Hit the senior bar on $title.',
        redactionPolicyVersion: kShareWinRedactionPolicyVersion,
      ),
    );
  }
  return wins;
}

String _deltaMessage(InterviewRoundComparison comparison) {
  if (comparison.resolvedRisks.isNotEmpty) {
    return 'You closed ${_cleanDelta(comparison.resolvedRisks.first)} from last attempt.';
  }
  if (comparison.newStrengths.isNotEmpty) {
    return 'You added ${_cleanDelta(comparison.newStrengths.first)} since last attempt.';
  }
  if (_bandRank(comparison.currentLevelBand) >
      _bandRank(comparison.previousLevelBand)) {
    return 'You moved from ${comparison.previousLevelBand} to ${comparison.currentLevelBand}.';
  }
  if (comparison.persistentRisks.isNotEmpty) {
    return 'Still exposed: ${_cleanDelta(comparison.persistentRisks.first)}.';
  }
  return 'Calibration stayed ${comparison.currentLevelBand} on this archetype.';
}

String _firstSpecificDelta(List<String> summary) {
  for (final item in summary) {
    if (item.startsWith('Resolved risk:')) {
      return 'You closed ${_cleanDelta(item.substring('Resolved risk:'.length))} from last attempt.';
    }
  }
  for (final item in summary) {
    if (item.startsWith('New strength:')) {
      return 'You added ${_cleanDelta(item.substring('New strength:'.length))} since last attempt.';
    }
  }
  return summary.first;
}

String? _extractJudgmentId(List<String> summary, String prefix) {
  for (final item in summary) {
    if (item.startsWith('$prefix:')) {
      return item.substring(prefix.length + 1).trim();
    }
  }
  return null;
}

String _normalizedBand(String value) {
  return switch (value) {
    'at_bar' || 'above_bar' || 'reads L6' => 'at_bar',
    'approaching' || 'reads L5, not L6' => 'approaching',
    'below_bar' || 'reads below L5' => 'below_bar',
    _ => value,
  };
}

int _bandRank(String value) {
  return switch (_normalizedBand(value)) {
    'at_bar' => 2,
    'approaching' => 1,
    'below_bar' => 0,
    _ => -1,
  };
}

DateTime _nextDueAt(ArchetypeProgressViewModel cell, DateTime now) {
  return switch (cell.levelBand) {
    'not_attempted' => now,
    'below_bar' => now.add(const Duration(days: 1)),
    'approaching' => now.add(const Duration(days: 3)),
    _ => now.add(const Duration(days: 14)),
  };
}

DateTime _minDateTime(DateTime first, DateTime second, DateTime third) {
  var current = first.isBefore(second) ? first : second;
  current = current.isBefore(third) ? current : third;
  return current;
}

String _displayTitle(String title) {
  return title
      .replaceFirst('Backend depth round: ', '')
      .replaceFirst('Backend depth: ', '')
      .trim();
}

String _cleanDelta(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').replaceAll('.', '');
}

int _compareEvents(
  CalibrationEngagementEvent left,
  CalibrationEngagementEvent right,
) {
  final byTime = left.createdAt.compareTo(right.createdAt);
  if (byTime != 0) return byTime;
  return left.eventId.compareTo(right.eventId);
}

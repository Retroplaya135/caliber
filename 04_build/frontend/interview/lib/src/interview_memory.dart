import 'package:caliber_shared/caliber_shared.dart' as schema;

abstract interface class InterviewRoundMemoryStore {
  Future<schema.InterviewContentJudgment?> latest({
    required String profileId,
    required String questionId,
  });

  Future<List<schema.InterviewContentJudgment>> history({
    required String profileId,
    required String questionId,
  });

  Future<void> record(schema.InterviewContentJudgment judgment);
}

final class InMemoryInterviewRoundMemoryStore
    implements InterviewRoundMemoryStore {
  InMemoryInterviewRoundMemoryStore({this.maxJudgmentsPerKey = 8})
    : assert(maxJudgmentsPerKey > 0, 'maxJudgmentsPerKey must be positive');

  final int maxJudgmentsPerKey;
  final Map<String, List<schema.InterviewContentJudgment>> _history =
      <String, List<schema.InterviewContentJudgment>>{};

  @override
  Future<schema.InterviewContentJudgment?> latest({
    required String profileId,
    required String questionId,
  }) {
    final items = _history[_key(profileId: profileId, questionId: questionId)];
    if (items == null || items.isEmpty) {
      return Future<schema.InterviewContentJudgment?>.value();
    }
    return Future<schema.InterviewContentJudgment?>.value(items.last);
  }

  @override
  Future<List<schema.InterviewContentJudgment>> history({
    required String profileId,
    required String questionId,
  }) {
    final items = _history[_key(profileId: profileId, questionId: questionId)];
    if (items == null || items.isEmpty) {
      return Future<List<schema.InterviewContentJudgment>>.value(
        const <schema.InterviewContentJudgment>[],
      );
    }
    return Future<List<schema.InterviewContentJudgment>>.value(
      List<schema.InterviewContentJudgment>.unmodifiable(items),
    );
  }

  @override
  Future<void> record(schema.InterviewContentJudgment judgment) {
    final items = _history.putIfAbsent(
      _key(profileId: judgment.profileId, questionId: judgment.questionId),
      () => <schema.InterviewContentJudgment>[],
    );
    items.add(judgment);
    if (items.length > maxJudgmentsPerKey) {
      items.removeRange(0, items.length - maxJudgmentsPerKey);
    }
    return Future<void>.value();
  }
}

final class InterviewRoundComparison {
  const InterviewRoundComparison({
    required this.previousJudgmentId,
    required this.currentJudgmentId,
    required this.previousLevelBand,
    required this.currentLevelBand,
    required this.retainedStrengths,
    required this.newStrengths,
    required this.persistentRisks,
    required this.resolvedRisks,
  });

  factory InterviewRoundComparison.compare({
    required schema.InterviewContentJudgment previous,
    required schema.InterviewContentJudgment current,
  }) {
    final previousStrengths = _normalizedItems(previous.strengths);
    final currentStrengths = _normalizedItems(current.strengths);
    final previousRisks = _normalizedItems(previous.risks);
    final currentRisks = _normalizedItems(current.risks);
    return InterviewRoundComparison(
      previousJudgmentId: previous.judgmentId,
      currentJudgmentId: current.judgmentId,
      previousLevelBand: previous.levelBand,
      currentLevelBand: current.levelBand,
      retainedStrengths: _intersection(currentStrengths, previousStrengths),
      newStrengths: _difference(currentStrengths, previousStrengths),
      persistentRisks: _intersection(currentRisks, previousRisks),
      resolvedRisks: _difference(previousRisks, currentRisks),
    );
  }

  final String previousJudgmentId;
  final String currentJudgmentId;
  final String previousLevelBand;
  final String currentLevelBand;
  final List<String> retainedStrengths;
  final List<String> newStrengths;
  final List<String> persistentRisks;
  final List<String> resolvedRisks;

  List<String> get summaryBullets {
    return <String>[
      if (previousLevelBand == currentLevelBand)
        'Calibration stayed $currentLevelBand against the previous round.'
      else
        'Calibration moved from $previousLevelBand to $currentLevelBand.',
      if (newStrengths.isNotEmpty) 'New strength: ${newStrengths.first}.',
      if (retainedStrengths.isNotEmpty)
        'Repeated strength: ${retainedStrengths.first}.',
      if (resolvedRisks.isNotEmpty) 'Resolved risk: ${resolvedRisks.first}.',
      if (persistentRisks.isNotEmpty)
        'Still exposed: ${persistentRisks.first}.',
    ];
  }
}

Future<InterviewRoundComparison?> rememberInterviewJudgment({
  required InterviewRoundMemoryStore memoryStore,
  required schema.InterviewContentJudgment judgment,
}) async {
  final previous = await memoryStore.latest(
    profileId: judgment.profileId,
    questionId: judgment.questionId,
  );
  await memoryStore.record(judgment);
  if (previous == null) {
    return null;
  }
  return InterviewRoundComparison.compare(
    previous: previous,
    current: judgment,
  );
}

String _key({required String profileId, required String questionId}) {
  return '$profileId::$questionId';
}

List<String> _normalizedItems(List<String> values) {
  final items = <String>[];
  final seen = <String>{};
  for (final value in values) {
    final normalized = _withoutCategory(value).trim();
    if (normalized.isEmpty) continue;
    final key = normalized.toLowerCase();
    if (seen.add(key)) {
      items.add(normalized);
    }
  }
  return List<String>.unmodifiable(items);
}

String _withoutCategory(String value) {
  final separator = value.indexOf(':');
  if (separator < 0) {
    return value;
  }
  return value.substring(separator + 1);
}

List<String> _intersection(List<String> left, List<String> right) {
  final rightKeys = right.map((item) => item.toLowerCase()).toSet();
  return List<String>.unmodifiable(
    left.where((item) => rightKeys.contains(item.toLowerCase())),
  );
}

List<String> _difference(List<String> left, List<String> right) {
  final rightKeys = right.map((item) => item.toLowerCase()).toSet();
  return List<String>.unmodifiable(
    left.where((item) => !rightKeys.contains(item.toLowerCase())),
  );
}

import 'dart:convert';

import 'package:caliber_interview/interview.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:test/test.dart';

void main() {
  test('engagement state is grounded in verdict bands and serializable', () {
    final now = DateTime.utc(2026, 6, 5, 12);
    final catalog = kBackendDepthPracticeQuestions.take(2).toList();
    final first = _judgment(
      judgmentId: 'j1',
      questionId: catalog.first.questionId,
      levelBand: 'below_bar',
      createdAt: now.subtract(const Duration(days: 2)),
      risks: const <String>['Content: misses failure modes.'],
    );
    final second = _judgment(
      judgmentId: 'j2',
      questionId: catalog.first.questionId,
      levelBand: 'at_bar',
      createdAt: now,
      strengths: const <String>['Content: failure modes covered.'],
    );
    final comparison = InterviewRoundComparison.compare(
      previous: first,
      current: second,
    );

    final state = buildBackendEngagementState(
      profileId: 'profile-1',
      catalog: catalog,
      now: now,
      passStartedAt: DateTime.utc(2026, 6, 1),
      interviewDate: DateTime.utc(2026, 6, 20, 12),
      events: <CalibrationEngagementEvent>[
        CalibrationEngagementEvent.verdictRecorded(judgment: first),
        CalibrationEngagementEvent.verdictRecorded(
          judgment: second,
          comparison: comparison,
          shareOptIn: true,
        ),
      ],
    );
    final encoded = jsonEncode(state.toJson());

    expect(state.masteryMap.totalArchetypes, 2);
    expect(state.masteryMap.clearedAtBarCount, 1);
    expect(
      state.masteryMap.nudge,
      '1 archetype from completing the Backend map.',
    );
    expect(state.breakthroughs, hasLength(1));
    expect(state.breakthroughs.single.questionId, catalog.first.questionId);
    expect(
      state.latestDelta!.message,
      'You closed misses failure modes from last attempt.',
    );
    expect(state.nextRetest.questionId, catalog.last.questionId);
    expect(state.nextRetest.reason, 'No recorded attempt yet.');
    expect(state.prepSprint.policyVersion, kPrepSprintPolicyVersion);
    expect(state.prepSprint.daysRemaining, 15);
    expect(state.shareableWins.single.text, contains('Hit the senior bar on'));
    expect(state.shareableWins.single.text, isNot(contains('profile-1')));
    expect(encoded, isNot(contains('score')));
    expect(encoded, isNot(contains('readiness')));
    expect(encoded, isNot(contains('%')));
    expect(encoded, isNot(contains('probability')));
    expect(encoded, isNot(contains('definitely')));
    expect(encoded, isNot(contains('ats score')));
    expect(encoded, isNot(contains('live assist')));
    expect(encoded, isNot(contains('guarantee')));
    expect(encoded, isNot(contains('87%')));
  });

  test(
    'engagement state serialization is deterministic for shuffled events',
    () {
      final now = DateTime.utc(2026, 6, 5, 12);
      final catalog = kBackendDepthPracticeQuestions.take(2).toList();
      final first = _judgment(
        judgmentId: 'j1',
        questionId: catalog.first.questionId,
        levelBand: 'below_bar',
        createdAt: now.subtract(const Duration(days: 2)),
        risks: const <String>['Content: misses failure modes.'],
      );
      final second = _judgment(
        judgmentId: 'j2',
        questionId: catalog.first.questionId,
        levelBand: 'at_bar',
        createdAt: now,
        strengths: const <String>['Content: failure modes covered.'],
      );
      final comparison = InterviewRoundComparison.compare(
        previous: first,
        current: second,
      );
      final firstEvent = CalibrationEngagementEvent.verdictRecorded(
        judgment: first,
      );
      final secondEvent = CalibrationEngagementEvent.verdictRecorded(
        judgment: second,
        comparison: comparison,
        shareOptIn: true,
      );

      final ordered = buildBackendEngagementState(
        profileId: 'profile-1',
        catalog: catalog,
        now: now,
        passStartedAt: DateTime.utc(2026, 6, 1),
        interviewDate: DateTime.utc(2026, 6, 20, 12),
        events: <CalibrationEngagementEvent>[firstEvent, secondEvent],
      );
      final shuffled = buildBackendEngagementState(
        profileId: 'profile-1',
        catalog: catalog,
        now: now,
        passStartedAt: DateTime.utc(2026, 6, 1),
        interviewDate: DateTime.utc(2026, 6, 20, 12),
        events: <CalibrationEngagementEvent>[secondEvent, firstEvent],
      );

      expect(jsonEncode(shuffled.toJson()), jsonEncode(ordered.toJson()));
    },
  );

  test('interview memory exposes bounded trajectory history', () async {
    final store = InMemoryInterviewRoundMemoryStore(maxJudgmentsPerKey: 2);
    final questionId = kSeedBackendPracticeQuestion.questionId;
    await store.record(
      _judgment(
        judgmentId: 'j1',
        questionId: questionId,
        levelBand: 'below_bar',
        createdAt: DateTime.utc(2026, 6, 5, 9),
      ),
    );
    await store.record(
      _judgment(
        judgmentId: 'j2',
        questionId: questionId,
        levelBand: 'approaching',
        createdAt: DateTime.utc(2026, 6, 5, 10),
      ),
    );
    await store.record(
      _judgment(
        judgmentId: 'j3',
        questionId: questionId,
        levelBand: 'at_bar',
        createdAt: DateTime.utc(2026, 6, 5, 11),
      ),
    );

    final history = await store.history(
      profileId: 'profile-1',
      questionId: questionId,
    );

    expect(history.map((judgment) => judgment.judgmentId), <String>[
      'j2',
      'j3',
    ]);
  });
}

schema.InterviewContentJudgment _judgment({
  required String judgmentId,
  required String questionId,
  required String levelBand,
  required DateTime createdAt,
  List<String> strengths = const <String>[],
  List<String> risks = const <String>[],
}) {
  final question = backendDepthPracticeQuestionFor(questionId);
  final policy = CalibrationPolicyTuple.forBackend(modelPin: 'test-model');
  return schema.InterviewContentJudgment(
    judgmentId: judgmentId,
    profileId: 'profile-1',
    target: question.target,
    questionId: questionId,
    answerTranscriptId: 'answer-$judgmentId',
    rubricVersion: question.rubricVersion,
    promptVersion: question.promptVersion,
    modelId: 'test-model',
    levelBand: levelBand,
    strengths: strengths,
    risks: risks,
    recommendedActions: const <String>['Tighten one missing criterion.'],
    evidenceSpans: <schema.EvidenceSpan>[
      schema.EvidenceSpan(
        sourceId: 'answer-$judgmentId',
        sourceType: 'typed_answer',
        startOffset: 0,
        endOffset: 12,
        quote: 'tenant quota',
        metadata: policyTupleMetadata(policy),
      ),
    ],
    createdAt: createdAt,
  );
}

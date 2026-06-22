import 'dart:async';
import 'dart:convert';

import 'package:caliber_app_shell/app_shell.dart';
import 'package:caliber_design_system/design_system.dart';
import 'package:caliber_interview/interview.dart';
import 'package:caliber_prep_brief/prep_brief.dart';
import 'package:caliber_screens/screens.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('all shell product routes render in $brightness theme', (
      tester,
    ) async {
      final theme = switch (brightness) {
        Brightness.light => CaliberTheme.light(),
        Brightness.dark => CaliberTheme.dark(),
      };

      for (final destination in caliberShellDestinations) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) =>
                  buildScreenForDestination(context, destination),
            ),
          ),
        );

        final expectedTitle = switch (destination.lane) {
          CaliberLane.home => 'Next action',
          CaliberLane.interview => 'Practice room',
          _ => destination.label,
        };
        expect(find.text(expectedTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('route-specific product controls render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: Builder(
          builder: (context) => buildScreenForDestination(
            context,
            caliberShellDestinations.firstWhere(
              (dest) => dest.lane == CaliberLane.home,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Create job packet'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: Builder(
          builder: (context) => buildScreenForDestination(
            context,
            caliberShellDestinations.firstWhere(
              (dest) => dest.lane == CaliberLane.interview,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Submit answer'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: Builder(
          builder: (context) => buildScreenForDestination(
            context,
            caliberShellDestinations.firstWhere(
              (dest) => dest.lane == CaliberLane.resume,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: Builder(
          builder: (context) => buildScreenForDestination(
            context,
            caliberShellDestinations.firstWhere(
              (dest) => dest.lane == CaliberLane.corpus,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Search corpus'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: Builder(
          builder: (context) => buildScreenForDestination(
            context,
            caliberShellDestinations.firstWhere(
              (dest) => dest.lane == CaliberLane.billing,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Current plan: Free trial eval'), findsOneWidget);
  });

  testWidgets('home prep brief generates and preloads interview practice', (
    tester,
  ) async {
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.home,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: HomeScreen(
          destination: destination,
          eventSink: InMemoryPrepBriefEventSink(),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField).first,
      'Senior Backend Engineer role owning distributed APIs, cache-backed '
      'services, queues, event pipelines, observability, production incidents, '
      'debugging, code review, and architecture tradeoffs.',
    );
    await _pressElevatedButton(tester, 'Create job packet');

    await _scrollToText(tester, 'Prep brief');
    expect(find.text('Prep brief'), findsOneWidget);
    expect(find.text('Round mix forecast'), findsOneWidget);
    expect(find.text('Likely questions'), findsOneWidget);
    expect(find.text('What good looks like'), findsOneWidget);
    expect(find.text('Down-level risks'), findsOneWidget);

    await _pressElevatedButton(tester, 'Start practice');

    final answerLabel = find.text('Your answer', skipOffstage: false);
    await tester.ensureVisible(answerLabel);
    expect(answerLabel, findsOneWidget);
    expect(
      find.textContaining('Prep brief practice:', skipOffstage: false),
      findsWidgets,
    );
  });

  testWidgets('product spine view-models serialize deterministically', (
    tester,
  ) async {
    final generator = JdPrepBriefGenerator();
    final brief = await generator.generate(
      PrepBriefInput(jobDescription: _backendSeniorJd),
    );
    final question = brief.practiceQuestion;
    final judgment = await runInterviewRound(
      question,
      _seniorBackendAnswer,
      now: DateTime.utc(2026, 6, 6, 12),
    );
    final event = CalibrationEngagementEvent.verdictRecorded(
      judgment: judgment,
    );
    final engagement = buildBackendEngagementState(
      profileId: judgment.profileId,
      events: [event],
      now: DateTime.utc(2026, 6, 6, 12),
    );
    Map<String, Object?> buildState() {
      final verdict = VerdictArtifactViewModel.fromJudgment(judgment: judgment);
      return <String, Object?>{
        'packet': JobPacketViewModel.fromBrief(
          brief: brief,
          currentLevel: 'Mid-level',
          timeline: '90-day pass',
          hasResumeEvidence: false,
        ).toJson(),
        'brief': PrepBriefViewModel.fromBrief(brief).toJson(),
        'practice': PracticeRoomViewModel.fromQuestion(
          question: question,
          brief: brief,
        ).toJson(),
        'verdict': verdict.toJson(),
        'inspect': EvidenceInspectViewModel.fromJudgment(judgment).toJson(),
        'retest': RetestPlanViewModel.fromVerdict(
          question: question,
          verdict: verdict,
        ).toJson(),
        'map': BackendMapViewModel.fromEngagementState(engagement).toJson(),
      };
    }

    final first = jsonEncode(buildState());
    final second = jsonEncode(buildState());

    expect(second, first);
    expect(first, contains('"policy"'));
    expect(first, contains('"corpus_bundle_version"'));
    expect(first, contains('"highest_leverage_fix"'));
    expect(first, contains('"quote"'));
  });

  testWidgets('home route is not a blank chat composer', (tester) async {
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.home,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: HomeScreen(destination: destination),
      ),
    );

    final visible = _visibleText(tester).toLowerCase();
    expect(visible, contains('next action'));
    expect(visible, contains('paste backend senior jd'));
    expect(visible, isNot(contains('assistant')));
    expect(visible, isNot(contains('chat composer')));
    expect(visible, isNot(contains('message thread')));
  });

  testWidgets('product spine persists Block 9 funnel events', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final clock = _TickingClock(DateTime.utc(2026, 6, 6, 12));
    final sink = PersistentPrepBriefEventSink(
      anonProfileId: 'anon-profile-1',
      preferences: preferences,
      clock: clock.call,
    );
    await sink.ready;
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.home,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: HomeScreen(
          destination: destination,
          eventSink: sink,
          anonProfileId: 'anon-profile-1',
          clock: clock.call,
          runRound: (question, answer) {
            return runInterviewRound(
              question,
              answer,
              now: DateTime.utc(2026, 6, 6, 12),
            );
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), _backendSeniorJd);
    await tester.enterText(find.byType(TextField).at(5), 'founder@example.com');
    await _pressElevatedButton(tester, 'Create job packet');
    await sink.flush();

    expect(sink.records.map((record) => record.eventType.wireName), <String>[
      'packet_created',
      'brief_completed',
      'email_capture',
    ]);
    expect(sink.records.first.anonProfileId, 'anon-profile-1');
    expect(sink.records.first.occurredAt, DateTime.utc(2026, 6, 6, 12));

    await _pressElevatedButton(tester, 'Start practice');
    await sink.flush();

    expect(
      sink.query(type: PrepBriefEventType.practiceStartClick),
      hasLength(1),
    );

    await _enterPracticeAnswer(tester, _seniorBackendAnswer);
    await _pressElevatedButton(tester, 'Submit answer');
    await sink.flush();
    await tester.drag(find.byType(ListView).last, const Offset(0, -2400));
    await tester.pumpAndSettle();
    await _pressOutlinedButton(tester, 'Open evidence inspect');
    await _scrollToText(tester, 'Evidence inspect');
    expect(find.text('Evidence inspect', skipOffstage: false), findsOneWidget);
    await _pressElevatedButton(tester, 'Retest same archetype');
    await sink.flush();

    expect(sink.records.map((record) => record.eventType.wireName), <String>[
      'packet_created',
      'brief_completed',
      'email_capture',
      'practice_start_click',
      'first_paid_eval_started',
      'verdict_completed',
      'inspect_opened',
      'retest_started',
    ]);
    await _scrollToText(tester, 'Verdict artifact');
    expect(find.text('Verdict artifact'), findsOneWidget);
    expect(find.text('Backend map', skipOffstage: false), findsOneWidget);
    expect(find.text('Map cells', skipOffstage: false), findsOneWidget);

    final persisted = preferences.getStringList(
      PersistentPrepBriefEventSink.defaultStorageKey,
    );
    expect(persisted, hasLength(8));
    expect(
      persisted!.join('\n'),
      contains('"anon_profile_id":"anon-profile-1"'),
    );
    expect(persisted.join('\n'), contains('"event_type":"brief_completed"'));
    expect(persisted.join('\n'), contains('"event_type":"packet_created"'));
    expect(persisted.join('\n'), contains('"event_type":"verdict_completed"'));
    expect(persisted.join('\n'), contains('"event_type":"inspect_opened"'));
    expect(persisted.join('\n'), contains('"event_type":"retest_started"'));
    expect(persisted.join('\n'), contains('"ts":"2026-06-06T12:00:00.000Z"'));
  });

  testWidgets('funnel sink posts two anonymous sessions to one server store', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final endpoint = Uri.parse('https://gateway.test/funnel');
    final posted = <Map<String, Object?>>[];
    Future<bool> poster(
      Uri actualEndpoint,
      Map<String, Object?> payload,
    ) async {
      expect(actualEndpoint, endpoint);
      posted.add(Map<String, Object?>.of(payload));
      return true;
    }

    final firstSink = PersistentPrepBriefEventSink(
      anonProfileId: 'anon-session-a',
      preferences: preferences,
      clock: _TickingClock(DateTime.utc(2026, 6, 6, 15)).call,
      funnelEndpoint: endpoint,
      funnelPoster: poster,
    );
    final secondSink = PersistentPrepBriefEventSink(
      anonProfileId: 'anon-session-b',
      preferences: preferences,
      clock: _TickingClock(DateTime.utc(2026, 6, 6, 16)).call,
      funnelEndpoint: endpoint,
      funnelPoster: poster,
    );
    await firstSink.ready;
    await secondSink.ready;

    final firstBrief = await JdPrepBriefGenerator(
      eventSink: firstSink,
    ).generate(PrepBriefInput(jobDescription: _backendSeniorJd));
    final secondGenerator = JdPrepBriefGenerator(eventSink: secondSink);
    final secondBrief = await secondGenerator.generate(
      PrepBriefInput(jobDescription: _backendSeniorJd),
    );
    secondGenerator.recordPracticeStartClick(secondBrief);
    await firstSink.flush();
    await secondSink.flush();

    expect(
      posted.map((payload) => payload['anon_profile_id']).toSet(),
      <String>{'anon-session-a', 'anon-session-b'},
    );
    expect(posted.map((payload) => payload['event_type']), <String>[
      'packet_created',
      'brief_completed',
      'packet_created',
      'brief_completed',
      'practice_start_click',
    ]);
    expect(firstBrief.corpusBundleVersion, secondBrief.corpusBundleVersion);
    expect(
      preferences.getStringList(
        PersistentPrepBriefEventSink.defaultPendingStorageKey,
      ),
      isEmpty,
    );
  });

  testWidgets('funnel sink keeps failed sends buffered for retry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final endpoint = Uri.parse('https://gateway.test/funnel');
    var remoteAvailable = false;
    var attempts = 0;
    Future<bool> poster(
      Uri actualEndpoint,
      Map<String, Object?> payload,
    ) async {
      expect(actualEndpoint, endpoint);
      attempts += 1;
      return remoteAvailable;
    }

    final sink = PersistentPrepBriefEventSink(
      anonProfileId: 'anon-retry',
      preferences: preferences,
      clock: _TickingClock(DateTime.utc(2026, 6, 6, 17)).call,
      funnelEndpoint: endpoint,
      funnelPoster: poster,
    );
    await sink.ready;

    await JdPrepBriefGenerator(
      eventSink: sink,
    ).generate(PrepBriefInput(jobDescription: _backendSeniorJd));
    await sink.flush();

    expect(attempts, greaterThanOrEqualTo(1));
    expect(
      preferences.getStringList(
        PersistentPrepBriefEventSink.defaultPendingStorageKey,
      ),
      hasLength(2),
    );

    remoteAvailable = true;
    await sink.flush();

    expect(
      preferences.getStringList(
        PersistentPrepBriefEventSink.defaultPendingStorageKey,
      ),
      isEmpty,
    );
  });

  testWidgets('funnel sink retries buffered events after browser restart', (
    tester,
  ) async {
    final bufferedRecord = PrepBriefDemandSignalRecord(
      eventType: PrepBriefEventType.briefCompleted,
      anonProfileId: 'anon-restart',
      occurredAt: DateTime.utc(2026, 6, 6, 18),
      sourceHash: 'source-restart',
      questionId: null,
      corpusBundleVersion: 'backend_depth_corpus_seed.v0.2',
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      PersistentPrepBriefEventSink.defaultPendingStorageKey: <String>[
        jsonEncode(bufferedRecord.toJson()),
      ],
    });
    final preferences = await SharedPreferences.getInstance();
    final posted = Completer<Map<String, Object?>>();

    final restartedSink = PersistentPrepBriefEventSink(
      anonProfileId: 'anon-restart',
      preferences: preferences,
      funnelEndpoint: Uri.parse('https://gateway.test/funnel'),
      funnelPoster: (endpoint, payload) async {
        if (!posted.isCompleted) {
          posted.complete(Map<String, Object?>.of(payload));
        }
        return true;
      },
    );

    await restartedSink.ready;
    final payload = await posted.future.timeout(const Duration(seconds: 1));
    await restartedSink.flush();

    expect(payload['event_type'], 'brief_completed');
    expect(payload['anon_profile_id'], 'anon-restart');
    expect(
      preferences.getStringList(
        PersistentPrepBriefEventSink.defaultPendingStorageKey,
      ),
      isEmpty,
    );
  });

  testWidgets('browser fake gateway flow renders verdict and mastery', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final sink = PersistentPrepBriefEventSink(
      anonProfileId: 'anon-browser-gateway',
      preferences: preferences,
      clock: _TickingClock(DateTime.utc(2026, 6, 6, 14)).call,
    );
    await sink.ready;
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.home,
    );
    var fakeGatewayCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: HomeScreen(
          destination: destination,
          eventSink: sink,
          anonProfileId: 'anon-browser-gateway',
          runRound: (question, answer) async {
            fakeGatewayCalled = true;
            return _fakeGatewayJudgment(
              question: question,
              answer: answer,
              createdAt: DateTime.utc(2026, 6, 6, 14, 0, 3),
            );
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), _backendSeniorJd);
    await _pressElevatedButton(tester, 'Create job packet');
    await _pressElevatedButton(tester, 'Start practice');
    await _enterPracticeAnswer(tester, _seniorBackendAnswer);
    await _pressElevatedButton(tester, 'Submit answer');
    expect(tester.takeException(), isNull);
    await sink.flush();
    await tester.drag(find.byType(ListView).last, const Offset(0, -2400));
    await tester.pumpAndSettle();
    await _pressOutlinedButton(tester, 'Open evidence inspect');
    await _scrollToText(tester, 'Evidence inspect');
    expect(find.text('Evidence inspect', skipOffstage: false), findsOneWidget);
    await _pressElevatedButton(tester, 'Retest same archetype');
    await sink.flush();

    expect(fakeGatewayCalled, isTrue);
    await _scrollToText(tester, 'Verdict artifact');
    expect(find.text('Verdict artifact', skipOffstage: false), findsOneWidget);
    expect(find.text('Risks', skipOffstage: false), findsWidgets);
    expect(find.text('Evidence quotes', skipOffstage: false), findsWidgets);
    expect(find.text('Backend map', skipOffstage: false), findsOneWidget);
    expect(find.text('Map cells', skipOffstage: false), findsOneWidget);
    expect(find.text('Retest plan', skipOffstage: false), findsOneWidget);
    expect(
      sink.query(type: PrepBriefEventType.firstPaidEvalStarted),
      hasLength(1),
    );
    expect(sink.query(type: PrepBriefEventType.verdictCompleted), hasLength(1));
    expect(sink.query(type: PrepBriefEventType.inspectOpened), hasLength(1));
    expect(sink.query(type: PrepBriefEventType.retestStarted), hasLength(1));
    expect(
      preferences
          .getStringList(PersistentPrepBriefEventSink.defaultStorageKey)!
          .join('\n'),
      allOf(
        contains('"event_type":"first_paid_eval_started"'),
        contains('"event_type":"packet_created"'),
        contains('"event_type":"verdict_completed"'),
        contains('"event_type":"inspect_opened"'),
        contains('"event_type":"retest_started"'),
      ),
    );
  });

  testWidgets('visible wedge and verdict copy avoids never-list claims', (
    tester,
  ) async {
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.home,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: HomeScreen(
          destination: destination,
          eventSink: InMemoryPrepBriefEventSink(),
          runRound: (question, answer) => runInterviewRound(
            question,
            answer,
            now: DateTime.utc(2026, 6, 6, 12),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), _backendSeniorJd);
    await _pressElevatedButton(tester, 'Create job packet');
    await _pressElevatedButton(tester, 'Start practice');
    await _enterPracticeAnswer(tester, _seniorBackendAnswer);
    await _pressElevatedButton(tester, 'Submit answer');

    final encodedCopy = _visibleText(tester).toLowerCase();
    for (final banned in <String>[
      'ats score',
      '87%',
      'probability',
      'definitely',
      'live assist',
      'guaranteed pass',
      'guarantee',
      'emotion',
    ]) {
      expect(encodedCopy, isNot(contains(banned)), reason: banned);
    }
  });

  testWidgets('interview round renders calibrated feedback', (tester) async {
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.interview,
    );
    var runRoundCalled = false;
    final runRoundComplete = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: InterviewScreen(
          destination: destination,
          runRound: (question, answer) {
            runRoundCalled = true;
            final judgment = runInterviewRound(
              question,
              answer,
              now: DateTime.utc(2026, 6, 4, 12),
            );
            judgment.whenComplete(runRoundComplete.complete);
            return judgment;
          },
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'I would define tenant quotas, burst policy, and latency budget first. '
      'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
      'The tradeoff versus sliding windows is less exact fairness. '
      'For login I would fail closed after a timeout, while read-only traffic can fail open. '
      'I would measure p95 latency and reject rate.',
    );
    final feedbackButton = find.widgetWithText(ElevatedButton, 'Submit answer');
    await tester.ensureVisible(feedbackButton);
    await tester.pumpAndSettle();
    tester.widget<ElevatedButton>(feedbackButton).onPressed!();
    await runRoundComplete.future;
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(runRoundCalled, isTrue);
    expect(find.text('Verdict sheet'), findsOneWidget);
    expect(find.text('Content strengths'), findsOneWidget);
    expect(find.text('Delivery risks'), findsOneWidget);
    expect(find.text('Why we judged this'), findsOneWidget);
    expect(find.text('Answer evidence'), findsOneWidget);
    expect(find.textContaining('Requirements and constraints'), findsWidgets);
    expect(find.textContaining('Minimum fix:'), findsWidgets);
    expect(find.textContaining('fail closed'), findsWidgets);
  });

  testWidgets('interview round renders comparison after a prior round', (
    tester,
  ) async {
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.interview,
    );
    final memoryStore = InMemoryInterviewRoundMemoryStore();

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: InterviewScreen(
          destination: destination,
          memoryStore: memoryStore,
          runRound: (question, answer) => runInterviewRound(
            question,
            answer,
            now: DateTime.utc(2026, 6, 4, 12),
          ),
        ),
      ),
    );

    await _submitInterviewAnswer(tester, 'I would add a cache.');
    expect(find.text('Compared with last round'), findsNothing);

    await _submitInterviewAnswer(
      tester,
      'I would define tenant quotas, burst policy, and latency budget first. '
      'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
      'The tradeoff versus sliding windows is less exact fairness. '
      'For login I would fail closed after a timeout, while read-only traffic can fail open. '
      'I would measure p95 latency and reject rate.',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Compared with last round'), findsOneWidget);
    expect(find.textContaining('Calibration'), findsWidgets);
  });

  testWidgets('interview teaser hides full evidence report when not entitled', (
    tester,
  ) async {
    final destination = caliberShellDestinations.firstWhere(
      (dest) => dest.lane == CaliberLane.interview,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: InterviewScreen(
          destination: destination,
          feedbackAccess: InterviewFeedbackAccess.teaser,
          runRound: (question, answer) => runInterviewRound(
            question,
            answer,
            now: DateTime.utc(2026, 6, 4, 12),
          ),
        ),
      ),
    );

    await _submitInterviewAnswer(
      tester,
      'I would define tenant quotas and use Redis.',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Verdict preview'), findsOneWidget);
    expect(find.text('Verdict sheet'), findsNothing);
    expect(find.text('Answer evidence'), findsNothing);
    expect(find.textContaining('Full pass keeps cited evidence'), findsWidgets);
  });
}

Future<void> _submitInterviewAnswer(WidgetTester tester, String answer) async {
  await _enterPracticeAnswer(tester, answer);
  await _pressElevatedButton(tester, 'Submit answer');
}

Future<void> _enterPracticeAnswer(WidgetTester tester, String answer) async {
  await _scrollToText(tester, 'Your answer');
  final answerField = find.byType(TextField).last;
  await tester.ensureVisible(answerField);
  await tester.enterText(answerField, answer);
  await tester.pumpAndSettle();
}

Future<void> _pressElevatedButton(WidgetTester tester, String label) async {
  await _scrollToText(tester, label);
  final button = find.widgetWithText(ElevatedButton, label).last;
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  final widget = tester.widget<ElevatedButton>(button);
  expect(widget.onPressed, isNotNull, reason: label);
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

Future<void> _pressOutlinedButton(WidgetTester tester, String label) async {
  await _scrollToText(tester, label);
  final button = find.widgetWithText(OutlinedButton, label).last;
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  final widget = tester.widget<OutlinedButton>(button);
  expect(widget.onPressed, isNotNull, reason: label);
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

Future<void> _scrollToText(WidgetTester tester, String label) async {
  final text = find.text(label, skipOffstage: false);
  if (text.evaluate().isNotEmpty) {
    await tester.ensureVisible(text.last);
    await tester.pumpAndSettle();
    return;
  }
  final scrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(
    find.text(label),
    520,
    scrollable: scrollable,
    maxScrolls: 20,
  );
  await tester.pumpAndSettle();
}

String _visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) {
        final data = text.data;
        if (data != null) return data;
        return text.textSpan?.toPlainText() ?? '';
      })
      .join('\n');
}

final class _TickingClock {
  _TickingClock(this._next);

  DateTime _next;

  DateTime call() {
    final current = _next;
    _next = _next.add(const Duration(seconds: 1));
    return current;
  }
}

const _backendSeniorJd = '''
Senior Backend Engineer role owning distributed APIs, cache-backed services,
queues, event pipelines, observability, production incidents, debugging, code
review, and architecture tradeoffs.
''';

const _seniorBackendAnswer =
    'I would define tenant quotas, burst policy, and latency budget first. '
    'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
    'The tradeoff versus sliding windows is less exact fairness. '
    'For login I would fail closed after a timeout, while read-only traffic can fail open. '
    'I would measure p95 latency and reject rate.';

schema.InterviewContentJudgment _fakeGatewayJudgment({
  required InterviewPracticeQuestion question,
  required String answer,
  required DateTime createdAt,
}) {
  final quote = answer.contains('tenant quotas')
      ? 'tenant quotas'
      : answer.split(RegExp(r'\s+')).take(4).join(' ');
  return schema.InterviewContentJudgment(
    judgmentId: 'fake-gateway-${question.questionId}',
    profileId: 'anon-browser-gateway',
    target: question.target,
    questionId: question.questionId,
    answerTranscriptId: 'browser-answer-1',
    rubricVersion: question.rubricVersion,
    promptVersion: question.promptVersion,
    modelId: 'fake-gateway',
    levelBand: 'at_bar',
    strengths: const <String>[
      'Content: Names capacity policy before mechanism selection.',
    ],
    risks: const <String>[
      'Content: Needs sharper incident fallback boundaries.',
    ],
    recommendedActions: const <String>[
      'Tie the fallback mode to one measurable user impact.',
    ],
    evidenceSpans: <schema.EvidenceSpan>[
      schema.EvidenceSpan(
        sourceId: 'browser-answer-1',
        sourceType: 'typed_answer',
        startOffset: answer.indexOf(quote).clamp(0, answer.length),
        endOffset:
            (answer.indexOf(quote).clamp(0, answer.length) + quote.length)
                .clamp(1, answer.length),
        quote: quote,
        metadata: const <String, Object?>{
          'dimension': 'requirements',
          'criterion_label': 'Requirements and constraints',
          'level_signal': 'at_bar',
          'corpus_bundle_version': 'backend_depth_corpus_seed.v0.2',
          'rubric_version': 'backend_depth_rubric.v0.2',
          'prompt_version': 'fake-gateway-browser-flow.v1',
          'model_pin': 'fake-gateway',
          'schema_version': schema.kInterviewContentJudgmentSchemaVersion,
        },
      ),
    ],
    createdAt: createdAt,
  );
}

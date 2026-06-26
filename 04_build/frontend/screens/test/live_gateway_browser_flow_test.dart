import 'dart:convert';

import 'package:caliber_app_shell/app_shell.dart';
import 'package:caliber_design_system/design_system.dart';
import 'package:caliber_gateway_client/caliber_gateway_client.dart';
import 'package:caliber_interview/interview.dart';
import 'package:caliber_prep_brief/prep_brief.dart';
import 'package:caliber_screens/screens.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _runLiveGateway = bool.fromEnvironment('CALIBER_LIVE_GATEWAY_TEST');
const _liveGatewayBaseUrl = String.fromEnvironment(
  'CALIBER_LIVE_GATEWAY_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

void main() {
  testWidgets(
    'live browser gateway flow returns provider verdict and mastery',
    (tester) async {
      final destination = caliberShellDestinations.firstWhere(
        (dest) => dest.lane == CaliberLane.home,
      );
      final gatewayClient = GatewayClient(
        config: GatewayClientConfig(
          baseUrl: Uri.parse(_liveGatewayBaseUrl),
          timeout: const Duration(seconds: 90),
        ),
      );
      schema.InterviewContentJudgment? captured;

      await tester.pumpWidget(
        MaterialApp(
          theme: CaliberTheme.light(),
          home: HomeScreen(
            destination: destination,
            eventSink: InMemoryPrepBriefEventSink(),
            anonProfileId: 'live-browser-profile',
            runRound: (question, answer) async {
              final judgment = await runInterviewRound(
                question,
                answer,
                judge: GatewayStructuredJudgeAdapter(
                  gatewayClient: gatewayClient,
                  clock: () => DateTime.utc(2026, 6, 6, 16),
                ),
                profile: _profileFixture(),
                now: DateTime.utc(2026, 6, 6, 16),
              );
              captured = judgment;
              return judgment;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), _backendSeniorJd);
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Create job packet'),
      );
      await tester.pumpAndSettle();
      final practiceButton = find.widgetWithText(
        ElevatedButton,
        'Start practice',
      );
      await tester.ensureVisible(practiceButton);
      tester.widget<ElevatedButton>(practiceButton).onPressed!();
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -900));
      await tester.pumpAndSettle();
      final answerField = find.byType(TextField).last;
      await tester.ensureVisible(answerField);
      await tester.enterText(answerField, _liveBackendAnswer);
      final feedbackButton = find.widgetWithText(
        ElevatedButton,
        'Submit answer',
      );
      await tester.ensureVisible(feedbackButton);
      await tester.pumpAndSettle();
      tester.widget<ElevatedButton>(feedbackButton).onPressed!();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.drag(find.byType(ListView).last, const Offset(0, -2400));
      await tester.pumpAndSettle();

      final judgment = captured;
      expect(judgment, isNotNull);
      expect(find.text('Verdict sheet'), findsOneWidget);
      expect(find.text('Backend map', skipOffstage: false), findsOneWidget);
      expect(find.text('Answer evidence'), findsOneWidget);
      debugPrint(
        'CALIBER_LIVE_BROWSER_VERDICT ${jsonEncode(<String, Object?>{'judgment_id': judgment!.judgmentId, 'model_id': judgment.modelId, 'level_band': judgment.levelBand, 'question_id': judgment.questionId, 'rubric_version': judgment.rubricVersion, 'evidence_count': judgment.evidenceSpans.length, 'strengths_count': judgment.strengths.length, 'risks_count': judgment.risks.length})}',
      );
    },
    skip: !_runLiveGateway,
    timeout: const Timeout(Duration(minutes: 4)),
  );
}

schema.ProfileIdentity _profileFixture() {
  final now = DateTime.utc(2026, 6, 6, 16);
  return schema.ProfileIdentity(
    profileId: 'live-browser-profile',
    ownerUserId: 'anonymous:live-browser-profile',
    displayName: 'Live Browser Candidate',
    primaryDomain: 'Backend',
    targetLevelBand: 'Senior',
    locale: 'en-US',
    createdAt: now,
    updatedAt: now,
  );
}

const _backendSeniorJd = '''
Senior Backend Engineer role owning distributed APIs, cache-backed services,
queues, event pipelines, observability, production incidents, debugging, code
review, and architecture tradeoffs.
''';

const _liveBackendAnswer =
    'I would start by separating tenant quotas, burst rules, and the user-facing latency budget. '
    'The design would use token buckets with atomic updates because bursts matter more than exact fairness here. '
    'I would call out the tradeoff versus sliding windows, then define fail-open for read-only traffic and fail-closed for login. '
    'For production I would measure p95 latency, rejection rate, Redis timeout rate, and saturation during regional failover.';

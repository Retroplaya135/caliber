import 'package:caliber_app_runner/main.dart';
import 'package:caliber_auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real macOS app starts, onboards, and opens five tabs', (
    tester,
  ) async {
    final authProvider = buildCaliberLocalAuthProvider();
    final preferences = const SharedPrefsOnboardingPreferences();
    addTearDown(authProvider.dispose);

    await authProvider.signOut();
    await preferences.clear();

    await tester.pumpWidget(
      ProviderScope(
        child: CaliberApp(
          authProvider: authProvider,
          onboardingPreferences: preferences,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Caliber'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
    await tester.pumpAndSettle();

    await _pumpUntilFound(tester, find.byType(NavigationBar));
    expect(find.byType(NavigationBar), findsOneWidget);

    await _expectTab(tester, label: 'Home', screenText: 'Create job packet');
    await _completeHomePrepBriefFlow(tester);
    await _expectTab(
      tester,
      label: 'Packets',
      screenText:
          'Job packets, saved prep context, and recovery state are organized here.',
    );
    await _expectTab(
      tester,
      label: 'Practice',
      screenText: 'Backend depth round: distributed rate limiter',
    );
    await _completeInterviewRound(tester);
    await _expectTab(
      tester,
      label: 'Progress',
      screenText:
          'Backend map, attempt memory, and retest priorities are summarized here.',
    );
    await _expectTab(
      tester,
      label: 'Settings',
      screenText:
          'Workspace preferences, privacy controls, and app defaults will be configured here.',
    );
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}

Future<void> _completeHomePrepBriefFlow(WidgetTester tester) async {
  final textFields = find.byType(TextField);
  await tester.enterText(textFields.at(0), _backendSeniorJd);
  await tester.enterText(textFields.at(5), 'founder-smoke@example.com');

  final generateButton = find.widgetWithText(
    ElevatedButton,
    'Create job packet',
  );
  await tester.ensureVisible(generateButton);
  await tester.pumpAndSettle();
  await tester.tap(generateButton);
  await tester.pumpAndSettle();

  expect(find.text('Prep brief'), findsOneWidget);
  expect(find.text('Round mix forecast'), findsOneWidget);
  expect(find.text('Likely questions'), findsOneWidget);

  final ctaButton = find.widgetWithText(ElevatedButton, 'Start practice');
  await tester.ensureVisible(ctaButton);
  await tester.pumpAndSettle();
  await tester.tap(ctaButton);
  await tester.pumpAndSettle();

  final answerLabel = find.text('Your answer', skipOffstage: false);
  await tester.ensureVisible(answerLabel);
  expect(answerLabel, findsOneWidget);
  expect(
    find.textContaining('Prep brief practice:', skipOffstage: false),
    findsOneWidget,
  );
}

Future<void> _expectTab(
  WidgetTester tester, {
  required String label,
  required String screenText,
}) async {
  final tab = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
  await tester.tap(tab);
  await tester.pumpAndSettle();
  expect(find.text(screenText), findsOneWidget);
}

Future<void> _completeInterviewRound(WidgetTester tester) async {
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
  await tester.tap(feedbackButton);
  await tester.pumpAndSettle();
  await tester.drag(find.byType(ListView), const Offset(0, -600));
  await tester.pumpAndSettle();

  expect(find.text('Verdict sheet'), findsOneWidget);
  expect(find.text('Why we judged this'), findsOneWidget);
  expect(find.text('Answer evidence'), findsOneWidget);
  expect(find.textContaining('fail closed'), findsWidgets);
}

const _backendSeniorJd = '''
Senior Backend Engineer, Infrastructure.
Build distributed rate limiting, idempotent APIs, observability, queueing,
incident response, and consistency trade-off documentation for high-volume
services. Partner with product and SRE on reliability and privacy reviews.
''';

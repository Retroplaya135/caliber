import 'dart:async';

import 'package:caliber_app_runner/main.dart';
import 'package:caliber_app_state/caliber_app_state.dart' as app_state;
import 'package:caliber_auth/auth.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding completes into the five tappable shell tabs', (
    tester,
  ) async {
    final authProvider = _MemoryAuthProvider();
    final onboardingPreferences = _MemoryOnboardingPreferences();
    addTearDown(authProvider.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: CaliberApp(
          authProvider: authProvider,
          onboardingPreferences: onboardingPreferences,
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

    expect(onboardingPreferences.complete, isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);

    await _expectTab(tester, label: 'Home', screenText: 'Create job packet');
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

  testWidgets('denied gateway entitlement still opens interview preview', (
    tester,
  ) async {
    final authProvider = _MemoryAuthProvider();
    final onboardingPreferences = _MemoryOnboardingPreferences()
      ..complete = true;
    await authProvider.signInAnonymously();
    addTearDown(authProvider.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          app_state.entitlementPolicyProvider.overrideWithValue(
            const _DenyGatewayEntitlementPolicy(),
          ),
        ],
        child: CaliberApp(
          authProvider: authProvider,
          onboardingPreferences: onboardingPreferences,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expectTab(
      tester,
      label: 'Practice',
      screenText: 'Backend depth round: distributed rate limiter',
    );
    await tester.enterText(
      find.byType(TextField),
      'I would define tenant quotas and use Redis.',
    );
    final feedbackButton = find.widgetWithText(ElevatedButton, 'Submit answer');
    await tester.ensureVisible(feedbackButton);
    await tester.pumpAndSettle();
    await tester.tap(feedbackButton);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Verdict preview'), findsOneWidget);
    expect(find.text('Verdict sheet'), findsNothing);
    expect(find.text('Answer evidence'), findsNothing);
  });
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

final class _MemoryAuthProvider implements AuthProvider {
  final StreamController<schema.ProfileIdentity?> _changes =
      StreamController<schema.ProfileIdentity?>.broadcast();

  schema.ProfileIdentity? _profile;

  @override
  Stream<schema.ProfileIdentity?> get currentUser async* {
    yield _profile;
    yield* _changes.stream;
  }

  @override
  Future<schema.ProfileIdentity?> get currentProfile async => _profile;

  @override
  Future<schema.ProfileIdentity> signInAnonymously() async {
    final profile = _profile ?? _profileFixture();
    _profile = profile;
    _changes.add(profile);
    return profile;
  }

  @override
  Future<schema.ProfileIdentity> signInWithApple() {
    throw const AppleSignInNotImplementedException();
  }

  @override
  Future<void> signOut() async {
    _profile = null;
    _changes.add(null);
  }

  void dispose() {
    unawaited(_changes.close());
  }
}

final class _MemoryOnboardingPreferences implements OnboardingPreferences {
  bool complete = false;

  @override
  Future<void> clear() async {
    complete = false;
  }

  @override
  Future<bool> isComplete() async => complete;

  @override
  Future<void> markComplete() async {
    complete = true;
  }
}

schema.ProfileIdentity _profileFixture() {
  final now = DateTime.utc(2026, 6, 3, 20);
  return schema.ProfileIdentity(
    profileId: '123e4567-e89b-42d3-a456-426614174000',
    ownerUserId: 'anonymous:123e4567-e89b-42d3-a456-426614174000',
    displayName: 'Anonymous Candidate',
    primaryDomain: 'local',
    targetLevelBand: 'unspecified',
    locale: 'en-US',
    createdAt: now,
    updatedAt: now,
  );
}

final class _DenyGatewayEntitlementPolicy implements schema.EntitlementPolicy {
  const _DenyGatewayEntitlementPolicy();

  @override
  schema.EntitlementDecision evaluate({
    required schema.EntitlementSnapshot snapshot,
    required String featureKey,
    required String policyVersion,
    required DateTime evaluatedAt,
  }) {
    final allowed = featureKey != 'gateway_interview_eval';
    return schema.EntitlementDecision(
      decisionId: 'test:${snapshot.userId}:$featureKey',
      allowed: allowed,
      reasonCode: allowed ? 'test_allowed' : 'test_denied',
      policyVersion: policyVersion,
      snapshot: snapshot,
    );
  }
}

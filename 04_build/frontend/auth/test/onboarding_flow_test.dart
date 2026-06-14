import 'package:caliber_auth/auth.dart';
import 'package:caliber_design_system/design_system.dart';
import 'package:caliber_shared/caliber_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Onboarding completes, creates anonymous profile, and persists flag',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = SharedPrefsOnboardingPreferences(
        preferences: await SharedPreferences.getInstance(),
      );
      final authProvider = _CompletingAuthProvider();
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CaliberTheme.light(),
          home: OnboardingFlow(
            authProvider: authProvider,
            preferences: preferences,
            onComplete: () => completed = true,
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(authProvider.didSignInAnonymously, isTrue);
      expect(await preferences.isComplete(), isTrue);
      expect(completed, isTrue);
    },
  );
}

final class _CompletingAuthProvider implements AuthProvider {
  bool didSignInAnonymously = false;

  final ProfileIdentity profile = _profile();

  @override
  Stream<ProfileIdentity?> get currentUser async* {
    yield null;
  }

  @override
  Future<ProfileIdentity?> get currentProfile async => null;

  @override
  Future<ProfileIdentity> signInAnonymously() async {
    didSignInAnonymously = true;
    return profile;
  }

  @override
  Future<ProfileIdentity> signInWithApple() {
    throw const AppleSignInNotImplementedException();
  }

  @override
  Future<void> signOut() async {}
}

ProfileIdentity _profile() {
  final now = DateTime.utc(2026, 5, 31, 20);
  return ProfileIdentity(
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

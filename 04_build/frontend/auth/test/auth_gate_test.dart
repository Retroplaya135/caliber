import 'package:caliber_auth/auth.dart';
import 'package:caliber_design_system/design_system.dart';
import 'package:caliber_shared/caliber_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuthGate shows onboarding when no profile exists', (
    tester,
  ) async {
    final authProvider = _FakeAuthProvider(null);

    await tester.pumpWidget(
      _TestApp(
        child: AuthGate(
          authProvider: authProvider,
          preferences: _MemoryOnboardingPreferences(),
          shell: const Text('Shell Ready'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome to Caliber'), findsOneWidget);
    expect(find.text('Shell Ready'), findsNothing);
  });

  testWidgets('AuthGate shows shell when profile exists', (tester) async {
    final authProvider = _FakeAuthProvider(_profile());

    await tester.pumpWidget(
      _TestApp(
        child: AuthGate(
          authProvider: authProvider,
          preferences: _MemoryOnboardingPreferences(),
          shell: const Text('Shell Ready'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Shell Ready'), findsOneWidget);
    expect(find.text('Welcome to Caliber'), findsNothing);
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: CaliberTheme.light(), home: child);
  }
}

final class _FakeAuthProvider implements AuthProvider {
  _FakeAuthProvider(this.profile);

  final ProfileIdentity? profile;

  @override
  Stream<ProfileIdentity?> get currentUser async* {
    yield profile;
  }

  @override
  Future<ProfileIdentity?> get currentProfile async => profile;

  @override
  Future<ProfileIdentity> signInAnonymously() async {
    return profile ?? _profile();
  }

  @override
  Future<ProfileIdentity> signInWithApple() {
    throw const AppleSignInNotImplementedException();
  }

  @override
  Future<void> signOut() async {}
}

final class _MemoryOnboardingPreferences implements OnboardingPreferences {
  bool complete = false;

  @override
  Future<void> clear() async {
    complete = false;
  }

  @override
  Future<bool> isComplete() async {
    return complete;
  }

  @override
  Future<void> markComplete() async {
    complete = true;
  }
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

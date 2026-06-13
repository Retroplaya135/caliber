import 'package:flutter/material.dart';

import 'auth_provider.dart';
import 'onboarding_flow.dart';
import 'onboarding_preferences.dart';

final class AuthGate extends StatelessWidget {
  const AuthGate({
    required this.authProvider,
    required this.preferences,
    required this.shell,
    super.key,
  });

  final AuthProvider authProvider;
  final OnboardingPreferences preferences;
  final Widget shell;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authProvider.currentUser,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null) {
          return OnboardingFlow(
            authProvider: authProvider,
            preferences: preferences,
          );
        }
        return shell;
      },
    );
  }
}

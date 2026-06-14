import 'package:caliber_design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'auth_provider.dart';
import 'onboarding_preferences.dart';
import 'onboarding_step_queue.dart';

final class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    required this.authProvider,
    required this.preferences,
    this.onComplete,
    super.key,
  });

  final AuthProvider authProvider;
  final OnboardingPreferences preferences;
  final VoidCallback? onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

final class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  final OnboardingStepQueue<_OnboardingStep>
  _steps = OnboardingStepQueue<_OnboardingStep>(const [
    _OnboardingStep(
      title: 'Welcome to Caliber',
      body:
          'Start privately. Your profile begins on this device before any account is required.',
      actionLabel: 'Continue',
    ),
    _OnboardingStep(
      title: 'Build from evidence',
      body:
          'Capture resumes, interviews, targets, and practice signals into one local-first workspace.',
      actionLabel: 'Continue',
    ),
    _OnboardingStep(
      title: 'Get started',
      body:
          'Create an anonymous local profile now. Sign-in providers can attach later without blocking setup.',
      actionLabel: 'Get Started',
    ),
  ]);

  int _activeIndex = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(color: tokens.colors.surface),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: CaliberGlassSurface(
                padding: EdgeInsets.all(tokens.spacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height:
                          tokens.spacing.section *
                          _OnboardingLayout.pageHeightUnits,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _steps.length,
                        onPageChanged: (index) {
                          setState(() => _activeIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return _OnboardingStepView(step: _steps.at(index));
                        },
                      ),
                    ),
                    SizedBox(height: tokens.spacing.lg),
                    _OnboardingProgress(
                      activeIndex: _activeIndex,
                      count: _steps.length,
                    ),
                    SizedBox(height: tokens.spacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _advance,
                        child: Text(
                          _isSubmitting
                              ? 'Starting'
                              : _steps.at(_activeIndex).actionLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _advance() async {
    if (_activeIndex < _steps.length - 1) {
      await _pageController.nextPage(
        duration: context.caliberTokens.motion.normal,
        curve: context.caliberTokens.motion.standardCurve,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.authProvider.signInAnonymously();
      await widget.preferences.markComplete();
      widget.onComplete?.call();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

final class _OnboardingStepView extends StatelessWidget {
  const _OnboardingStepView({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step.title, style: tokens.typography.display),
        SizedBox(height: tokens.spacing.md),
        Text(step.body, style: tokens.typography.body),
      ],
    );
  }
}

final class _OnboardingProgress extends StatelessWidget {
  const _OnboardingProgress({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++) ...[
          AnimatedContainer(
            duration: tokens.motion.fast,
            curve: tokens.motion.standardCurve,
            width: index == activeIndex ? tokens.spacing.xl : tokens.spacing.sm,
            height: tokens.spacing.sm,
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? tokens.colors.accent
                  : tokens.colors.divider,
              borderRadius: tokens.radii.control,
            ),
          ),
          if (index < count - 1) SizedBox(width: tokens.spacing.xs),
        ],
      ],
    );
  }
}

final class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  final String title;
  final String body;
  final String actionLabel;
}

abstract final class _OnboardingLayout {
  static const pageHeightUnits = 4.5;
}

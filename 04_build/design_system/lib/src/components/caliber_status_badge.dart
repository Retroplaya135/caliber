import 'package:flutter/material.dart';

import '../tokens/caliber_tokens.dart';

enum CaliberStatusTone {
  neutral,
  success,
  warning,
  danger,
}

class CaliberStatusBadge extends StatelessWidget {
  const CaliberStatusBadge({
    required this.label,
    this.tone = CaliberStatusTone.neutral,
    super.key,
  });

  final String label;
  final CaliberStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    final colors = switch (tone) {
      CaliberStatusTone.neutral => (
          background: tokens.colors.surfaceSunken,
          foreground: tokens.colors.onSurface,
        ),
      CaliberStatusTone.success => (
          background: tokens.colors.successContainer,
          foreground: tokens.colors.onSuccessContainer,
        ),
      CaliberStatusTone.warning => (
          background: tokens.colors.warningContainer,
          foreground: tokens.colors.onWarningContainer,
        ),
      CaliberStatusTone.danger => (
          background: tokens.colors.dangerContainer,
          foreground: tokens.colors.onDangerContainer,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: tokens.radii.control,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.xs,
        ),
        child: Text(
          label,
          style: tokens.typography.caption.copyWith(color: colors.foreground),
        ),
      ),
    );
  }
}

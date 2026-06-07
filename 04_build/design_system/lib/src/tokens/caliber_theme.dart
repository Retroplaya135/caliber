import 'package:flutter/material.dart';

import 'caliber_tokens.dart';

abstract final class CaliberTheme {
  static ThemeData light({CaliberThemeOverrides? overrides}) {
    return _build(
      brightness: Brightness.light,
      tokens: overrides?.merge(CaliberTokens.light) ?? CaliberTokens.light,
    );
  }

  static ThemeData dark({CaliberThemeOverrides? overrides}) {
    return _build(
      brightness: Brightness.dark,
      tokens: overrides?.merge(CaliberTokens.dark) ?? CaliberTokens.dark,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required CaliberTokens tokens,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.colors.accent,
      onPrimary: tokens.colors.onAccent,
      secondary: tokens.colors.focus,
      onSecondary: tokens.colors.onAccent,
      error: tokens.colors.danger,
      onError: tokens.colors.onDangerContainer,
      surface: tokens.colors.surface,
      onSurface: tokens.colors.onSurface,
    );
    final textTheme = tokens.typography.textTheme(tokens.colors);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.colors.surface,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: tokens.colors.surfaceRaised,
        elevation: tokens.spacing.none,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: tokens.radii.panel),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.glass.reducedTransparencyFillColor,
        elevation: tokens.spacing.none,
        shape: RoundedRectangleBorder(borderRadius: tokens.radii.panel),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.glass.reducedTransparencyFillColor,
        modalBackgroundColor: tokens.glass.reducedTransparencyFillColor,
        shape: RoundedRectangleBorder(borderRadius: tokens.radii.sheet),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.colors.accent,
          foregroundColor: tokens.colors.onAccent,
          elevation: tokens.spacing.none,
          padding: tokens.spacing.insetControl,
          shape: RoundedRectangleBorder(borderRadius: tokens.radii.control),
          textStyle: tokens.typography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.colors.onSurface,
          padding: tokens.spacing.insetControl,
          side: BorderSide(color: tokens.colors.divider),
          shape: RoundedRectangleBorder(borderRadius: tokens.radii.control),
          textStyle: tokens.typography.label,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }
}

@immutable
class CaliberThemeOverrides {
  const CaliberThemeOverrides({this.tokens});

  final CaliberTokens? tokens;

  CaliberTokens merge(CaliberTokens base) {
    return tokens == null
        ? base
        : base.copyWith(
            colors: tokens!.colors,
            typography: tokens!.typography,
            spacing: tokens!.spacing,
            radii: tokens!.radii,
            elevation: tokens!.elevation,
            motion: tokens!.motion,
            glass: tokens!.glass,
          );
  }
}

class CaliberThemeScope extends StatelessWidget {
  const CaliberThemeScope({
    required this.child,
    this.overrides,
    super.key,
  });

  final CaliberThemeOverrides? overrides;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parent = Theme.of(context);
    final baseTokens = context.caliberTokens;
    final scopedTokens = overrides?.merge(baseTokens) ?? baseTokens;

    return Theme(
      data: parent.copyWith(
        extensions: [
          scopedTokens,
        ],
      ),
      child: child,
    );
  }
}

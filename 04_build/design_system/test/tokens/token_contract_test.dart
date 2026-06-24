import 'package:caliber_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ThemeData exposes CaliberTokens extension for both modes', () {
    expect(
      CaliberTheme.light().extension<CaliberTokens>(),
      equals(CaliberTokens.light),
    );
    expect(
      CaliberTheme.dark().extension<CaliberTokens>(),
      equals(CaliberTokens.dark),
    );
  });

  test('page overrides are additive and do not mutate MASTER tokens', () {
    final override = CaliberThemeOverrides(
      tokens: CaliberTokens.light.copyWith(
        glass: CaliberTokens.light.glass.lerp(
          CaliberTokens.dark.glass,
          CaliberPrimitives.opacityGlassDark,
        ),
      ),
    );
    final themed = CaliberTheme.light(overrides: override);

    expect(CaliberTokens.light.glass.fillColor, isNot(equals(
      themed.extension<CaliberTokens>()!.glass.fillColor,
    )));
    expect(CaliberTheme.light().extension<CaliberTokens>(), CaliberTokens.light);
  });

  test('component themes are sourced from semantic tokens', () {
    final theme = CaliberTheme.light();
    final tokens = theme.extension<CaliberTokens>()!;
    final cardShape = theme.cardTheme.shape;

    expect(theme.colorScheme.primary, tokens.colors.accent);
    expect(theme.dialogTheme.backgroundColor,
        tokens.glass.reducedTransparencyFillColor);
    expect(cardShape, isA<RoundedRectangleBorder>());
  });
}

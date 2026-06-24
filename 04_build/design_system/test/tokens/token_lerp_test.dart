import 'package:caliber_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('token copyWith preserves unspecified MASTER groups', () {
    final changed = CaliberTokens.light.copyWith(glass: CaliberTokens.dark.glass);

    expect(changed.colors, CaliberTokens.light.colors);
    expect(changed.typography, CaliberTokens.light.typography);
    expect(changed.spacing, CaliberTokens.light.spacing);
    expect(changed.radii, CaliberTokens.light.radii);
    expect(changed.elevation, CaliberTokens.light.elevation);
    expect(changed.motion, CaliberTokens.light.motion);
    expect(changed.glass, CaliberTokens.dark.glass);
  });

  test('token interpolation keeps every group addressable', () {
    final interpolated = CaliberTokens.light.lerp(CaliberTokens.dark, 0.5);

    expect(interpolated.colors.surface, isA<Color>());
    expect(interpolated.typography.body.fontSize, greaterThan(0));
    expect(interpolated.spacing.insetPanel, isA<EdgeInsets>());
    expect(interpolated.radii.panel, isA<BorderRadius>());
    expect(interpolated.elevation.panel, isNotEmpty);
    expect(interpolated.motion.normal, CaliberTokens.light.motion.normal);
    expect(interpolated.glass.borderWidth, CaliberTokens.light.glass.borderWidth);
  });

  test('theme override scope replaces only the Caliber token extension', () {
    final override = CaliberThemeOverrides(
      tokens: CaliberTokens.dark.copyWith(colors: CaliberTokens.light.colors),
    );
    final scoped = override.merge(CaliberTokens.light);

    expect(scoped.colors, CaliberTokens.light.colors);
    expect(scoped.glass, CaliberTokens.dark.glass);
  });
}

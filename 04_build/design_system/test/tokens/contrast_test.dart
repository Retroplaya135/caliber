import 'dart:math' as math;

import 'package:caliber_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Caliber token contrast', () {
    test('light theme text roles meet WCAG AA', () {
      _expectContrast(CaliberTokens.light.colors.onSurface,
          CaliberTokens.light.colors.surface);
      _expectContrast(CaliberTokens.light.colors.onSurfaceMuted,
          CaliberTokens.light.colors.surface);
      _expectContrast(CaliberTokens.light.colors.onAccent,
          CaliberTokens.light.colors.accent);
    });

    test('dark theme text roles meet WCAG AA', () {
      _expectContrast(
          CaliberTokens.dark.colors.onSurface, CaliberTokens.dark.colors.surface);
      _expectContrast(CaliberTokens.dark.colors.onSurfaceMuted,
          CaliberTokens.dark.colors.surface);
      _expectContrast(
          CaliberTokens.dark.colors.onAccent, CaliberTokens.dark.colors.accent);
    });

    test('glass fallback surfaces preserve readable text contrast', () {
      _expectContrast(
        CaliberTokens.light.colors.onSurface,
        CaliberTokens.light.glass.reducedTransparencyFillColor,
      );
      _expectContrast(
        CaliberTokens.dark.colors.onSurface,
        CaliberTokens.dark.glass.reducedTransparencyFillColor,
      );
    });
  });
}

void _expectContrast(Color foreground, Color background) {
  expect(
    _contrastRatio(foreground, background),
    greaterThanOrEqualTo(4.5),
    reason: '$foreground on $background must meet WCAG AA contrast.',
  );
}

double _contrastRatio(Color foreground, Color background) {
  final first = _relativeLuminance(foreground);
  final second = _relativeLuminance(background);
  final lighter = math.max(first, second);
  final darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double channel(double normalized) {
    if (normalized <= 0.03928) {
      return normalized / 12.92;
    }
    return math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

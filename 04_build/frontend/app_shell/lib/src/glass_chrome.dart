import 'package:flutter/material.dart';

class GlassChromeTokens extends ThemeExtension<GlassChromeTokens> {
  const GlassChromeTokens({
    required this.blurSigma,
    required this.surfaceOpacity,
    required this.borderOpacity,
    required this.reducedTransparency,
  });

  final double blurSigma;
  final double surfaceOpacity;
  final double borderOpacity;
  final bool reducedTransparency;

  static const fallback = GlassChromeTokens(
    blurSigma: 18,
    surfaceOpacity: 0.72,
    borderOpacity: 0.28,
    reducedTransparency: false,
  );

  static GlassChromeTokens resolve(BuildContext context) {
    final theme = Theme.of(context);
    final direct = theme.extension<GlassChromeTokens>();
    if (direct != null) {
      return direct;
    }

    for (final extension in theme.extensions.values) {
      final bridged = _tryBridgeGlassKit(extension);
      if (bridged != null) {
        return bridged;
      }
    }

    return fallback;
  }

  @override
  GlassChromeTokens copyWith({
    double? blurSigma,
    double? surfaceOpacity,
    double? borderOpacity,
    bool? reducedTransparency,
  }) {
    return GlassChromeTokens(
      blurSigma: blurSigma ?? this.blurSigma,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      reducedTransparency: reducedTransparency ?? this.reducedTransparency,
    );
  }

  @override
  GlassChromeTokens lerp(ThemeExtension<GlassChromeTokens>? other, double t) {
    if (other is! GlassChromeTokens) {
      return this;
    }
    return GlassChromeTokens(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t),
      surfaceOpacity: lerpDouble(surfaceOpacity, other.surfaceOpacity, t),
      borderOpacity: lerpDouble(borderOpacity, other.borderOpacity, t),
      reducedTransparency: t < 0.5 ? reducedTransparency : other.reducedTransparency,
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;

GlassChromeTokens? _tryBridgeGlassKit(ThemeExtension<dynamic> extension) {
  try {
    final dynamic candidate = extension;
    final dynamic glass = candidate.glass;
    return GlassChromeTokens(
      blurSigma: _asDouble(glass.blur),
      surfaceOpacity: _colorAlpha(glass.fillColor),
      borderOpacity: _colorAlpha(glass.borderColor),
      reducedTransparency: false,
    );
  } on Object {
    return null;
  }
}

double _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  throw ArgumentError('expected numeric Glass Kit token');
}

double _colorAlpha(Object? value) {
  if (value is Color) {
    return value.a;
  }
  throw ArgumentError('expected color Glass Kit token');
}

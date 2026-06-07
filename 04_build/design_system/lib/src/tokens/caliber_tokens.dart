import 'package:flutter/material.dart';

import 'caliber_primitives.dart';

@immutable
class CaliberTokens extends ThemeExtension<CaliberTokens> {
  const CaliberTokens({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radii,
    required this.elevation,
    required this.motion,
    required this.glass,
  });

  final CaliberColorTokens colors;
  final CaliberTypeTokens typography;
  final CaliberSpacingTokens spacing;
  final CaliberRadiusTokens radii;
  final CaliberElevationTokens elevation;
  final CaliberMotionTokens motion;
  final CaliberGlassTokens glass;

  static const light = CaliberTokens(
    colors: CaliberColorTokens.light,
    typography: CaliberTypeTokens.base,
    spacing: CaliberSpacingTokens.base,
    radii: CaliberRadiusTokens.base,
    elevation: CaliberElevationTokens.light,
    motion: CaliberMotionTokens.base,
    glass: CaliberGlassTokens.light,
  );

  static const dark = CaliberTokens(
    colors: CaliberColorTokens.dark,
    typography: CaliberTypeTokens.base,
    spacing: CaliberSpacingTokens.base,
    radii: CaliberRadiusTokens.base,
    elevation: CaliberElevationTokens.dark,
    motion: CaliberMotionTokens.base,
    glass: CaliberGlassTokens.dark,
  );

  @override
  CaliberTokens copyWith({
    CaliberColorTokens? colors,
    CaliberTypeTokens? typography,
    CaliberSpacingTokens? spacing,
    CaliberRadiusTokens? radii,
    CaliberElevationTokens? elevation,
    CaliberMotionTokens? motion,
    CaliberGlassTokens? glass,
  }) {
    return CaliberTokens(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      elevation: elevation ?? this.elevation,
      motion: motion ?? this.motion,
      glass: glass ?? this.glass,
    );
  }

  @override
  CaliberTokens lerp(ThemeExtension<CaliberTokens>? other, double t) {
    if (other is! CaliberTokens) {
      return this;
    }
    return CaliberTokens(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      spacing: spacing.lerp(other.spacing, t),
      radii: radii.lerp(other.radii, t),
      elevation: elevation.lerp(other.elevation, t),
      motion: motion.lerp(other.motion, t),
      glass: glass.lerp(other.glass, t),
    );
  }
}

@immutable
class CaliberColorTokens {
  const CaliberColorTokens({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.accent,
    required this.onAccent,
    required this.focus,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.divider,
    required this.scrim,
    required this.clear,
  });

  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color accent;
  final Color onAccent;
  final Color focus;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color onDangerContainer;
  final Color divider;
  final Color scrim;
  final Color clear;

  static const light = CaliberColorTokens(
    surface: CaliberPrimitives.colorMist,
    surfaceRaised: CaliberPrimitives.colorMistRaised,
    surfaceSunken: CaliberPrimitives.colorMistSunken,
    onSurface: CaliberPrimitives.colorInk,
    onSurfaceMuted: CaliberPrimitives.colorGraphiteSoft,
    accent: CaliberPrimitives.colorTeal,
    onAccent: CaliberPrimitives.colorWhite,
    focus: CaliberPrimitives.colorBlue,
    success: CaliberPrimitives.colorGreen,
    successContainer: CaliberPrimitives.colorGreenSoft,
    onSuccessContainer: CaliberPrimitives.colorGreen,
    warning: CaliberPrimitives.colorAmber,
    warningContainer: CaliberPrimitives.colorAmberSoft,
    onWarningContainer: CaliberPrimitives.colorAmber,
    danger: CaliberPrimitives.colorRed,
    dangerContainer: CaliberPrimitives.colorRedSoft,
    onDangerContainer: CaliberPrimitives.colorRed,
    divider: CaliberPrimitives.colorLineLight,
    scrim: Color(0x8F111315),
    clear: CaliberPrimitives.colorClear,
  );

  static const dark = CaliberColorTokens(
    surface: CaliberPrimitives.colorInk,
    surfaceRaised: CaliberPrimitives.colorInkRaised,
    surfaceSunken: CaliberPrimitives.colorBlack,
    onSurface: CaliberPrimitives.colorMist,
    onSurfaceMuted: CaliberPrimitives.colorMistSunken,
    accent: CaliberPrimitives.colorTealSoft,
    onAccent: CaliberPrimitives.colorInk,
    focus: CaliberPrimitives.colorBlueSoft,
    success: CaliberPrimitives.colorGreenSoft,
    successContainer: CaliberPrimitives.colorGreen,
    onSuccessContainer: CaliberPrimitives.colorMistRaised,
    warning: CaliberPrimitives.colorAmberSoft,
    warningContainer: CaliberPrimitives.colorAmber,
    onWarningContainer: CaliberPrimitives.colorInk,
    danger: CaliberPrimitives.colorRedSoft,
    dangerContainer: CaliberPrimitives.colorRed,
    onDangerContainer: CaliberPrimitives.colorMistRaised,
    divider: CaliberPrimitives.colorLineDark,
    scrim: Color(0xB3000000),
    clear: CaliberPrimitives.colorClear,
  );

  CaliberColorTokens lerp(CaliberColorTokens other, double t) {
    return CaliberColorTokens(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      onDangerContainer:
          Color.lerp(onDangerContainer, other.onDangerContainer, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      clear: Color.lerp(clear, other.clear, t)!,
    );
  }
}

@immutable
class CaliberTypeTokens {
  const CaliberTypeTokens({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
  });

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle label;
  final TextStyle caption;

  static const base = CaliberTypeTokens(
    display: CaliberPrimitives.typeDisplay,
    headline: CaliberPrimitives.typeHeadline,
    title: CaliberPrimitives.typeTitle,
    body: CaliberPrimitives.typeBody,
    bodyStrong: CaliberPrimitives.typeBodyStrong,
    label: CaliberPrimitives.typeLabel,
    caption: CaliberPrimitives.typeCaption,
  );

  TextTheme textTheme(CaliberColorTokens colors) {
    return TextTheme(
      displaySmall: display.copyWith(color: colors.onSurface),
      headlineSmall: headline.copyWith(color: colors.onSurface),
      titleMedium: title.copyWith(color: colors.onSurface),
      bodyMedium: body.copyWith(color: colors.onSurface),
      bodySmall: body.copyWith(color: colors.onSurfaceMuted),
      labelLarge: label.copyWith(color: colors.onSurface),
      labelSmall: caption.copyWith(color: colors.onSurfaceMuted),
    );
  }

  CaliberTypeTokens lerp(CaliberTypeTokens other, double t) {
    return CaliberTypeTokens(
      display: TextStyle.lerp(display, other.display, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyStrong: TextStyle.lerp(bodyStrong, other.bodyStrong, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

@immutable
class CaliberSpacingTokens {
  const CaliberSpacingTokens({
    required this.none,
    required this.hair,
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.section,
    required this.insetControl,
    required this.insetPanel,
    required this.stackGap,
  });

  final double none;
  final double hair;
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double section;
  final EdgeInsets insetControl;
  final EdgeInsets insetPanel;
  final double stackGap;

  static const base = CaliberSpacingTokens(
    none: CaliberPrimitives.space0,
    hair: CaliberPrimitives.space1,
    xxs: CaliberPrimitives.space2,
    xs: CaliberPrimitives.space3,
    sm: CaliberPrimitives.space4,
    md: CaliberPrimitives.space5,
    lg: CaliberPrimitives.space6,
    xl: CaliberPrimitives.space8,
    xxl: CaliberPrimitives.space9,
    section: CaliberPrimitives.space12,
    insetControl: EdgeInsets.symmetric(
      horizontal: CaliberPrimitives.space6,
      vertical: CaliberPrimitives.space5,
    ),
    insetPanel: EdgeInsets.all(CaliberPrimitives.space6),
    stackGap: CaliberPrimitives.space5,
  );

  CaliberSpacingTokens lerp(CaliberSpacingTokens other, double t) {
    return CaliberSpacingTokens(
      none: _lerpDouble(none, other.none, t),
      hair: _lerpDouble(hair, other.hair, t),
      xxs: _lerpDouble(xxs, other.xxs, t),
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
      section: _lerpDouble(section, other.section, t),
      insetControl: EdgeInsets.lerp(insetControl, other.insetControl, t)!,
      insetPanel: EdgeInsets.lerp(insetPanel, other.insetPanel, t)!,
      stackGap: _lerpDouble(stackGap, other.stackGap, t),
    );
  }
}

@immutable
class CaliberRadiusTokens {
  const CaliberRadiusTokens({
    required this.focus,
    required this.control,
    required this.panel,
    required this.sheet,
  });

  final BorderRadius focus;
  final BorderRadius control;
  final BorderRadius panel;
  final BorderRadius sheet;

  static const base = CaliberRadiusTokens(
    focus: BorderRadius.all(Radius.circular(CaliberPrimitives.radiusFocus)),
    control: BorderRadius.all(Radius.circular(CaliberPrimitives.radiusControl)),
    panel: BorderRadius.all(Radius.circular(CaliberPrimitives.radiusPanel)),
    sheet: BorderRadius.vertical(
      top: Radius.circular(CaliberPrimitives.radiusSheet),
    ),
  );

  CaliberRadiusTokens lerp(CaliberRadiusTokens other, double t) {
    return CaliberRadiusTokens(
      focus: BorderRadius.lerp(focus, other.focus, t)!,
      control: BorderRadius.lerp(control, other.control, t)!,
      panel: BorderRadius.lerp(panel, other.panel, t)!,
      sheet: BorderRadius.lerp(sheet, other.sheet, t)!,
    );
  }
}

@immutable
class CaliberElevationTokens {
  const CaliberElevationTokens({
    required this.panel,
    required this.overlay,
  });

  final List<BoxShadow> panel;
  final List<BoxShadow> overlay;

  static const light = CaliberElevationTokens(
    panel: CaliberPrimitives.shadowPanelLight,
    overlay: CaliberPrimitives.shadowPanelLight,
  );

  static const dark = CaliberElevationTokens(
    panel: CaliberPrimitives.shadowPanelDark,
    overlay: CaliberPrimitives.shadowPanelDark,
  );

  CaliberElevationTokens lerp(CaliberElevationTokens other, double t) {
    return CaliberElevationTokens(
      panel: BoxShadow.lerpList(panel, other.panel, t)!,
      overlay: BoxShadow.lerpList(overlay, other.overlay, t)!,
    );
  }
}

@immutable
class CaliberMotionTokens {
  const CaliberMotionTokens({
    required this.fast,
    required this.normal,
    required this.emphasis,
    required this.slow,
    required this.standardCurve,
    required this.emphasisCurve,
  });

  final Duration fast;
  final Duration normal;
  final Duration emphasis;
  final Duration slow;
  final Curve standardCurve;
  final Curve emphasisCurve;

  static const base = CaliberMotionTokens(
    fast: CaliberPrimitives.durationFast,
    normal: CaliberPrimitives.durationNormal,
    emphasis: CaliberPrimitives.durationEmphasis,
    slow: CaliberPrimitives.durationSlow,
    standardCurve: Curves.easeOutCubic,
    emphasisCurve: Curves.easeInOutCubic,
  );

  CaliberMotionTokens lerp(CaliberMotionTokens other, double t) {
    return t < CaliberPrimitives.opacityScrim
        ? this
        : other;
  }
}

@immutable
class CaliberGlassTokens {
  const CaliberGlassTokens({
    required this.blur,
    required this.fillOpacity,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.contrastOverlay,
    required this.reducedTransparencyFillColor,
    required this.elevation,
  });

  final double blur;
  final double fillOpacity;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final Color contrastOverlay;
  final Color reducedTransparencyFillColor;
  final List<BoxShadow> elevation;

  static const light = CaliberGlassTokens(
    blur: CaliberPrimitives.blurPanel,
    fillOpacity: CaliberPrimitives.opacityGlassLight,
    fillColor: Color(0xB8FFFFFF),
    borderColor: Color(0xCCFFFFFF),
    borderWidth: CaliberPrimitives.strokeHairline,
    contrastOverlay: Color(0x1A111315),
    reducedTransparencyFillColor: CaliberPrimitives.colorMistRaised,
    elevation: CaliberPrimitives.shadowPanelLight,
  );

  static const dark = CaliberGlassTokens(
    blur: CaliberPrimitives.blurPanel,
    fillOpacity: CaliberPrimitives.opacityGlassDark,
    fillColor: Color(0x8A1B1F24),
    borderColor: Color(0x523A414A),
    borderWidth: CaliberPrimitives.strokeHairline,
    contrastOverlay: Color(0x2EFFFFFF),
    reducedTransparencyFillColor: CaliberPrimitives.colorInkRaised,
    elevation: CaliberPrimitives.shadowPanelDark,
  );

  CaliberGlassTokens lerp(CaliberGlassTokens other, double t) {
    return CaliberGlassTokens(
      blur: _lerpDouble(blur, other.blur, t),
      fillOpacity: _lerpDouble(fillOpacity, other.fillOpacity, t),
      fillColor: Color.lerp(fillColor, other.fillColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderWidth: _lerpDouble(borderWidth, other.borderWidth, t),
      contrastOverlay: Color.lerp(contrastOverlay, other.contrastOverlay, t)!,
      reducedTransparencyFillColor: Color.lerp(
        reducedTransparencyFillColor,
        other.reducedTransparencyFillColor,
        t,
      )!,
      elevation: BoxShadow.lerpList(elevation, other.elevation, t)!,
    );
  }
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

extension CaliberTokensContext on BuildContext {
  CaliberTokens get caliberTokens {
    final tokens = Theme.of(this).extension<CaliberTokens>();
    assert(tokens != null, 'CaliberTokens missing from ThemeData.extensions.');
    return tokens ?? CaliberTokens.light;
  }
}

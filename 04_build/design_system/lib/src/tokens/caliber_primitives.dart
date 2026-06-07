import 'package:flutter/material.dart';

abstract final class CaliberPrimitives {
  static const colorInk = Color(0xFF111315);
  static const colorInkRaised = Color(0xFF1B1F24);
  static const colorGraphite = Color(0xFF2E343B);
  static const colorGraphiteSoft = Color(0xFF5D6671);
  static const colorMist = Color(0xFFF7F8F9);
  static const colorMistRaised = Color(0xFFFFFFFF);
  static const colorMistSunken = Color(0xFFE9EDF1);
  static const colorLineLight = Color(0xFFD8DEE5);
  static const colorLineDark = Color(0xFF3A414A);
  static const colorTeal = Color(0xFF087F7B);
  static const colorTealDeep = Color(0xFF055F5C);
  static const colorTealSoft = Color(0xFFE2F4F2);
  static const colorBlue = Color(0xFF1F6FEB);
  static const colorBlueSoft = Color(0xFFE8F0FF);
  static const colorGreen = Color(0xFF1F7A4D);
  static const colorGreenSoft = Color(0xFFE4F3EA);
  static const colorAmber = Color(0xFF9A6700);
  static const colorAmberSoft = Color(0xFFFFF4D5);
  static const colorRed = Color(0xFFB42318);
  static const colorRedSoft = Color(0xFFFFE7E5);
  static const colorWhite = Color(0xFFFFFFFF);
  static const colorBlack = Color(0xFF000000);
  static const colorClear = Color(0x00000000);

  static const opacityGlassLight = 0.72;
  static const opacityGlassDark = 0.54;
  static const opacityOverlayLight = 0.10;
  static const opacityOverlayDark = 0.18;
  static const opacityBadgeFill = 0.16;
  static const opacityScrim = 0.56;

  static const space0 = 0.0;
  static const space1 = 2.0;
  static const space2 = 4.0;
  static const space3 = 6.0;
  static const space4 = 8.0;
  static const space5 = 12.0;
  static const space6 = 16.0;
  static const space7 = 20.0;
  static const space8 = 24.0;
  static const space9 = 32.0;
  static const space10 = 40.0;
  static const space11 = 48.0;
  static const space12 = 64.0;

  static const radiusFocus = 6.0;
  static const radiusControl = 8.0;
  static const radiusPanel = 8.0;
  static const radiusSheet = 8.0;

  static const strokeHairline = 1.0;
  static const strokeFocus = 2.0;
  static const blurSubtle = 10.0;
  static const blurPanel = 16.0;
  static const blurOverlay = 22.0;

  static const durationFast = Duration(milliseconds: 120);
  static const durationNormal = Duration(milliseconds: 180);
  static const durationEmphasis = Duration(milliseconds: 240);
  static const durationSlow = Duration(milliseconds: 320);

  static const shadowPanelLight = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
  static const shadowPanelDark = [
    BoxShadow(
      color: Color(0x52000000),
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];

  static const typeFontFamily = 'Inter';
  static const typeDisplay = TextStyle(
    fontFamily: typeFontFamily,
    fontSize: 36,
    height: 1.08,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const typeHeadline = TextStyle(
    fontFamily: typeFontFamily,
    fontSize: 26,
    height: 1.16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const typeTitle = TextStyle(
    fontFamily: typeFontFamily,
    fontSize: 19,
    height: 1.24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const typeBody = TextStyle(
    fontFamily: typeFontFamily,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const typeBodyStrong = TextStyle(
    fontFamily: typeFontFamily,
    fontSize: 16,
    height: 1.42,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const typeLabel = TextStyle(
    fontFamily: typeFontFamily,
    fontSize: 13,
    height: 1.24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const typeCaption = TextStyle(
    fontFamily: typeFontFamily,
    fontSize: 12,
    height: 1.28,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
}

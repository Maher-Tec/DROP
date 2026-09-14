import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropTheme {

  static const Color deepBlue = Color(0xFF0A1628);

  static const Color oceanBlue = Color(0xFF0D2B4A);

  static const Color waterBlue = Color(0xFF1A4B6E);

  static const Color tealAccent = Color(0xFF2E8B9A);

  static const Color softWhite = Color(0xFFF0F8FF);

  static const Color gradientTop = Color(0xFF050D18);

  static const Color gradientMid = Color(0xFF0A1E38);

  static const Color gradientBottom = Color(0xFF0D2845);

  static const Color dropAccent = Color(0xFF5BB8D9);

  static const Color dropHighlight = Color(0xFF8ED4F0);

  static const Color glowColor = Color(0xFF3A9BC2);

  static const Color rippleColor = Color(0xFF4AADCC);


  static const Color lightSkyWater = Color(0xFFE8F5F7);

  static const Color lightWaterBlue = Color(0xFFC5E7ED);

  static const Color lightOceanMid = Color(0xFFADD9E5);

  static const Color lightOceanDeep = Color(0xFF9DCFE0);

  static const Color darkTealText = Color(0xFF1A252F);

  static const Color lightDropAccent = Color(0xFF3A9BC2);

  static const Color lightGlow = Color(0xFF5BB8D9);

  static const Color lightRipple = Color(0xFF7CC8E0);


  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientMid, gradientBottom],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightSkyWater, lightWaterBlue, lightOceanMid, lightOceanDeep],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient lakeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF081420),
      Color(0xFF0C2035),
      Color(0xFF102848),
      Color(0xFF1A3A5C),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient lightLakeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE0F2F7),
      Color(0xFFB8DDE8),
      Color(0xFF9DCFE0),
      Color(0xFF85C4D8),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );


  static LinearGradient getBackgroundGradient(bool isDarkMode) {
    return isDarkMode ? backgroundGradient : lightBackgroundGradient;
  }

  static LinearGradient getLakeGradient(bool isDarkMode) {
    return isDarkMode ? lakeGradient : lightLakeGradient;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? softWhite : darkTealText;
  }

  static Color getAccentColor(bool isDarkMode) {
    return isDarkMode ? dropAccent : lightDropAccent;
  }

  static Color getGlowColor(bool isDarkMode) {
    return isDarkMode ? glowColor : lightGlow;
  }


  static Color _textColor(bool isDarkMode, [double alpha = 1.0]) {
    return isDarkMode
        ? softWhite.withValues(alpha: alpha)
        : darkTealText.withValues(alpha: alpha);
  }

  static Color _hintColor(bool isDarkMode, [double alpha = 0.5]) {
    return isDarkMode
        ? softWhite.withValues(alpha: alpha)
        : darkTealText.withValues(alpha: alpha);
  }

  static TextStyle getTitleStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 42,
        fontWeight: FontWeight.w500,
        letterSpacing: 14,
        color: _textColor(isDarkMode),
      );
    } catch (e) {
      return TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w500,
        letterSpacing: 14,
        color: _textColor(isDarkMode),
      );
    }
  }

  static TextStyle getTaglineStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 3,
        color: _hintColor(isDarkMode, 0.65),
      );
    } catch (e) {
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 3,
        color: _hintColor(isDarkMode, 0.65),
      );
    }
  }

  static TextStyle getBodyStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _textColor(isDarkMode),
      );
    } catch (e) {
      return TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _textColor(isDarkMode),
      );
    }
  }

  static TextStyle getHintStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
        color: _hintColor(isDarkMode, 0.45),
      );
    } catch (e) {
      return TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
        color: _hintColor(isDarkMode, 0.45),
      );
    }
  }

  static TextStyle getInputStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: _textColor(isDarkMode, 0.95),
      );
    } catch (e) {
      return TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: _textColor(isDarkMode, 0.95),
      );
    }
  }

  static TextStyle getPlaceholderStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        color: _hintColor(isDarkMode, 0.4),
      );
    } catch (e) {
      return TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        color: _hintColor(isDarkMode, 0.4),
      );
    }
  }

  static TextStyle getButtonStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: isDarkMode ? dropAccent : lightDropAccent,
      );
    } catch (e) {
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: isDarkMode ? dropAccent : lightDropAccent,
      );
    }
  }

  static TextStyle getClosureStyle(bool isDarkMode) {
    try {
      return GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.5,
        color: _textColor(isDarkMode, 0.9),
      );
    } catch (e) {
      return TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.5,
        color: _textColor(isDarkMode, 0.9),
      );
    }
  }


  static TextStyle get titleStyle => getTitleStyle(true);
  static TextStyle get taglineStyle => getTaglineStyle(true);
  static TextStyle get bodyStyle => getBodyStyle(true);
  static TextStyle get hintStyle => getHintStyle(true);
  static TextStyle get inputStyle => getInputStyle(true);
  static TextStyle get placeholderStyle => getPlaceholderStyle(true);
  static TextStyle get buttonStyle => getButtonStyle(true);
  static TextStyle get closureStyle => getClosureStyle(true);


  static const Duration splashDuration = Duration(milliseconds: 2500);

  static const Duration rippleAnimationDuration = Duration(milliseconds: 4000);

  static const Duration dropAnimationDuration = Duration(milliseconds: 3500);

  static const Duration fadeTransitionDuration = Duration(milliseconds: 600);

  static const Duration waveAnimationDuration = Duration(seconds: 8);


  static const Curve defaultCurve = Curves.easeInOut;

  static const Curve rippleCurve = Curves.easeOut;

  static const Curve dropFallCurve = Curves.easeInQuad;


  static bool isSmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.width < 380;
  }

  static double fontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return 0.85;
    if (width < 400) return 0.92;
    return 1.0;
  }

  static double spacing(BuildContext context, double base) {
    return base * fontScale(context);
  }


  static bool nightModeOverride = false;

  static bool isNightTime() {
    if (nightModeOverride) return true;
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 6;
  }

  static bool isEvening() {
    final hour = DateTime.now().hour;
    return hour >= 18 && hour < 20;
  }

  static LinearGradient get timeAwareGradient {
    if (isNightTime()) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF020508),
          Color(0xFF050D15),
          Color(0xFF081420),
        ],
        stops: [0.0, 0.5, 1.0],
      );
    } else if (isEvening()) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF040810), Color(0xFF081525), Color(0xFF0C2035)],
        stops: [0.0, 0.5, 1.0],
      );
    }
    return lakeGradient;
  }

  static double get animationSpeedMultiplier {
    if (isNightTime()) return 1.4;
    if (isEvening()) return 1.2;
    return 1.0;
  }

  static Duration adjustedDuration(Duration base) {
    return Duration(
      milliseconds: (base.inMilliseconds * animationSpeedMultiplier).round(),
    );
  }

  static double get ambientOpacity {
    if (isNightTime()) return 0.6;
    if (isEvening()) return 0.8;
    return 1.0;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DROP Design System - PREMIUM PRO MAX
/// 
/// A calming, minimalist design language for emotional release
/// Colors inspired by deep ocean water for realistic feel
class DropTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS - REALISTIC DEEP BLUE WATER PALETTE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Deep Blue - Primary dark color (deep ocean)
  static const Color deepBlue = Color(0xFF0A1628);
  
  /// Ocean Blue - Rich water color
  static const Color oceanBlue = Color(0xFF0D2B4A);
  
  /// Water Blue - Mid-tone water
  static const Color waterBlue = Color(0xFF1A4B6E);
  
  /// Teal Accent - Light shimmer
  static const Color tealAccent = Color(0xFF2E8B9A);
  
  /// Soft White - Text color (moonlight on water)
  static const Color softWhite = Color(0xFFF0F8FF);
  
  /// Very dark blue (near black) - Gradient top (night sky meeting water)
  static const Color gradientTop = Color(0xFF050D18);
  
  /// Deep ocean blue - Gradient middle
  static const Color gradientMid = Color(0xFF0A1E38);
  
  /// Slightly lighter blue - Gradient bottom (deep water)
  static const Color gradientBottom = Color(0xFF0D2845);
  
  /// Drop/Accent color - Luminous water droplet
  static const Color dropAccent = Color(0xFF5BB8D9);
  
  /// Bright drop highlight
  static const Color dropHighlight = Color(0xFF8ED4F0);
  
  /// Glow color - Soft blue luminescence
  static const Color glowColor = Color(0xFF3A9BC2);
  
  /// Ripple color
  static const Color rippleColor = Color(0xFF4AADCC);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS - REALISTIC WATER DEPTH
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Main background gradient (deep ocean, night water feel)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientMid, gradientBottom],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Lake surface gradient (calmer, lighter)
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

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY - PREMIUM SOFT FONTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// App title style - "DROP" (elegant, spaced)
  static TextStyle get titleStyle => GoogleFonts.quicksand(
    fontSize: 42,
    fontWeight: FontWeight.w500,
    letterSpacing: 14,
    color: softWhite,
  );
  
  /// Tagline style - "Let it go" (whisper)
  static TextStyle get taglineStyle => GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    letterSpacing: 3,
    color: softWhite.withValues(alpha: 0.65),
  );
  
  /// Main body text - "Drop one thought."
  static TextStyle get bodyStyle => GoogleFonts.quicksand(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: softWhite,
  );
  
  /// Hint text style - "One per day."
  static TextStyle get hintStyle => GoogleFonts.quicksand(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    letterSpacing: 2,
    color: softWhite.withValues(alpha: 0.35),
  );
  
  /// Input text style
  static TextStyle get inputStyle => GoogleFonts.quicksand(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: softWhite.withValues(alpha: 0.95),
  );
  
  /// Placeholder text style
  static TextStyle get placeholderStyle => GoogleFonts.quicksand(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
    color: softWhite.withValues(alpha: 0.35),
  );
  
  /// Button text style
  static TextStyle get buttonStyle => GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    color: dropAccent,
  );
  
  /// Closure text - "It's gone."
  static TextStyle get closureStyle => GoogleFonts.quicksand(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    color: softWhite.withValues(alpha: 0.9),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Splash screen duration before auto-transition
  static const Duration splashDuration = Duration(milliseconds: 2500);
  
  /// Ripple animation duration (slow, calming)
  static const Duration rippleAnimationDuration = Duration(milliseconds: 4000);
  
  /// Drop fall animation duration
  static const Duration dropAnimationDuration = Duration(milliseconds: 3500);
  
  /// Fade transition duration
  static const Duration fadeTransitionDuration = Duration(milliseconds: 600);
  
  /// Wave animation duration (very slow)
  static const Duration waveAnimationDuration = Duration(seconds: 8);

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION CURVES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Default animation curve - slow and smooth
  static const Curve defaultCurve = Curves.easeInOut;
  
  /// Ripple expansion curve
  static const Curve rippleCurve = Curves.easeOut;
  
  /// Drop fall curve - gravity feel
  static const Curve dropFallCurve = Curves.easeInQuad;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE RESPONSIVE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Check if device is small (< 380 width)
  static bool isSmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.width < 380;
  }
  
  /// Get responsive font scale
  static double fontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return 0.85;
    if (width < 400) return 0.92;
    return 1.0;
  }
  
  /// Get responsive spacing
  static double spacing(BuildContext context, double base) {
    return base * fontScale(context);
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // NIGHT MODE & TIME-OF-DAY AWARENESS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Check if it's night time (8 PM - 6 AM)
  static bool isNightTime() {
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 6;
  }
  
  /// Check if it's evening (6 PM - 8 PM)
  static bool isEvening() {
    final hour = DateTime.now().hour;
    return hour >= 18 && hour < 20;
  }
  
  /// Get time-aware gradient (darker at night)
  static LinearGradient get timeAwareGradient {
    if (isNightTime()) {
      // Very dark, almost black - true night mode
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF020508), // Near black
          Color(0xFF050D15),
          Color(0xFF081420),
        ],
        stops: [0.0, 0.5, 1.0],
      );
    } else if (isEvening()) {
      // Slightly warmer, deeper tones
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF040810),
          Color(0xFF081525),
          Color(0xFF0C2035),
        ],
        stops: [0.0, 0.5, 1.0],
      );
    }
    return lakeGradient;
  }
  
  /// Get animation speed multiplier (slower at night)
  static double get animationSpeedMultiplier {
    if (isNightTime()) return 1.4; // 40% slower at night
    if (isEvening()) return 1.2; // 20% slower in evening
    return 1.0;
  }
  
  /// Get adjusted duration for time of day
  static Duration adjustedDuration(Duration base) {
    return Duration(
      milliseconds: (base.inMilliseconds * animationSpeedMultiplier).round(),
    );
  }
  
  /// Get ambient opacity (dimmer at night)
  static double get ambientOpacity {
    if (isNightTime()) return 0.6;
    if (isEvening()) return 0.8;
    return 1.0;
  }
}


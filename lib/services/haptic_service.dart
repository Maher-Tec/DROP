import 'package:flutter/services.dart';

/// Haptic Service - Gentle vibration feedback for emotional moments
/// 
/// Uses Flutter's built-in HapticFeedback for reliable cross-platform support.
/// Creates physical connection to the emotional release experience.
class HapticService {
  
  /// Very gentle tap - for subtle interactions
  static Future<void> gentleTap() async {
    await HapticFeedback.selectionClick();
  }
  
  /// Soft tap - for page transitions
  static Future<void> softTap() async {
    await HapticFeedback.lightImpact();
  }
  
  /// Soft pulse - for button presses
  static Future<void> softPulse() async {
    await HapticFeedback.lightImpact();
  }
  
  /// Water drop impact - the main emotional moment
  /// A satisfying ripple-like pattern
  static Future<void> waterDropImpact() async {
    // Strong initial impact
    await HapticFeedback.mediumImpact();
    // Brief pause
    await Future.delayed(const Duration(milliseconds: 80));
    // Lighter ripple
    await HapticFeedback.lightImpact();
    // Brief pause
    await Future.delayed(const Duration(milliseconds: 60));
    // Softest ripple
    await HapticFeedback.selectionClick();
  }
  
  /// Closure feeling - when "It's gone." appears
  /// Very soft, peaceful vibration
  static Future<void> closurePulse() async {
    await HapticFeedback.lightImpact();
  }
  
  /// Heavy impact - for emphasis
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }
}

import 'package:flutter/services.dart';

class HapticService {
  static Future<void> gentleTap() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> softTap() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> waterDropImpact() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.selectionClick();
  }

  static Future<void> closurePulse() async {
    await HapticFeedback.lightImpact();
  }
}

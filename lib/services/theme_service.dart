import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

class ThemeService extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _dark = true;
  bool _night = false;
  bool _reducedMotion = false;

  Timer? _timeOfDayTimer;
  bool _isNightTime = DropTheme.isNightTime();
  bool _isEvening = DropTheme.isEvening();

  bool get isDarkMode => _night || _dark;
  bool get isLightMode => !isDarkMode;
  bool get nightModeOverride => _night;
  bool get reducedMotion => _reducedMotion;

  Future<void> init() async {
    await loadTheme();
    _watchTimeOfDay();
  }

  Future<void> loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _dark = _prefs!.getBool('theme_mode') ?? true;
    _night = _prefs!.getBool('night_mode_override') ?? false;
    _reducedMotion = _prefs!.getBool('reduced_motion') ?? false;
    DropTheme.nightModeOverride = _night;
    notifyListeners();
  }

  void _watchTimeOfDay() {
    _timeOfDayTimer?.cancel();
    _timeOfDayTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final isNightTime = DropTheme.isNightTime();
      final isEvening = DropTheme.isEvening();
      if (isNightTime == _isNightTime && isEvening == _isEvening) return;
      _isNightTime = isNightTime;
      _isEvening = isEvening;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timeOfDayTimer?.cancel();
    super.dispose();
  }

  Future<void> toggleTheme() => setDarkMode(!isDarkMode);

  Future<void> setDarkMode(bool value) async {
    _dark = value;
    _night = false;
    DropTheme.nightModeOverride = false;
    notifyListeners();
    await _prefs?.setBool('theme_mode', value);
    await _prefs?.setBool('night_mode_override', false);
  }

  Future<void> setNightMode(bool value) async {
    _night = value;
    DropTheme.nightModeOverride = value;
    notifyListeners();
    await _prefs?.setBool('night_mode_override', value);
  }

  Future<void> setReducedMotion(bool value) async {
    _reducedMotion = value;
    notifyListeners();
    await _prefs?.setBool('reduced_motion', value);
  }
}

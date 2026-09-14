import 'package:shared_preferences/shared_preferences.dart';

/// Remove activity metadata left by versions with a daily limit.
/// Run on every launch so an interrupted migration is safely retried.
Future<void> removeLegacyDropHistory() async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in ['lastDropDate', 'dropHistory']) {
    if (prefs.containsKey(key)) {
      await prefs.remove(key);
    }
  }
}

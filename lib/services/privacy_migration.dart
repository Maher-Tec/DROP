import 'package:shared_preferences/shared_preferences.dart';

Future<void> removeLegacyDropHistory() async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in ['lastDropDate', 'dropHistory']) {
    if (prefs.containsKey(key)) {
      await prefs.remove(key);
    }
  }
}

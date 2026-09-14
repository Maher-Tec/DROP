import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop/services/privacy_migration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('removes legacy activity history and preserves preferences', () async {
    SharedPreferences.setMockInitialValues({
      'lastDropDate': '2026-01-01T10:00:00.000',
      'dropHistory': ['2026-01-01T10:00:00.000'],
      'sound_enabled': false,
      'onboarding_completed': true,
    });

    await removeLegacyDropHistory();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('lastDropDate'), isFalse);
    expect(prefs.containsKey('dropHistory'), isFalse);
    expect(prefs.getBool('sound_enabled'), isFalse);
    expect(prefs.getBool('onboarding_completed'), isTrue);
  });
}

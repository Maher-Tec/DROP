import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/drop_app.dart';
import 'services/notification_service.dart';
import 'services/privacy_migration.dart';
import 'services/sound_service.dart';
import 'services/theme_service.dart';
import 'services/widget_launch_service.dart';

/// Runs [action] and swallows any failure so one misbehaving initializer
/// (a plugin, a locked prefs file, an OEM quirk) can never keep the app
/// from reaching [runApp].
Future<void> _tryInit(String name, Future<void> Function() action) async {
  try {
    await action();
  } catch (e, stack) {
    debugPrint('Startup step "$name" failed: $e\n$stack');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _tryInit('privacy migration', removeLegacyDropHistory);

  // Load the saved sound preference before any screen requests playback.
  await _tryInit('sound service', soundService.init);

  // Initialize notification service for daily reminders
  await _tryInit('notification service', notificationService.init);

  // Initialize theme service
  final themeService = ThemeService();
  await _tryInit('theme service', themeService.init);

  String? widgetAction;
  await _tryInit('widget launch service', () async {
    widgetAction = await WidgetLaunchService.getInitialAction();
  });

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: DropApp(initialWidgetAction: widgetAction),
    ),
  );
}

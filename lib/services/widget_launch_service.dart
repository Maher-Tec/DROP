import 'package:flutter/services.dart';

/// Receives privacy-safe action names from the native Android home widget.
/// No thought text or activity data crosses this channel.
class WidgetLaunchService {
  static const MethodChannel _channel = MethodChannel(
    'com.maherahmed.drop/widget_launch',
  );

  static Future<String?> getInitialAction() async {
    try {
      return await _channel.invokeMethod<String>('getInitialAction');
    } on MissingPluginException {
      return null;
    }
  }

  static void listen(void Function(String action) onAction) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'widgetAction' && call.arguments is String) {
        onAction(call.arguments as String);
      }
    });
  }

  static void stopListening() => _channel.setMethodCallHandler(null);
}

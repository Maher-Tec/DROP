import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// NOTIFICATION SERVICE - Daily Reminder System
/// 
/// Features:
/// - Schedule daily reminder at user's chosen time
/// - Calming notification messages
/// - Enable/disable reminders
/// - Persist reminder settings
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  SharedPreferences? _prefs;
  
  static const String _enabledKey = 'reminder_enabled';
  static const String _hourKey = 'reminder_hour';
  static const String _minuteKey = 'reminder_minute';
  static const int _notificationId = 1;
  
  // Calming reminder messages
  static const List<String> _reminderMessages = [
    "Take a moment to release something.",
    "Your safe space is waiting.",
    "One thought. One drop. Peace.",
    "Ready to let go?",
    "A calm moment awaits you.",
    "Time to release and breathe.",
    "Drop one thought today.",
  ];
  
  /// Initialize the notification service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Initialize timezone
    tz_data.initializeTimeZones();
    
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // Re-schedule if reminder was enabled
    if (isReminderEnabled) {
      await scheduleReminder(
        TimeOfDay(hour: reminderHour, minute: reminderMinute),
      );
    }
  }
  
  void _onNotificationTap(NotificationResponse response) {
    // App will be opened when notification is tapped
    // No additional action needed - just opens the app
  }
  
  /// Check if reminders are enabled
  bool get isReminderEnabled => _prefs?.getBool(_enabledKey) ?? false;
  
  /// Get reminder hour (default: 20 = 8 PM)
  int get reminderHour => _prefs?.getInt(_hourKey) ?? 20;
  
  /// Get reminder minute (default: 0)
  int get reminderMinute => _prefs?.getInt(_minuteKey) ?? 0;
  
  /// Get reminder time as TimeOfDay
  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour, minute: reminderMinute);
  
  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return false;
  }
  
  /// Schedule daily reminder at specified time
  Future<void> scheduleReminder(TimeOfDay time) async {
    // Cancel any existing reminder
    await cancelReminder();
    
    // Save settings
    await _prefs?.setBool(_enabledKey, true);
    await _prefs?.setInt(_hourKey, time.hour);
    await _prefs?.setInt(_minuteKey, time.minute);
    
    // Calculate next occurrence of scheduled time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Random calming message
    final message = _reminderMessages[
      DateTime.now().millisecondsSinceEpoch % _reminderMessages.length
    ];
    
    // Notification details
    const androidDetails = AndroidNotificationDetails(
      'drop_daily_reminder',
      'Daily Reminders',
      channelDescription: 'Gentle daily reminders to release your thoughts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: false,
      enableVibration: true,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Schedule daily repeating notification
    await _notifications.zonedSchedule(
      _notificationId,
      'DROP',
      message,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  /// Cancel scheduled reminder
  Future<void> cancelReminder() async {
    await _prefs?.setBool(_enabledKey, false);
    await _notifications.cancel(_notificationId);
  }
  
  /// Toggle reminder on/off
  Future<void> toggleReminder(bool enabled, {TimeOfDay? time}) async {
    if (enabled) {
      await scheduleReminder(time ?? reminderTime);
    } else {
      await cancelReminder();
    }
  }
}

/// Global singleton instance
final notificationService = NotificationService();

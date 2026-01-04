import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/notification_service.dart';

/// REMINDER SETTINGS - Simple toggle with time picker
/// 
/// A minimal, calming settings widget for daily reminder configuration.
/// Can be placed at bottom of home screen or in a settings modal.
class ReminderSettings extends StatefulWidget {
  const ReminderSettings({super.key});

  @override
  State<ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await notificationService.init();
    if (mounted) {
      setState(() {
        _enabled = notificationService.isReminderEnabled;
        _time = notificationService.reminderTime;
        _loading = false;
      });
    }
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      // Request permission first
      final granted = await notificationService.requestPermissions();
      if (!granted) {
        // Show message if permission denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notification permission required',
                style: TextStyle(color: DropTheme.softWhite),
              ),
              backgroundColor: DropTheme.deepBlue,
            ),
          );
        }
        return;
      }
    }
    
    setState(() => _enabled = value);
    await notificationService.toggleReminder(value, time: _time);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: DropTheme.dropAccent,
              surface: DropTheme.deepBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _time) {
      setState(() => _time = picked);
      if (_enabled) {
        await notificationService.scheduleReminder(_time);
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = DropTheme.fontScale(context);
    
    if (_loading) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: DropTheme.deepBlue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DropTheme.softWhite.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: DropTheme.softWhite.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Daily Reminder',
                    style: DropTheme.bodyStyle.copyWith(
                      fontSize: 15 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _enabled,
                onChanged: _toggleReminder,
                activeTrackColor: DropTheme.dropAccent,
                thumbColor: WidgetStatePropertyAll(DropTheme.softWhite),
              ),
            ],
          ),
          
          // Time selector (only visible when enabled)
          if (_enabled) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: DropTheme.deepBlue.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remind me at',
                      style: DropTheme.hintStyle.copyWith(
                        fontSize: 13 * fontScale,
                        color: DropTheme.softWhite.withValues(alpha: 0.5),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatTime(_time),
                          style: DropTheme.bodyStyle.copyWith(
                            fontSize: 15 * fontScale,
                            color: DropTheme.dropAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.schedule_rounded,
                          color: DropTheme.dropAccent.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

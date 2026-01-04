import 'package:flutter/material.dart';
import 'app/drop_app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service for daily reminders
  await notificationService.init();
  
  runApp(const DropApp());
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/main_screen.dart';
import 'services/json_import_service.dart';
import 'services/notification_service.dart';
import 'theme/forest_night_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Import JSON data on first run
  final importService = JsonImportService();
  final isImported = await importService.isDataImported();
  if (!isImported) {
    print('🚀 First run detected - importing JSON data...');
    await importService.importAllData();
    print('✅ JSON data imported successfully');
  }

  // Initialize notification service
  final notificationService = NotificationService.instance;
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const LongevityApp());
}

class LongevityApp extends StatelessWidget {
  const LongevityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Longevity Tracker',
      debugShowCheckedModeBanner: false,
      theme: ForestNightTheme.theme,
      home: const MainScreen(),
    );
  }
}

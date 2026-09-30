import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/daily_task_instance.dart';
import 'database_service.dart';

/// Service for managing local notifications for daily tasks
class NotificationService {
  static final NotificationService instance = NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationService._init();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Linux initialization settings
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    // Initialize with callback for notification taps
    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
  }

  /// Handle notification tap or action button press
  static Future<void> _onNotificationResponse(NotificationResponse response) async {
    final taskId = int.tryParse(response.payload ?? '');
    if (taskId == null) return;

    final db = DatabaseService.instance;

    // Check if an action button was pressed
    if (response.actionId != null) {
      // Action button pressed
      switch (response.actionId) {
        case 'done':
          await _markTaskDone(taskId, db);
          break;
        case 'skip':
          await _markTaskSkipped(taskId, db);
          break;
      }
    } else {
      // Notification body tapped - could open app to task details
      print('Notification tapped for task: $taskId');
    }
  }

  /// Mark a task as done from notification
  static Future<void> _markTaskDone(int taskId, DatabaseService db) async {
    try {
      final tasks = await db.database.then((d) => d.query(
        'daily_tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      ));

      if (tasks.isNotEmpty) {
        final task = DailyTaskInstance.fromMap(tasks.first);
        final updated = task.copyWith(
          status: 'done',
          completedAt: DateTime.now(),
        );
        await db.updateDailyTask(updated);
        print('✅ Task $taskId marked as done');
      }
    } catch (e) {
      print('Error marking task done: $e');
    }
  }

  /// Mark a task as skipped from notification
  static Future<void> _markTaskSkipped(int taskId, DatabaseService db) async {
    try {
      final tasks = await db.database.then((d) => d.query(
        'daily_tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      ));

      if (tasks.isNotEmpty) {
        final task = DailyTaskInstance.fromMap(tasks.first);
        final updated = task.copyWith(
          status: 'skipped',
          skippedAt: DateTime.now(),
        );
        await db.updateDailyTask(updated);
        print('⏭️ Task $taskId marked as skipped');
      }
    } catch (e) {
      print('Error marking task skipped: $e');
    }
  }

  /// Request notification permissions (primarily for iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != true) return false;
    }

    // Android 13+ permissions
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted != true) return false;
    }

    return true;
  }

  /// Schedule a notification for a daily task
  Future<void> scheduleTaskNotification(DailyTaskInstance task) async {
    if (!_initialized) await initialize();

    // Skip if no planned time or no task ID
    if (task.plannedTime.isEmpty || task.id == null) return;

    // Parse the task date and time
    final taskDateStr = task.taskDate.toIso8601String().split('T')[0];
    final taskDateTime = _parseTaskDateTime(taskDateStr, task.plannedTime);
    if (taskDateTime == null) return;

    // Don't schedule notifications for past times
    if (taskDateTime.isBefore(DateTime.now())) return;

    // Create notification details
    final notificationDetails = _createNotificationDetails(task);

    // Schedule the notification
    await _notifications.zonedSchedule(
      id: task.id!,
      title: _getNotificationTitle(task),
      body: _getNotificationBody(task),
      scheduledDate: tz.TZDateTime.from(taskDateTime, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: task.id.toString(),
    );
  }

  /// Schedule notifications for multiple tasks
  Future<void> scheduleTaskNotifications(List<DailyTaskInstance> tasks) async {
    for (final task in tasks) {
      try {
        await scheduleTaskNotification(task);
      } catch (e) {
        // Log error but continue with other tasks
        print('Error scheduling notification for task ${task.id}: $e');
      }
    }
  }

  /// Cancel a notification for a task
  Future<void> cancelTaskNotification(int taskId) async {
    if (!_initialized) await initialize();
    await _notifications.cancel(id: taskId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _notifications.pendingNotificationRequests();
  }

  /// Parse task date and planned time into DateTime
  DateTime? _parseTaskDateTime(String taskDate, String plannedTime) {
    try {
      // taskDate is ISO format: "2026-04-06"
      final date = DateTime.parse(taskDate);

      // plannedTime examples: "8:00 AM", "6:30 PM", "sunrise+10min", etc.
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?')
          .firstMatch(plannedTime);

      if (timeMatch != null) {
        var hour = int.parse(timeMatch.group(1)!);
        final minute = int.parse(timeMatch.group(2)!);
        final period = timeMatch.group(3);

        if (period != null) {
          // 12-hour format
          if (period == 'PM' && hour != 12) hour += 12;
          if (period == 'AM' && hour == 12) hour = 0;
        }

        return DateTime(date.year, date.month, date.day, hour, minute);
      }

      // Special time formats (sunrise+10min, sunset-30min, etc.)
      // For now, default to 8 AM for morning tasks
      if (plannedTime.contains('sunrise') || plannedTime.contains('morning')) {
        return DateTime(date.year, date.month, date.day, 8, 0);
      }
      if (plannedTime.contains('sunset') || plannedTime.contains('evening')) {
        return DateTime(date.year, date.month, date.day, 18, 0);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create notification details with appropriate styling and actions
  NotificationDetails _createNotificationDetails(DailyTaskInstance task) {
    final androidDetails = AndroidNotificationDetails(
      'daily_tasks',
      'Daily Tasks',
      channelDescription: 'Notifications for your daily longevity tasks',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      actions: [
        AndroidNotificationAction(
          'done',
          '✓ Done',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'skip',
          'Skip',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails();

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );
  }

  /// Get notification title based on task category
  String _getNotificationTitle(DailyTaskInstance task) {
    switch (task.category) {
      case 'supplement':
        return '💊 Time for supplements';
      case 'exercise':
        return '💪 Time to exercise';
      case 'meal':
        return '🍽️ Meal time';
      case 'other':
      default:
        return '✨ Task reminder';
    }
  }

  /// Get notification body with task details
  String _getNotificationBody(DailyTaskInstance task) {
    return task.title;
  }

}

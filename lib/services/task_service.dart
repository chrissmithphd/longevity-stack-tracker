import '../models/daily_task_instance.dart';
import '../models/schedule/schedule_models.dart';
import 'database_service.dart';
import 'sun_timing_service.dart';
import 'notification_service.dart';

class TaskService {
  final DatabaseService _db = DatabaseService.instance;
  final SunTimingService _sunTiming = SunTimingService();
  final NotificationService _notifications = NotificationService.instance;

  /// Generate daily tasks for a specific date from schedule events
  Future<void> generateDailyTasks(DateTime date) async {
    // Check if tasks already exist for this date
    final existing = await _db.getDailyTasks(date);
    if (existing.isNotEmpty) {
      return; // Tasks already generated
    }

    // Get day of week (Mon, Tue, Wed, etc.)
    final dayOfWeek = _getDayOfWeek(date);

    // Get schedule events for this day that should be tasks
    final events = await _db.getScheduleTaskEvents(dayOfWeek);

    // Generate tasks from events
    for (final event in events) {
      await _generateTaskFromEvent(date, event);
    }

    // Schedule notifications for generated tasks
    final tasks = await _db.getDailyTasks(date);
    await _notifications.scheduleTaskNotifications(tasks);
  }

  /// Generate a task from a schedule event
  Future<void> _generateTaskFromEvent(
    DateTime date,
    ScheduleEvent event,
  ) async {
    String title = '';
    String category = '';
    bool isActive = true;

    // Initialize metadata early so it can be used in switch cases
    final metadata = Map<String, dynamic>.from(event.metadata ?? {});

    switch (event.eventType) {
      case 'supplements':
        if (event.supplementIds != null && event.supplementIds!.isNotEmpty) {
          // Get supplement details
          final supplements = await Future.wait(
            event.supplementIds!.map((id) => _db.getSupplement(id)),
          );

          final allSupps = supplements.whereType<Supplement>().toList();
          final activeSupps = allSupps.where((s) => s.active).toList();

          // Task is inactive if ALL supplements are inactive
          isActive = activeSupps.isNotEmpty;

          if (allSupps.length == 1) {
            title = allSupps.first.name;
            category = 'Supplements';
          } else if (allSupps.length > 1) {
            // Show count of active supplements if some are inactive
            if (activeSupps.length != allSupps.length) {
              title = '${activeSupps.length} of ${allSupps.length} Supplements';
            } else {
              title = '${allSupps.length} Supplements';
            }
            category = 'Supplements';
          } else {
            title = 'Supplements';
            category = 'Supplements';
          }
        } else {
          title = 'Supplements';
          category = 'Supplements';
        }
        break;

      case 'exercise':
        if (event.moduleId != null) {
          final module = await _db.getExerciseModule(event.moduleId!);
          isActive = module?.active ?? true;
          title = module?.name ?? event.details ?? 'Exercise';
          category = 'Exercise';

          // Check if this is an outdoor activity and adjust time
          if (module != null && module.details['outdoor'] == true) {
            metadata['is_outdoor'] = true;
            // Time will be adjusted below after metadata is set
          }
        } else {
          title = event.details ?? 'Exercise';
          category = 'Exercise';
        }
        break;

      case 'breathing':
        if (event.moduleId != null) {
          final module = await _db.getExerciseModule(event.moduleId!);
          isActive = module?.active ?? true;
          title = module?.name ?? 'Breathing Exercise';
          category = 'Recovery';
        } else {
          title = 'Breathing Exercise';
          category = 'Recovery';
        }
        break;

      case 'hydration':
        title = event.details ?? 'Hydration';
        category = 'Hydration';
        break;

      case 'caffeine':
        title = 'Caffeine';
        category = 'Supplements';
        break;

      default:
        title = event.getTitle();
        category = event.eventType;
    }

    // Merge isActive flag into metadata
    metadata['is_active'] = isActive;

    // For outdoor activities, store special format that will be calculated dynamically
    String plannedTime = event.time;
    if (metadata['is_outdoor'] == true) {
      // Determine if morning or evening based on original time
      final isMorning = _isMorningTime(event.time);
      if (isMorning) {
        plannedTime = 'sunrise+10min';
        metadata['time_calculation'] = 'sunrise+10';
      } else {
        // Get duration for evening activities
        final duration = await _getActivityDuration(event);
        plannedTime = 'sunset-${duration.inMinutes}min';
        metadata['time_calculation'] = 'sunset-${duration.inMinutes}';
      }
    }

    final task = DailyTaskInstance(
      scheduleEventId: event.id,
      taskDate: date,
      title: title,
      category: category,
      plannedTime: plannedTime,
      status: 'pending',
      eventType: event.eventType,
      metadata: metadata,
    );

    await _db.insertDailyTask(task);
  }

  /// Adjust planned time for outdoor activities based on sunrise/sunset
  Future<String> _adjustOutdoorTime(
    DateTime date,
    ScheduleEvent event,
    Map<String, dynamic> metadata,
  ) async {
    final sunTimes = await _sunTiming.getSunTimes(date);

    // If no location set, return original time
    if (!sunTimes.hasLocation) {
      return event.time;
    }

    // Determine if this is a morning or evening activity based on original time
    final isMorning = _isMorningTime(event.time);

    if (isMorning) {
      // Morning outdoor activity: sunrise + 10 minutes
      final adjustedTime = sunTimes.sunrise.add(const Duration(minutes: 10));
      return _formatTime(adjustedTime);
    } else {
      // Evening outdoor activity: ensure it finishes before sunset
      // Get activity duration from module details if available
      final duration = await _getActivityDuration(event);
      final latestStart = sunTimes.sunset.subtract(duration);
      return _formatTime(latestStart);
    }
  }

  /// Check if a time string represents morning (before noon)
  bool _isMorningTime(String timeStr) {
    // Check for explicit AM/PM
    if (timeStr.toLowerCase().contains('am')) return true;
    if (timeStr.toLowerCase().contains('pm')) return false;

    // Parse hour
    final hourMatch = RegExp(r'(\d{1,2})').firstMatch(timeStr);
    if (hourMatch != null) {
      final hour = int.parse(hourMatch.group(1)!);
      return hour < 12;
    }

    // Default to morning
    return true;
  }

  /// Get activity duration from module details
  Future<Duration> _getActivityDuration(ScheduleEvent event) async {
    if (event.moduleId != null) {
      final module = await _db.getExerciseModule(event.moduleId!);
      if (module != null) {
        // Check for duration_min field
        if (module.details['duration_min'] != null) {
          final minutes = module.details['duration_min'] as int;
          return Duration(minutes: minutes);
        }
        // Check for duration_min_range field (use max)
        if (module.details['duration_min_range'] != null) {
          final range = module.details['duration_min_range'] as List;
          final maxMinutes = range.isNotEmpty ? range.last as int : 30;
          return Duration(minutes: maxMinutes);
        }
      }
    }

    // Default duration: 30 minutes
    return const Duration(minutes: 30);
  }

  /// Format DateTime to time string (e.g., "8:00 AM")
  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Get tasks for today, generating them if needed
  Future<List<DailyTaskInstance>> getTodaysTasks() async {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    await generateDailyTasks(dateOnly);
    return await _db.getDailyTasks(dateOnly);
  }

  /// Mark a task as done
  Future<void> markTaskDone(DailyTaskInstance task) async {
    final updated = task.copyWith(
      status: 'done',
      completedAt: DateTime.now(),
      skippedAt: null,
    );
    await _db.updateDailyTask(updated);
  }

  /// Mark a task as skipped
  Future<void> markTaskSkipped(DailyTaskInstance task) async {
    final updated = task.copyWith(
      status: 'skipped',
      skippedAt: DateTime.now(),
      completedAt: null,
    );
    await _db.updateDailyTask(updated);
  }

  /// Reset a task to pending
  Future<void> resetTask(DailyTaskInstance task) async {
    final updated = task.copyWith(
      status: 'pending',
      completedAt: null,
      skippedAt: null,
    );
    await _db.updateDailyTask(updated);
  }

  /// Get task history
  Future<List<DailyTaskInstance>> getTaskHistory({int limit = 30}) async {
    return await _db.getTaskHistory(limit: limit);
  }

  /// Get day of week abbreviation (Mon, Tue, etc.)
  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  /// Get task details (supplements, exercise module, etc.)
  Future<Map<String, dynamic>> getTaskDetails(DailyTaskInstance task) async {
    final details = <String, dynamic>{};

    if (task.scheduleEventId != null) {
      // This is a task generated from new schedule system
      final events = await _db.getScheduleEvents();
      final event = events.firstWhere(
        (e) => e.id == task.scheduleEventId,
        orElse: () => ScheduleEvent(
          dayOfWeek: '',
          time: '',
          eventType: '',
          isTask: false,
        ),
      );

      if (event.eventType == 'supplements' && event.supplementIds != null) {
        final supplements = await Future.wait(
          event.supplementIds!.map((id) => _db.getSupplement(id)),
        );
        details['supplements'] = supplements.whereType<Supplement>().toList();
      }

      if (event.moduleId != null) {
        final module = await _db.getExerciseModule(event.moduleId!);
        if (module != null) {
          details['exercise_module'] = module;
        }
      }

      details['event'] = event;
    }

    return details;
  }
}

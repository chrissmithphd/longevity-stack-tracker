import 'dart:convert';

class ScheduleEvent {
  final int? id;
  final String dayOfWeek; // 'Mon', 'Tue', etc.
  final String time; // 'HH:mm' format
  final String eventType; // 'supplements', 'exercise', 'breathing', 'hydration', 'meal', 'caffeine', 'sleep_prep', 'sleep', 'optional'
  final String? details; // Text details
  final String? moduleId; // Reference to exercise module
  final List<String>? supplementIds; // List of supplement IDs
  final bool isTask; // true if this should be a task, false if just reminder/info
  final Map<String, dynamic>? metadata; // Additional data

  ScheduleEvent({
    this.id,
    required this.dayOfWeek,
    required this.time,
    required this.eventType,
    this.details,
    this.moduleId,
    this.supplementIds,
    required this.isTask,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'time': time,
      'event_type': eventType,
      'details': details,
      'module_id': moduleId,
      'supplement_ids': supplementIds != null ? jsonEncode(supplementIds) : null,
      'is_task': isTask ? 1 : 0,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory ScheduleEvent.fromMap(Map<String, dynamic> map) {
    return ScheduleEvent(
      id: map['id'] as int?,
      dayOfWeek: map['day_of_week'] as String,
      time: map['time'] as String,
      eventType: map['event_type'] as String,
      details: map['details'] as String?,
      moduleId: map['module_id'] as String?,
      supplementIds: map['supplement_ids'] != null
          ? List<String>.from(jsonDecode(map['supplement_ids'] as String))
          : null,
      isTask: (map['is_task'] as int) == 1,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  factory ScheduleEvent.fromJson(String day, Map<String, dynamic> json) {
    final eventType = json['type'] as String;
    final time = json['time'] as String;

    // Determine if this should be a task
    bool isTask = _shouldBeTask(eventType, json);

    // Extract details
    String? details;
    String? moduleId;
    List<String>? supplementIds;

    if (json['details'] is String) {
      details = json['details'] as String;
    } else if (json['details'] is List) {
      // Supplement list
      supplementIds = _extractSupplementIds(json['details'] as List);
    }

    if (json['module'] != null) {
      moduleId = json['module'] as String;
    }

    return ScheduleEvent(
      dayOfWeek: day,
      time: time,
      eventType: eventType,
      details: details,
      moduleId: moduleId,
      supplementIds: supplementIds,
      isTask: isTask,
      metadata: json,
    );
  }

  static bool _shouldBeTask(String eventType, Map<String, dynamic> json) {
    // Task-generating event types
    if (eventType == 'supplements' ||
        eventType == 'exercise' ||
        eventType == 'breathing' ||
        eventType == 'hydration') {
      return true;
    }

    // Caffeine is a task unless it's the last one of the day (as reminder)
    if (eventType == 'caffeine') {
      final details = json['details'] as String? ?? '';
      // If it says "Must finish by" it's info/reminder, otherwise it's a task
      if (details.contains('Must finish by') || details.contains('allowed')) {
        return false; // Info/reminder
      }
      return true; // Task
    }

    return false; // Everything else is info/reminder
  }

  static List<String> _extractSupplementIds(List<dynamic> supplementList) {
    List<String> ids = [];
    for (var item in supplementList) {
      if (item is String) {
        // Parse supplement name to extract ID
        // e.g., "Creatine 3–5 g" -> try to match against known supplements
        // For now, store the raw string; we'll match during import
        ids.add(item);
      }
    }
    return ids;
  }

  String getTitle() {
    switch (eventType) {
      case 'supplements':
        if (supplementIds != null && supplementIds!.isNotEmpty) {
          return supplementIds!.length == 1
              ? 'Take supplement'
              : 'Take ${supplementIds!.length} supplements';
        }
        return 'Supplements';

      case 'exercise':
        if (moduleId != null) {
          return moduleId!
              .split('_')
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' ');
        }
        return details ?? 'Exercise';

      case 'breathing':
        return 'Breathing exercise';

      case 'hydration':
        return 'Hydration';

      case 'caffeine':
        return 'Caffeine';

      case 'meal':
        return 'Meal time';

      case 'sleep_prep':
        return 'Sleep prep';

      case 'sleep':
        return 'Bedtime';

      default:
        return eventType;
    }
  }
}

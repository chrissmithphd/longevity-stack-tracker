import 'dart:convert';

class DailyTaskInstance {
  final int? id;
  final int? templateId;
  final int? scheduleEventId;
  final DateTime taskDate;
  final String title;
  final String category;
  final String plannedTime;
  final String status; // 'pending', 'done', 'skipped'
  final DateTime? completedAt;
  final DateTime? skippedAt;
  final String? notes;
  final String? eventType;
  final Map<String, dynamic>? metadata;

  DailyTaskInstance({
    this.id,
    this.templateId,
    this.scheduleEventId,
    required this.taskDate,
    required this.title,
    required this.category,
    required this.plannedTime,
    this.status = 'pending',
    this.completedAt,
    this.skippedAt,
    this.notes,
    this.eventType,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_id': templateId,
      'schedule_event_id': scheduleEventId,
      'task_date': taskDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'title': title,
      'category': category,
      'planned_time': plannedTime,
      'status': status,
      'completed_at': completedAt?.toIso8601String(),
      'skipped_at': skippedAt?.toIso8601String(),
      'notes': notes,
      'event_type': eventType,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory DailyTaskInstance.fromMap(Map<String, dynamic> map) {
    return DailyTaskInstance(
      id: map['id'] as int?,
      templateId: map['template_id'] as int?,
      scheduleEventId: map['schedule_event_id'] as int?,
      taskDate: DateTime.parse(map['task_date'] as String),
      title: map['title'] as String,
      category: map['category'] as String,
      plannedTime: map['planned_time'] as String,
      status: map['status'] as String,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      skippedAt: map['skipped_at'] != null
          ? DateTime.parse(map['skipped_at'] as String)
          : null,
      notes: map['notes'] as String?,
      eventType: map['event_type'] as String?,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  DailyTaskInstance copyWith({
    int? id,
    int? templateId,
    int? scheduleEventId,
    DateTime? taskDate,
    String? title,
    String? category,
    String? plannedTime,
    String? status,
    DateTime? completedAt,
    DateTime? skippedAt,
    String? notes,
    String? eventType,
    Map<String, dynamic>? metadata,
  }) {
    return DailyTaskInstance(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      scheduleEventId: scheduleEventId ?? this.scheduleEventId,
      taskDate: taskDate ?? this.taskDate,
      title: title ?? this.title,
      category: category ?? this.category,
      plannedTime: plannedTime ?? this.plannedTime,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      skippedAt: skippedAt ?? this.skippedAt,
      notes: notes ?? this.notes,
      eventType: eventType ?? this.eventType,
      metadata: metadata ?? this.metadata,
    );
  }
}

class WeeklyScheduleTemplate {
  final int? id;
  final String title;
  final String category;
  final int dayOfWeek; // 1=Monday, 7=Sunday
  final String plannedTime; // HH:mm format
  final String instructions;
  final bool isOptional;
  final bool active;

  WeeklyScheduleTemplate({
    this.id,
    required this.title,
    required this.category,
    required this.dayOfWeek,
    required this.plannedTime,
    required this.instructions,
    this.isOptional = false,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'day_of_week': dayOfWeek,
      'planned_time': plannedTime,
      'instructions': instructions,
      'is_optional': isOptional ? 1 : 0,
      'active': active ? 1 : 0,
    };
  }

  factory WeeklyScheduleTemplate.fromMap(Map<String, dynamic> map) {
    return WeeklyScheduleTemplate(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      dayOfWeek: map['day_of_week'] as int,
      plannedTime: map['planned_time'] as String,
      instructions: map['instructions'] as String,
      isOptional: (map['is_optional'] as int) == 1,
      active: (map['active'] as int) == 1,
    );
  }
}

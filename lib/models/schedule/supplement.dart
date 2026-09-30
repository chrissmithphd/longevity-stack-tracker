class Supplement {
  final String id;
  final String name;
  final String dose;
  final String timingRule;
  final bool foodRequired;
  final String notes;
  final bool active;
  final int importance; // 1-10 scale, higher = more important for longevity

  Supplement({
    required this.id,
    required this.name,
    required this.dose,
    required this.timingRule,
    required this.foodRequired,
    required this.notes,
    this.active = true,
    this.importance = 5, // Default medium importance
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'timing_rule': timingRule,
      'food_required': foodRequired ? 1 : 0,
      'notes': notes,
      'active': active ? 1 : 0,
      'importance': importance,
    };
  }

  factory Supplement.fromMap(Map<String, dynamic> map) {
    return Supplement(
      id: map['id'] as String,
      name: map['name'] as String,
      dose: map['dose'] as String,
      timingRule: map['timing_rule'] as String,
      foodRequired: (map['food_required'] as int) == 1,
      notes: map['notes'] as String,
      active: map['active'] != null ? (map['active'] as int) == 1 : true,
      importance: map['importance'] as int? ?? 5,
    );
  }

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['id'] as String,
      name: json['name'] as String,
      dose: json['dose'] as String,
      timingRule: json['timing_rule'] as String,
      foodRequired: json['food_required'] as bool,
      notes: json['notes'] as String? ?? '',
      importance: json['importance'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'timing_rule': timingRule,
      'food_required': foodRequired,
      'notes': notes,
      'active': active,
      'importance': importance,
    };
  }

  Supplement copyWith({
    String? id,
    String? name,
    String? dose,
    String? timingRule,
    bool? foodRequired,
    String? notes,
    bool? active,
    int? importance,
  }) {
    return Supplement(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      timingRule: timingRule ?? this.timingRule,
      foodRequired: foodRequired ?? this.foodRequired,
      notes: notes ?? this.notes,
      active: active ?? this.active,
      importance: importance ?? this.importance,
    );
  }
}

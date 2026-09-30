import 'dart:convert';

class ExerciseModule {
  final String id;
  final String name;
  final String moduleType; // 'walk', 'joint_sequence', 'strength', 'zone2', 'vo2max', 'stretch', 'breathing'
  final Map<String, dynamic> details;
  final bool active;

  ExerciseModule({
    required this.id,
    required this.name,
    required this.moduleType,
    required this.details,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'module_type': moduleType,
      'details': jsonEncode(details),
      'active': active ? 1 : 0,
    };
  }

  factory ExerciseModule.fromMap(Map<String, dynamic> map) {
    return ExerciseModule(
      id: map['id'] as String,
      name: map['name'] as String,
      moduleType: map['module_type'] as String,
      details: jsonDecode(map['details'] as String) as Map<String, dynamic>,
      active: map['active'] != null ? (map['active'] as int) == 1 : true,
    );
  }

  factory ExerciseModule.fromJson(String moduleId, dynamic jsonData) {
    // Determine module type from the JSON structure
    String moduleType = 'unknown';
    Map<String, dynamic> details;

    if (jsonData is Map<String, dynamic>) {
      // Object-based module (walk, zone2, vo2max, breathing)
      final json = jsonData;

      if (json.containsKey('duration_min')) {
        if (json.containsKey('intensity')) {
          if (json.containsKey('rounds')) {
            moduleType = 'vo2max';
          } else if (json.containsKey('modalities')) {
            moduleType = 'zone2';
          } else {
            moduleType = 'walk';
          }
        }
      } else if (json.containsKey('pattern')) {
        moduleType = 'breathing';
      }

      details = json;
    } else if (jsonData is List) {
      // Array-based module (strength, stretch, joint_sequence)
      final json = jsonData;

      if (json.isNotEmpty && json[0] is Map) {
        final firstItem = json[0] as Map<String, dynamic>;

        if (firstItem.containsKey('sets')) {
          moduleType = 'strength';
        } else if (firstItem.containsKey('duration_sec_per_side')) {
          moduleType = 'stretch';
        } else if (firstItem.containsKey('reps')) {
          moduleType = 'joint_sequence';
        }
      }

      details = {'exercises': json};
    } else {
      details = {'raw': jsonData};
    }

    return ExerciseModule(
      id: moduleId,
      name: _generateNameFromId(moduleId),
      moduleType: moduleType,
      details: details,
    );
  }

  static String _generateNameFromId(String id) {
    return id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'module_type': moduleType,
      'details': details,
      'active': active,
    };
  }

  String getSummary() {
    switch (moduleType) {
      case 'walk':
        final duration = details['duration_min'];
        if (duration != null) {
          final intensity = details['intensity'] ?? 'easy';
          return '$duration min • $intensity';
        }
        final range = details['duration_min_range'] as List?;
        if (range != null && range.length >= 2) {
          return '${range[0]}–${range[1]} min';
        }
        return 'Walk';

      case 'zone2':
        final range = details['duration_min_range'] as List?;
        if (range != null && range.length >= 2) {
          return '${range[0]}–${range[1]} min • Zone 2';
        }
        return 'Zone 2 cardio';

      case 'vo2max':
        final rounds = details['rounds'] ?? 4;
        final work = details['work_interval_min'] ?? 4;
        return '$rounds rounds • ${work}min work';

      case 'strength':
        final exercises = details['exercises'] as List? ?? [];
        return '${exercises.length} exercises';

      case 'joint_sequence':
        final exercises = details['exercises'] as List? ?? [];
        return '${exercises.length} movements';

      case 'stretch':
        final exercises = details['exercises'] as List? ?? [];
        return '${exercises.length} stretches';

      case 'breathing':
        final duration = details['duration_min'];
        final breaths = details['breaths'];
        if (duration != null) {
          return '$duration min breathing';
        } else if (breaths != null) {
          return '$breaths breaths';
        }
        return 'Breathing exercise';

      default:
        return name;
    }
  }

  ExerciseModule copyWith({
    String? id,
    String? name,
    String? moduleType,
    Map<String, dynamic>? details,
    bool? active,
  }) {
    return ExerciseModule(
      id: id ?? this.id,
      name: name ?? this.name,
      moduleType: moduleType ?? this.moduleType,
      details: details ?? this.details,
      active: active ?? this.active,
    );
  }
}

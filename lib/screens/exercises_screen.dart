import 'package:flutter/material.dart';
import '../models/schedule/schedule_models.dart';
import '../services/database_service.dart';
import '../services/task_service.dart';
import '../theme/forest_night_theme.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<ExerciseModule> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    final exercises = await _db.getAllExerciseModules();
    setState(() {
      _exercises = exercises;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 64,
                        color: ForestNightTheme.secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No exercises yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ForestNightTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(ForestNightTheme.space4),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return _ExerciseCard(
                      exercise: exercise,
                      onActiveChanged: (bool active) async {
                        final updated = exercise.copyWith(active: active);
                        await _db.updateExerciseModule(updated);

                        // Regenerate today's tasks to reflect the change
                        final today = DateTime.now();
                        final todayDate = DateTime(today.year, today.month, today.day);
                        await _db.deleteTasksForDate(todayDate);
                        await TaskService().generateDailyTasks(todayDate);

                        await _loadExercises();
                      },
                    );
                  },
                ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final ExerciseModule exercise;
  final Function(bool) onActiveChanged;

  const _ExerciseCard({
    required this.exercise,
    required this.onActiveChanged,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.exercise.active ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: ForestNightTheme.space3),
        decoration: BoxDecoration(
          color: ForestNightTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
          border: Border.all(
            color: widget.exercise.active
                ? ForestNightTheme.tertiaryBackground
                : ForestNightTheme.tertiaryText.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(ForestNightTheme.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.exercise.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ForestNightTheme.active.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
                        ),
                        child: Text(
                          widget.exercise.moduleType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ForestNightTheme.active,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: widget.exercise.active,
                          onChanged: widget.onActiveChanged,
                          activeColor: ForestNightTheme.active,
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: ForestNightTheme.tertiaryText,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: ForestNightTheme.space2),
                  Text(
                    widget.exercise.getSummary(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details section
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ForestNightTheme.space4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(ForestNightTheme.radiusMedium),
                  bottomRight: Radius.circular(ForestNightTheme.radiusMedium),
                ),
              ),
              child: _buildDetailsContent(context),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    switch (widget.exercise.moduleType) {
      case 'strength':
        return _buildStrengthDetails(context);
      case 'joint_sequence':
        return _buildJointSequenceDetails(context);
      case 'stretch':
        return _buildStretchDetails(context);
      case 'walk':
        return _buildWalkDetails(context);
      case 'zone2':
        return _buildZone2Details(context);
      case 'vo2max':
        return _buildVO2MaxDetails(context);
      case 'breathing':
        return _buildBreathingDetails(context);
      default:
        return _buildGenericDetails(context);
    }
  }

  Widget _buildStrengthDetails(BuildContext context) {
    final exercises = widget.exercise.details['exercises'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        const SizedBox(height: ForestNightTheme.space3),
        Text(
          'Exercises:',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ForestNightTheme.tertiaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ForestNightTheme.space2),
        ...exercises.map((ex) {
          final exercise = ex as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: ForestNightTheme.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ForestNightTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise['sets']} sets × ${exercise['reps']} reps • ${exercise['rest_sec']}s rest',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ForestNightTheme.secondaryText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildJointSequenceDetails(BuildContext context) {
    final exercises = widget.exercise.details['exercises'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        const SizedBox(height: ForestNightTheme.space3),
        Text(
          'Movements:',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ForestNightTheme.tertiaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ForestNightTheme.space2),
        ...exercises.map((ex) {
          final exercise = ex as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: ForestNightTheme.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ForestNightTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildRepsText(exercise),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ForestNightTheme.secondaryText,
                  ),
                ),
                if (exercise['details'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    exercise['details'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ForestNightTheme.tertiaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStretchDetails(BuildContext context) {
    final exercises = widget.exercise.details['exercises'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        const SizedBox(height: ForestNightTheme.space3),
        Text(
          'Stretches:',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ForestNightTheme.tertiaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ForestNightTheme.space2),
        ...exercises.map((ex) {
          final exercise = ex as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: ForestNightTheme.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ForestNightTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildDurationText(exercise),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ForestNightTheme.secondaryText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWalkDetails(BuildContext context) {
    final details = widget.exercise.details;
    final durationRange = details['duration_min_range'] as List?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        const SizedBox(height: ForestNightTheme.space2),
        if (details['duration_min'] != null)
          _DetailRow(label: 'Duration', value: '${details['duration_min']} min'),
        if (durationRange != null)
          _DetailRow(label: 'Duration', value: '${durationRange[0]}–${durationRange[1]} min'),
        if (details['intensity'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Intensity', value: details['intensity']),
        ],
        if (details['breathing'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Breathing', value: details['breathing']),
        ],
        if (details['terrain'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Terrain', value: details['terrain']),
        ],
        if (details['notes'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Notes', value: details['notes']),
        ],
      ],
    );
  }

  Widget _buildZone2Details(BuildContext context) {
    final details = widget.exercise.details;
    final durationRange = details['duration_min_range'] as List?;
    final modalities = details['modalities'] != null
        ? (details['modalities'] as List).join(', ')
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        if (durationRange != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Duration', value: '${durationRange[0]}–${durationRange[1]} min'),
        ],
        if (details['hr_target_percentage'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Heart Rate', value: '${details['hr_target_percentage']}% max'),
        ],
        if (modalities != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Modalities', value: modalities),
        ],
        if (details['talk_test'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Talk Test', value: details['talk_test']),
        ],
        if (details['breathing'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Breathing', value: details['breathing']),
        ],
      ],
    );
  }

  Widget _buildVO2MaxDetails(BuildContext context) {
    final details = widget.exercise.details;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        const SizedBox(height: ForestNightTheme.space2),
        _DetailRow(label: 'Rounds', value: '${details['rounds'] ?? 4}'),
        const SizedBox(height: ForestNightTheme.space2),
        _DetailRow(label: 'Work Interval', value: '${details['work_interval_min']} min'),
        const SizedBox(height: ForestNightTheme.space2),
        _DetailRow(label: 'Recovery', value: '${details['recovery_interval_min']} min'),
        if (details['total_duration_min'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Total Time', value: '${details['total_duration_min']} min'),
        ],
        if (details['work_intensity'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Work Intensity', value: details['work_intensity']),
        ],
        if (details['recovery_intensity'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Recovery Intensity', value: details['recovery_intensity']),
        ],
      ],
    );
  }

  Widget _buildBreathingDetails(BuildContext context) {
    final details = widget.exercise.details;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        if (details['pattern'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Pattern', value: details['pattern']),
        ],
        if (details['duration_min'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Duration', value: '${details['duration_min']} min'),
        ],
        if (details['breaths'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Breaths', value: '${details['breaths']}'),
        ],
        if (details['position'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Position', value: details['position']),
        ],
        if (details['breathing'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Breathing', value: details['breathing']),
        ],
        if (details['focus'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Focus', value: details['focus']),
        ],
        if (details['notes'] != null) ...[
          const SizedBox(height: ForestNightTheme.space2),
          _DetailRow(label: 'Notes', value: details['notes']),
        ],
      ],
    );
  }

  Widget _buildGenericDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'ID', value: widget.exercise.id),
        _DetailRow(label: 'Type', value: widget.exercise.moduleType),
      ],
    );
  }

  String _buildRepsText(Map<String, dynamic> exercise) {
    if (exercise['reps_per_side'] != null) {
      return '${exercise['reps_per_side']} reps per side';
    } else if (exercise['reps_forward'] != null && exercise['reps_backward'] != null) {
      return '${exercise['reps_forward']} forward, ${exercise['reps_backward']} backward';
    } else if (exercise['reps'] != null) {
      return '${exercise['reps']} reps';
    } else {
      return 'See details';
    }
  }

  String _buildDurationText(Map<String, dynamic> exercise) {
    if (exercise['duration_sec_per_side'] != null) {
      return '${exercise['duration_sec_per_side']}s per side';
    } else if (exercise['duration_sec_total'] != null) {
      return '${exercise['duration_sec_total']}s total';
    } else {
      return 'See details';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ForestNightTheme.tertiaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ForestNightTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}

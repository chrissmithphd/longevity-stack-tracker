import 'package:flutter/material.dart';
import '../models/daily_task_instance.dart';
import '../models/schedule/schedule_models.dart';
import '../services/task_service.dart';
import '../services/database_service.dart';
import '../theme/forest_night_theme.dart';
import '../utils/category_icons.dart';
import '../utils/time_calculator.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final TaskService _taskService = TaskService();
  List<DailyTaskInstance> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _taskService.getTodaysTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _handleDone(DailyTaskInstance task) async {
    await _taskService.markTaskDone(task);
    await _loadTasks();
  }

  Future<void> _handleSkip(DailyTaskInstance task) async {
    await _taskService.markTaskSkipped(task);
    await _loadTasks();
  }

  Future<void> _handleReset(DailyTaskInstance task) async {
    await _taskService.resetTask(task);
    await _loadTasks();
  }

  int get _completedCount => _tasks
      .where((t) => t.status == 'done' && (t.metadata?['is_active'] ?? true))
      .length;
  int get _totalCount => _tasks
      .where((t) => t.metadata?['is_active'] ?? true)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        elevation: 0,
        actions: [
          if (!_isLoading && _tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ForestNightTheme.completed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ForestNightTheme.radiusFull),
                    border: Border.all(
                      color: ForestNightTheme.completed.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$_completedCount / $_totalCount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ForestNightTheme.completed,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: ForestNightTheme.secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks for today',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ForestNightTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(ForestNightTheme.space4),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: ForestNightTheme.space3),
                        child: _TaskCard(
                          task: _tasks[index],
                          onDone: _handleDone,
                          onSkip: _handleSkip,
                          onReset: _handleReset,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final DailyTaskInstance task;
  final Function(DailyTaskInstance) onDone;
  final Function(DailyTaskInstance) onSkip;
  final Function(DailyTaskInstance) onReset;

  const _TaskCard({
    required this.task,
    required this.onDone,
    required this.onSkip,
    required this.onReset,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _isExpanded = false;
  Map<String, dynamic>? _details;
  bool _isLoadingDetails = false;
  String? _displayTime;

  @override
  void initState() {
    super.initState();
    _calculateDisplayTime();
  }

  Future<void> _calculateDisplayTime() async {
    final timeCalc = await TimeCalculator.getDisplayTime(
      widget.task.plannedTime,
      widget.task.taskDate,
    );
    if (mounted) {
      setState(() => _displayTime = timeCalc);
    }
  }

  Future<void> _toggleExpansion() async {
    if (!_isExpanded && _details == null) {
      // Load details first time
      setState(() => _isLoadingDetails = true);
      final taskService = TaskService();
      final details = await taskService.getTaskDetails(widget.task);
      setState(() {
        _details = details;
        _isLoadingDetails = false;
        _isExpanded = true;
      });
    } else {
      setState(() => _isExpanded = !_isExpanded);
    }
  }

  Color _getStatusColor() {
    switch (widget.task.status) {
      case 'done':
        return ForestNightTheme.completed;
      case 'skipped':
        return ForestNightTheme.skipped;
      default:
        return ForestNightTheme.pending;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.task.status) {
      case 'done':
        return Icons.check_circle_outline;
      case 'skipped':
        return Icons.remove_circle_outline;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  bool _isTaskActive() {
    return widget.task.metadata?['is_active'] ?? true;
  }

  BoxDecoration _getCardDecoration() {
    final isActive = _isTaskActive();

    // Inactive tasks get special styling
    if (!isActive) {
      return BoxDecoration(
        color: ForestNightTheme.secondaryBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
        border: Border.all(
          color: ForestNightTheme.tertiaryText.withOpacity(0.2),
          width: 1,
        ),
      );
    }

    switch (widget.task.status) {
      case 'done':
        return BoxDecoration(
          color: ForestNightTheme.successBackground,
          borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
          border: Border.all(
            color: ForestNightTheme.completed.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            ForestNightTheme.completedGlow,
          ],
        );
      case 'skipped':
        return BoxDecoration(
          color: ForestNightTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
          border: Border.all(
            color: ForestNightTheme.skipped.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        );
      default:
        return BoxDecoration(
          color: ForestNightTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
          border: Border.all(
            color: ForestNightTheme.tertiaryBackground,
            width: 1,
          ),
          boxShadow: ForestNightTheme.cardShadow,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isActive = _isTaskActive();

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        decoration: _getCardDecoration(),
        child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(ForestNightTheme.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_getStatusIcon(), color: statusColor, size: 20),
                      const SizedBox(width: ForestNightTheme.space2),
                      CategoryIcons.getIcon(
                        widget.task.category,
                        size: 20,
                        color: ForestNightTheme.secondaryText,
                      ),
                      const SizedBox(width: ForestNightTheme.space2),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: ForestNightTheme.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
                          border: Border.all(
                            color: statusColor.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.task.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: ForestNightTheme.space2),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: ForestNightTheme.tertiaryText,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: ForestNightTheme.space2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: ForestNightTheme.tertiaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _displayTime ?? widget.task.plannedTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ForestNightTheme.tertiaryText,
                        ),
                      ),
                      if (widget.task.metadata?['is_outdoor'] == true) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '🌅',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_isExpanded) ...[
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
              child: _isLoadingDetails
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _buildDetailsSection(),
            ),
          ] else ...[
            // Action buttons when collapsed (or inactive badge)
            Padding(
              padding: const EdgeInsets.only(
                left: ForestNightTheme.space4,
                right: ForestNightTheme.space4,
                bottom: ForestNightTheme.space3,
              ),
              child: isActive
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.task.status != 'pending')
                          TextButton.icon(
                            onPressed: () => widget.onReset(widget.task),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reset'),
                            style: TextButton.styleFrom(
                              foregroundColor: ForestNightTheme.secondaryText,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        if (widget.task.status != 'pending')
                          const SizedBox(width: ForestNightTheme.space2),
                        if (widget.task.status != 'done')
                          TextButton.icon(
                            onPressed: () => widget.onDone(widget.task),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Done'),
                            style: TextButton.styleFrom(
                              foregroundColor: ForestNightTheme.completed,
                              backgroundColor: ForestNightTheme.completed.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        if (widget.task.status != 'done')
                          const SizedBox(width: ForestNightTheme.space2),
                        if (widget.task.status != 'skipped')
                          TextButton.icon(
                            onPressed: () => widget.onSkip(widget.task),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Skip'),
                            style: TextButton.styleFrom(
                              foregroundColor: ForestNightTheme.skipped,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ForestNightTheme.tertiaryText.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.toggle_off,
                                size: 16,
                                color: ForestNightTheme.tertiaryText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Disabled in settings',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ForestNightTheme.tertiaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    if (_details == null) {
      return const Text('No details available');
    }

    // Check event type
    final eventType = widget.task.eventType;

    if (eventType == 'supplements' && _details!['supplements'] != null) {
      return _buildSupplementDetails(_details!['supplements'] as List<Supplement>);
    } else if (eventType == 'exercise' && _details!['exercise_module'] != null) {
      return _buildExerciseDetails(_details!['exercise_module'] as ExerciseModule);
    } else {
      return Text(
        'Details for ${widget.task.category}',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
  }

  Widget _buildSupplementDetails(List<Supplement> supplements) {
    final activeCount = supplements.where((s) => s.active).length;
    final totalCount = supplements.length;

    // Sort by: active first, then importance (high to low), then name
    // Importance scores determined by longevity research (see TODO_PHASE2.md)
    final sortedSupplements = supplements.toList()
      ..sort((a, b) {
        // Active supplements first
        if (a.active != b.active) return a.active ? -1 : 1;
        // Then by importance (higher = more important, so reverse)
        if (a.importance != b.importance) return b.importance.compareTo(a.importance);
        // Finally alphabetically
        return a.name.compareTo(b.name);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supplements (${activeCount}${activeCount != totalCount ? " of $totalCount" : ""})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: ForestNightTheme.primaryText,
          ),
        ),
        const SizedBox(height: ForestNightTheme.space2),

        // All supplements in one list
        ...sortedSupplements.map((supp) => Opacity(
          opacity: supp.active ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.only(bottom: ForestNightTheme.space2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  supp.active ? Icons.circle : Icons.circle_outlined,
                  size: 6,
                  color: supp.active ? ForestNightTheme.secondaryText : ForestNightTheme.tertiaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supp.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        supp.dose,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: supp.active ? ForestNightTheme.active : ForestNightTheme.tertiaryText,
                        ),
                      ),
                      if (supp.foodRequired && supp.active)
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 12,
                              color: ForestNightTheme.pending,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Take with food',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: ForestNightTheme.pending,
                              ),
                            ),
                          ],
                        ),
                      if (supp.notes.isNotEmpty && supp.active)
                        Text(
                          supp.notes,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: ForestNightTheme.space2),
        // Action buttons in expanded view
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.task.status != 'pending')
              TextButton.icon(
                onPressed: () => widget.onReset(widget.task),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: ForestNightTheme.secondaryText,
                ),
              ),
            if (widget.task.status != 'done')
              TextButton.icon(
                onPressed: () => widget.onDone(widget.task),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Done'),
                style: TextButton.styleFrom(
                  foregroundColor: ForestNightTheme.completed,
                  backgroundColor: ForestNightTheme.completed.withOpacity(0.1),
                ),
              ),
            if (widget.task.status != 'skipped')
              TextButton.icon(
                onPressed: () => widget.onSkip(widget.task),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Skip'),
                style: TextButton.styleFrom(
                  foregroundColor: ForestNightTheme.skipped,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseDetails(ExerciseModule module) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          module.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: ForestNightTheme.primaryText,
          ),
        ),
        const SizedBox(height: ForestNightTheme.space1),
        Text(
          module.getSummary(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ForestNightTheme.secondaryText,
          ),
        ),
        const SizedBox(height: ForestNightTheme.space2),
        _buildExerciseModuleContent(module),
        const SizedBox(height: ForestNightTheme.space2),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.task.status != 'pending')
              TextButton.icon(
                onPressed: () => widget.onReset(widget.task),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: ForestNightTheme.secondaryText,
                ),
              ),
            if (widget.task.status != 'done')
              TextButton.icon(
                onPressed: () => widget.onDone(widget.task),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Done'),
                style: TextButton.styleFrom(
                  foregroundColor: ForestNightTheme.completed,
                  backgroundColor: ForestNightTheme.completed.withOpacity(0.1),
                ),
              ),
            if (widget.task.status != 'skipped')
              TextButton.icon(
                onPressed: () => widget.onSkip(widget.task),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Skip'),
                style: TextButton.styleFrom(
                  foregroundColor: ForestNightTheme.skipped,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseModuleContent(ExerciseModule module) {
    final details = module.details;

    switch (module.moduleType) {
      case 'strength':
      case 'joint_sequence':
      case 'stretch':
        final exercises = details['exercises'] as List? ?? [];
        return Column(
          children: exercises.map((ex) {
            final exercise = ex as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: ForestNightTheme.space2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: ForestNightTheme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['name'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (exercise['sets'] != null)
                          Text(
                            '${exercise['sets']} sets × ${exercise['reps']} reps • Rest: ${exercise['rest_sec']}s',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (exercise['reps'] != null && exercise['sets'] == null)
                          Text(
                            '${exercise['reps']} reps',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (exercise['duration_sec_per_side'] != null)
                          Text(
                            '${exercise['duration_sec_per_side']}s per side',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (exercise['duration_sec_total'] != null)
                          Text(
                            '${exercise['duration_sec_total']}s total',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (exercise['details'] != null)
                          Text(
                            exercise['details'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'zone2':
      case 'vo2max':
      case 'walk':
      case 'breathing':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: details.entries.map((e) {
            if (e.key == 'exercises') return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${_formatKey(e.key)}: ${_formatValue(e.value)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }).toList(),
        );

      default:
        return Text(
          'Type: ${module.moduleType}',
          style: Theme.of(context).textTheme.bodySmall,
        );
    }
  }

  String _formatKey(String key) {
    return key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }
}

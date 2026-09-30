import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_task_instance.dart';
import '../services/database_service.dart';
import '../services/task_service.dart';
import '../theme/forest_night_theme.dart';
import '../utils/category_icons.dart';
import '../widgets/calendar_view.dart';
import '../widgets/stats_dashboard.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService.instance;
  final TaskService _taskService = TaskService();

  Map<String, Map<String, int>> _completionStats = {};
  DateTime? _selectedDate;
  List<DailyTaskInstance> _selectedDayTasks = [];
  bool _isLoading = true;
  bool _isLoadingDayTasks = false;

  // Stats for dashboard
  int _currentStreak = 0;
  int _bestStreak = 0;
  double _weekCompletionRate = 0.0;
  int _totalCompleted = 0;
  Set<String> _streakDates = {};

  @override
  void initState() {
    super.initState();
    _loadMonthStats(DateTime.now());
    _loadStats();
  }

  Future<void> _loadStats() async {
    final currentStreak = await _db.getCurrentStreak();
    final bestStreak = await _db.getBestStreak();
    final weekRate = await _db.getWeekCompletionRate();
    final totalCompleted = await _db.getTotalCompletedTasks();

    setState(() {
      _currentStreak = currentStreak;
      _bestStreak = bestStreak;
      _weekCompletionRate = weekRate;
      _totalCompleted = totalCompleted;
    });

    await _calculateStreakDates();
  }

  Future<void> _calculateStreakDates() async {
    final streakDates = <String>{};

    if (_currentStreak == 0) {
      setState(() {
        _streakDates = streakDates;
      });
      return;
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Add all dates in the current streak
    for (int i = 0; i < _currentStreak; i++) {
      final date = todayDate.subtract(Duration(days: i));
      streakDates.add(date.toIso8601String().split('T')[0]);
    }

    setState(() {
      _streakDates = streakDates;
    });
  }

  Future<void> _loadMonthStats(DateTime month) async {
    setState(() => _isLoading = true);

    // Get first and last day of the month
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Load completion stats for the entire month
    final stats = await _db.getCompletionStatsByDateRange(firstDay, lastDay);

    setState(() {
      _completionStats = stats;
      _isLoading = false;
    });
  }

  Future<void> _loadDayTasks(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _isLoadingDayTasks = true;
    });

    // Check if tasks exist for this date
    var tasks = await _db.getDailyTasks(date);

    // If no tasks exist, generate them retroactively
    if (tasks.isEmpty) {
      await _taskService.generateDailyTasks(date);
      tasks = await _db.getDailyTasks(date);
    }

    setState(() {
      _selectedDayTasks = tasks;
      _isLoadingDayTasks = false;
    });
  }

  void _backToCalendar() {
    setState(() {
      _selectedDate = null;
      _selectedDayTasks = [];
    });
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today • ${DateFormat('EEEE, MMM d').format(date)}';
    } else if (taskDate == yesterday) {
      return 'Yesterday • ${DateFormat('EEEE, MMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If a date is selected, show day detail view
    if (_selectedDate != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_formatDateHeader(_selectedDate!)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _backToCalendar,
          ),
          elevation: 0,
        ),
        body: _isLoadingDayTasks
            ? const Center(child: CircularProgressIndicator())
            : _selectedDayTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: ForestNightTheme.secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for this day',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ForestNightTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(ForestNightTheme.space4),
                    itemCount: _selectedDayTasks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: ForestNightTheme.space2,
                        ),
                        child: _HistoryTaskCard(task: _selectedDayTasks[index]),
                      );
                    },
                  ),
      );
    }

    // Otherwise show calendar view
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Dashboard
                StatsDashboard(
                  currentStreak: _currentStreak,
                  bestStreak: _bestStreak,
                  weekCompletionRate: _weekCompletionRate,
                  totalCompleted: _totalCompleted,
                ),

                // Calendar
                Expanded(
                  child: CalendarView(
                    completionStats: _completionStats,
                    onDayTapped: _loadDayTasks,
                    onMonthChanged: _loadMonthStats,
                    selectedDate: _selectedDate,
                    streakDates: _streakDates,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final List<DailyTaskInstance> tasks;
  final String dateText;

  const _DateHeader({
    required this.date,
    required this.tasks,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.status == 'done').length;
    final totalCount = tasks.length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ForestNightTheme.space3,
        vertical: ForestNightTheme.space2,
      ),
      decoration: BoxDecoration(
        color: ForestNightTheme.tertiaryBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: ForestNightTheme.primaryText,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
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
              '$completedCount / $totalCount',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ForestNightTheme.completed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTaskCard extends StatelessWidget {
  final DailyTaskInstance task;

  const _HistoryTaskCard({required this.task});

  Color _getStatusColor() {
    switch (task.status) {
      case 'done':
        return ForestNightTheme.completed;
      case 'skipped':
        return ForestNightTheme.skipped;
      default:
        return ForestNightTheme.pending;
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case 'done':
        return Icons.check_circle_outline;
      case 'skipped':
        return Icons.remove_circle_outline;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case 'done':
        return 'Completed';
      case 'skipped':
        return 'Skipped';
      default:
        return 'Pending';
    }
  }

  String? _getTimestamp() {
    if (task.completedAt != null) {
      return DateFormat('h:mm a').format(task.completedAt!);
    } else if (task.skippedAt != null) {
      return DateFormat('h:mm a').format(task.skippedAt!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final timestamp = _getTimestamp();

    return Container(
      decoration: BoxDecoration(
        color: ForestNightTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
        border: Border.all(
          color: task.status == 'done'
              ? ForestNightTheme.completed.withOpacity(0.2)
              : ForestNightTheme.tertiaryBackground,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ForestNightTheme.space3),
        child: Row(
          children: [
            // Status icon
            Icon(
              _getStatusIcon(),
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: ForestNightTheme.space2),

            // Category icon
            CategoryIcons.getIcon(
              task.category,
              size: 18,
              color: ForestNightTheme.tertiaryText,
            ),
            const SizedBox(width: ForestNightTheme.space2),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        task.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Planned: ${task.plannedTime}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge and timestamp
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
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
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: ForestNightTheme.tertiaryText,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

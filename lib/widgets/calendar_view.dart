import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/forest_night_theme.dart';

class CalendarView extends StatefulWidget {
  final Map<String, Map<String, int>> completionStats;
  final Function(DateTime) onDayTapped;
  final Function(DateTime)? onMonthChanged;
  final DateTime? selectedDate;
  final Set<String> streakDates;

  const CalendarView({
    super.key,
    required this.completionStats,
    required this.onDayTapped,
    this.onMonthChanged,
    this.selectedDate,
    this.streakDates = const {},
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
  }

  void _previousMonth() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    setState(() {
      _currentMonth = newMonth;
    });
    widget.onMonthChanged?.call(newMonth);
  }

  void _nextMonth() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    setState(() {
      _currentMonth = newMonth;
    });
    widget.onMonthChanged?.call(newMonth);
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 1.0) {
      return ForestNightTheme.completed; // 100% - green
    } else if (percentage >= 0.75) {
      return ForestNightTheme.active; // 75-99% - light green
    } else if (percentage >= 0.50) {
      return const Color(0xFFB8860B); // 50-74% - yellow/gold
    } else if (percentage >= 0.25) {
      return const Color(0xFFCD853F); // 25-49% - orange
    } else {
      return ForestNightTheme.tertiaryText; // 0-24% - grey/red
    }
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    // Get the first day of the calendar grid (might be from previous month)
    final startDay = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    // Get the last day of the calendar grid (might be from next month)
    final endDay = lastDay.add(Duration(days: 6 - (lastDay.weekday % 7)));

    final days = <DateTime>[];
    for (var day = startDay; day.isBefore(endDay.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      days.add(day);
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];

    return Column(
      children: [
        // Month navigation header
        Container(
          padding: const EdgeInsets.all(ForestNightTheme.space3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                color: ForestNightTheme.primaryText,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ForestNightTheme.primaryText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                color: ForestNightTheme.primaryText,
              ),
            ],
          ),
        ),

        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ForestNightTheme.space3),
          child: Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ForestNightTheme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: ForestNightTheme.space2),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(ForestNightTheme.space3),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final dateStr = day.toIso8601String().split('T')[0];
              final stats = widget.completionStats[dateStr];
              final isCurrentMonth = day.month == _currentMonth.month;
              final isToday = dateStr == todayStr;
              final isSelected = widget.selectedDate != null &&
                  dateStr == widget.selectedDate!.toIso8601String().split('T')[0];

              final totalActive = stats?['totalActive'] ?? 0;
              final completed = stats?['completed'] ?? 0;
              final percentage = totalActive > 0 ? completed / totalActive : 0.0;
              final isInStreak = widget.streakDates.contains(dateStr);

              Color bgColor = ForestNightTheme.secondaryBackground;
              if (stats != null && totalActive > 0) {
                bgColor = _getCompletionColor(percentage).withOpacity(0.15);
              }

              return GestureDetector(
                onTap: isCurrentMonth ? () => widget.onDayTapped(day) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ForestNightTheme.active.withOpacity(0.3)
                        : bgColor,
                    borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
                    border: isToday
                        ? Border.all(
                            color: ForestNightTheme.primaryText,
                            width: 2,
                          )
                        : stats != null && totalActive > 0
                            ? Border.all(
                                color: _getCompletionColor(percentage),
                                width: 1.5,
                              )
                            : null,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isCurrentMonth
                                  ? (isToday ? ForestNightTheme.primaryText : ForestNightTheme.secondaryText)
                                  : ForestNightTheme.tertiaryText.withOpacity(0.4),
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (stats != null && totalActive > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '$completed/$totalActive',
                              style: TextStyle(
                                fontSize: 9,
                                color: _getCompletionColor(percentage),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isInStreak)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Text(
                            '🔥',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

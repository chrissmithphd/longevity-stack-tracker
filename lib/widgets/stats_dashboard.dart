import 'package:flutter/material.dart';
import '../theme/forest_night_theme.dart';

class StatsDashboard extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final double weekCompletionRate;
  final int totalCompleted;

  const StatsDashboard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.weekCompletionRate,
    required this.totalCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(ForestNightTheme.space3),
      padding: const EdgeInsets.all(ForestNightTheme.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ForestNightTheme.completed.withOpacity(0.1),
            ForestNightTheme.active.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
        border: Border.all(
          color: ForestNightTheme.completed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ForestNightTheme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ForestNightTheme.space3),

          // Stats grid
          Row(
            children: [
              // Current Streak
              Expanded(
                child: _StatCard(
                  icon: '🔥',
                  label: 'Current Streak',
                  value: '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
                  color: currentStreak > 0 ? ForestNightTheme.completed : ForestNightTheme.tertiaryText,
                ),
              ),
              const SizedBox(width: ForestNightTheme.space2),

              // Best Streak
              Expanded(
                child: _StatCard(
                  icon: '⭐',
                  label: 'Best Streak',
                  value: '$bestStreak ${bestStreak == 1 ? 'day' : 'days'}',
                  color: ForestNightTheme.active,
                ),
              ),
            ],
          ),
          const SizedBox(height: ForestNightTheme.space2),

          Row(
            children: [
              // This Week
              Expanded(
                child: _StatCard(
                  icon: '📊',
                  label: 'This Week',
                  value: '${(weekCompletionRate * 100).toInt()}%',
                  color: weekCompletionRate >= 0.8
                      ? ForestNightTheme.completed
                      : weekCompletionRate >= 0.5
                          ? ForestNightTheme.pending
                          : ForestNightTheme.skipped,
                ),
              ),
              const SizedBox(width: ForestNightTheme.space2),

              // Total Completed
              Expanded(
                child: _StatCard(
                  icon: '🎯',
                  label: 'Total Done',
                  value: '$totalCompleted',
                  color: ForestNightTheme.active,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ForestNightTheme.space3),
      decoration: BoxDecoration(
        color: ForestNightTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(ForestNightTheme.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ForestNightTheme.tertiaryText,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

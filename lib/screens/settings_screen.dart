import 'package:flutter/material.dart';
import '../theme/forest_night_theme.dart';
import 'supplements_screen.dart';
import 'exercises_screen.dart';
import 'location_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(ForestNightTheme.space4),
        children: [
          _SectionHeader(title: 'General'),
          const SizedBox(height: ForestNightTheme.space2),

          _SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'Set location for sunrise/sunset timing',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: ForestNightTheme.space6),
          _SectionHeader(title: 'Configuration'),
          const SizedBox(height: ForestNightTheme.space2),

          _SettingsTile(
            icon: Icons.medical_services_outlined,
            title: 'Supplements',
            subtitle: 'Manage your supplement list',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupplementsScreen(),
                ),
              );
            },
          ),

          _SettingsTile(
            icon: Icons.fitness_center_outlined,
            title: 'Exercises',
            subtitle: 'Manage exercise modules',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExercisesScreen(),
                ),
              );
            },
          ),

          _SettingsTile(
            icon: Icons.calendar_today_outlined,
            title: 'Schedule',
            subtitle: 'View and edit weekly schedule',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule editor coming soon'),
                ),
              );
            },
            trailing: const Chip(
              label: Text('Coming Soon', style: TextStyle(fontSize: 10)),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            ),
          ),

          const SizedBox(height: ForestNightTheme.space6),
          _SectionHeader(title: 'Data'),
          const SizedBox(height: ForestNightTheme.space2),

          _SettingsTile(
            icon: Icons.file_download_outlined,
            title: 'Export Data',
            subtitle: 'Export to JSON files',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export functionality coming soon'),
                ),
              );
            },
            trailing: const Chip(
              label: Text('Coming Soon', style: TextStyle(fontSize: 10)),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            ),
          ),

          const SizedBox(height: ForestNightTheme.space6),
          _SectionHeader(title: 'About'),
          const SizedBox(height: ForestNightTheme.space2),

          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: ForestNightTheme.space2,
        top: ForestNightTheme.space2,
        bottom: ForestNightTheme.space1,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: ForestNightTheme.tertiaryText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ForestNightTheme.space2),
      decoration: BoxDecoration(
        color: ForestNightTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(ForestNightTheme.radiusMedium),
        border: Border.all(
          color: ForestNightTheme.tertiaryBackground,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: ForestNightTheme.active,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: trailing ?? (onTap != null
            ? const Icon(
                Icons.chevron_right,
                color: ForestNightTheme.tertiaryText,
              )
            : null),
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }
}

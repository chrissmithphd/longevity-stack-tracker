import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Helper class for category-specific icons
class CategoryIcons {
  static const String _basePath = 'assets/icons/';

  /// Get icon widget for a given category
  static Widget getIcon(
    String category, {
    double size = 24,
    Color? color,
  }) {
    final iconPath = _getCategoryIconPath(category);

    if (iconPath != null) {
      return SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );
    }

    // Fallback to material icon if no custom icon found
    return Icon(
      _getCategoryFallbackIcon(category),
      size: size,
      color: color,
    );
  }

  /// Map category names to icon file paths
  static String? _getCategoryIconPath(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('supplement') || categoryLower.contains('vitamin')) {
      return '${_basePath}supplements.svg';
    } else if (categoryLower.contains('exercise') || categoryLower.contains('workout') || categoryLower.contains('training')) {
      return '${_basePath}exercise.svg';
    } else if (categoryLower.contains('recovery') || categoryLower.contains('breath') || categoryLower.contains('meditat')) {
      return '${_basePath}recovery.svg';
    } else if (categoryLower.contains('sleep') || categoryLower.contains('fast') || categoryLower.contains('rest')) {
      return '${_basePath}sleep.svg';
    } else if (categoryLower.contains('hydrat') || categoryLower.contains('water') || categoryLower.contains('drink')) {
      return '${_basePath}hydration.svg';
    }

    return null;
  }

  /// Fallback material icons if custom icons aren't found
  static IconData _getCategoryFallbackIcon(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('supplement') || categoryLower.contains('vitamin')) {
      return Icons.medical_services_outlined;
    } else if (categoryLower.contains('exercise') || categoryLower.contains('workout')) {
      return Icons.fitness_center_outlined;
    } else if (categoryLower.contains('recovery') || categoryLower.contains('breath')) {
      return Icons.spa_outlined;
    } else if (categoryLower.contains('sleep') || categoryLower.contains('fast')) {
      return Icons.bedtime_outlined;
    } else if (categoryLower.contains('hydrat') || categoryLower.contains('water')) {
      return Icons.water_drop_outlined;
    }

    return Icons.circle_outlined;
  }

  /// Get colored icon for category (with appropriate accent color)
  static Widget getCategoryIconColored(
    String category,
    BuildContext context, {
    double size = 24,
  }) {
    return getIcon(
      category,
      size: size,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
  }
}

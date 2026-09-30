import '../services/sun_timing_service.dart';

/// Utility class for calculating dynamic times based on sunrise/sunset
class TimeCalculator {
  static final SunTimingService _sunTiming = SunTimingService();

  /// Calculate actual time from a time string that may include sunrise/sunset references
  /// Examples: "07:00 AM" -> returns as-is, "sunrise+10min" -> calculates based on today's sunrise
  static Future<String> getDisplayTime(String plannedTime, DateTime date) async {
    // If it's a regular time format, return as-is
    if (!plannedTime.contains('sunrise') && !plannedTime.contains('sunset')) {
      return plannedTime;
    }

    // Calculate sunrise/sunset times for this date
    final sunTimes = await _sunTiming.getSunTimes(date);

    // Parse and calculate based on format
    if (plannedTime.startsWith('sunrise')) {
      // Format: "sunrise+10min" or "sunrise+10"
      final offset = _parseOffset(plannedTime);
      final actualTime = sunTimes.sunrise.add(Duration(minutes: offset));
      return _formatTime(actualTime);
    } else if (plannedTime.startsWith('sunset')) {
      // Format: "sunset-30min" or "sunset-30"
      final offset = _parseOffset(plannedTime);
      final actualTime = sunTimes.sunset.subtract(Duration(minutes: offset.abs()));
      return _formatTime(actualTime);
    }

    // Fallback to original time if parsing fails
    return plannedTime;
  }

  /// Parse the offset minutes from a time string like "sunrise+10min" or "sunset-30"
  static int _parseOffset(String timeStr) {
    final match = RegExp(r'[+-](\d+)').firstMatch(timeStr);
    if (match != null) {
      final value = int.parse(match.group(1)!);
      return timeStr.contains('-') ? -value : value;
    }
    return 0;
  }

  /// Format DateTime to time string (e.g., "8:00 AM")
  static String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Check if a time string is dynamic (contains sunrise/sunset)
  static bool isDynamicTime(String timeStr) {
    return timeStr.contains('sunrise') || timeStr.contains('sunset');
  }
}

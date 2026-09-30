import 'package:nrel_spa/nrel_spa.dart';
import 'database_service.dart';

/// Service for calculating sunrise/sunset times and adjusting outdoor activity timing
class SunTimingService {
  final DatabaseService _db = DatabaseService.instance;

  /// Get sunrise and sunset times for a given date and location
  Future<SunTimes> getSunTimes(DateTime date) async {
    // Get user location from settings
    final location = await _getUserLocation();

    if (location == null) {
      // Return default times if no location set (8 AM sunrise, 6 PM sunset)
      return SunTimes(
        sunrise: DateTime(date.year, date.month, date.day, 8, 0),
        sunset: DateTime(date.year, date.month, date.day, 18, 0),
        hasLocation: false,
      );
    }

    // Calculate sunrise/sunset using NREL SPA algorithm
    final utcDate = DateTime.utc(date.year, date.month, date.day, 12, 0, 0);

    final result = getSpa(
      utcDate,
      location.latitude,
      location.longitude,
      location.timezoneOffset,
    );

    // Convert fractional hours to DateTime
    // result.sunrise and result.sunset are in fractional hours (e.g., 6.5 = 6:30 AM UTC)
    final sunrise = _fractionalHoursToDateTime(date, result.sunrise!, location.timezoneOffset);
    final sunset = _fractionalHoursToDateTime(date, result.sunset!, location.timezoneOffset);

    return SunTimes(
      sunrise: sunrise,
      sunset: sunset,
      hasLocation: true,
    );
  }

  /// Calculate appropriate start time for a morning outdoor activity
  /// Returns sunrise + 10 minutes
  Future<DateTime?> getMorningOutdoorTime(DateTime date) async {
    final sunTimes = await getSunTimes(date);
    if (!sunTimes.hasLocation) {
      return null; // No location set, can't calculate
    }
    return sunTimes.sunrise.add(const Duration(minutes: 10));
  }

  /// Calculate latest start time for an evening outdoor activity
  /// Returns sunset - activity duration
  Future<DateTime?> getEveningOutdoorTime(
    DateTime date,
    Duration activityDuration,
  ) async {
    final sunTimes = await getSunTimes(date);
    if (!sunTimes.hasLocation) {
      return null; // No location set, can't calculate
    }
    return sunTimes.sunset.subtract(activityDuration);
  }

  /// Check if a given time is suitable for outdoor activity
  /// (after sunrise + 10min, before sunset)
  Future<bool> isTimeGoodForOutdoor(DateTime dateTime) async {
    final sunTimes = await getSunTimes(dateTime);
    if (!sunTimes.hasLocation) {
      return true; // Can't verify, assume okay
    }

    final morningCutoff = sunTimes.sunrise.add(const Duration(minutes: 10));
    return dateTime.isAfter(morningCutoff) && dateTime.isBefore(sunTimes.sunset);
  }

  /// Get user location from database settings
  Future<UserLocation?> _getUserLocation() async {
    final settings = await _db.getAppSettings();

    final lat = settings['latitude'] as double?;
    final lon = settings['longitude'] as double?;
    final tzOffset = settings['timezone_offset'] as double?;

    if (lat == null || lon == null || tzOffset == null) {
      return null;
    }

    return UserLocation(
      latitude: lat,
      longitude: lon,
      timezoneOffset: tzOffset,
    );
  }

  /// Convert fractional hours (from NREL SPA) to local DateTime
  DateTime _fractionalHoursToDateTime(DateTime localDate, double fractionalHours, double tzOffset) {
    // fractionalHours is already in LOCAL time (getSpa applies tzOffset internally)
    // Just convert to hours and minutes
    final hours = fractionalHours.floor();
    final minutes = ((fractionalHours - hours) * 60).round();

    return DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
      hours,
      minutes,
    );
  }
}

/// Sunrise and sunset times for a given date
class SunTimes {
  final DateTime sunrise;
  final DateTime sunset;
  final bool hasLocation; // False if using default times

  SunTimes({
    required this.sunrise,
    required this.sunset,
    required this.hasLocation,
  });

  @override
  String toString() {
    return 'Sunrise: ${_formatTime(sunrise)}, Sunset: ${_formatTime(sunset)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

/// User location for sunrise/sunset calculations
class UserLocation {
  final double latitude;
  final double longitude;
  final double timezoneOffset; // Hours from UTC (e.g., -5.0 for EST)

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.timezoneOffset,
  });
}

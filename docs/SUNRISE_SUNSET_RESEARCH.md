# Sunrise/Sunset Calculation Packages - Research Report

**Research Date:** April 1, 2026
**Dart SDK Version:** ^3.11.4 (from pubspec.yaml)

## Executive Summary

After researching available Flutter/Dart packages for calculating sunrise and sunset times, I recommend **nrel_spa** as the primary choice, with **daylight** as a solid alternative depending on your specific needs.

## Top Candidates Comparison

| Package | Version | Stars | Accuracy | Dependencies | Last Updated | Algorithm |
|---------|---------|-------|----------|--------------|--------------|-----------|
| **nrel_spa** | 1.0.0 | 0 | ±0.0003° | Zero | 4 days ago | NREL SPA (Reda & Andreas 2004) |
| **daylight** | 3.1.0 | 66 | Standard | 1 (equatable) | 2 months ago | Classic Sunrise/Sunset |
| **spa** | 1.3.0 | 12 | ±0.0003° | 2 (meta, tuple) | May 2023 | SPA (Reda & Andreas) |
| **solar_calculator** | 1.0.3 | N/A | ~1 min | Zero | Apr 2022 | Jean Meeus equations |
| **sunrise_sunset_calc** | 3.0.0 | N/A | Standard | 2 (async, vector_math) | 3 years ago | Port of sunrisesunset lib |

---

## Recommended Package: nrel_spa

### Why nrel_spa?

1. **Most Recent Updates** - Published 4 days ago (March 28, 2026), actively maintained
2. **Highest Accuracy** - ±0.0003 degrees precision (scientifically validated NREL algorithm)
3. **Zero Dependencies** - Pure Dart implementation, no external dependencies
4. **Official Algorithm** - Based on NREL/TP-560-34302 research paper by Reda & Andreas (2004)
5. **Comprehensive** - Calculates sunrise, sunset, solar noon, zenith, azimuth, and custom angles
6. **Cross-Platform** - Works on all platforms (Android, iOS, Web, Linux, macOS, Windows)
7. **Verified Publisher** - ariccamarata.com verified publisher

### Installation

Add to `pubspec.yaml`:
```yaml
dependencies:
  nrel_spa: ^1.0.0
```

Then run:
```bash
flutter pub add nrel_spa
```

### Basic Usage Example

```dart
import 'package:nrel_spa/nrel_spa.dart';

void main() {
  // Calculate for a specific location and time
  final result = getSpa(
    DateTime.utc(2026, 4, 1, 12, 0, 0),  // UTC time
    40.7128,    // latitude (New York City)
    -74.0060,   // longitude
    -5.0,       // timezone offset from UTC (EST = -5)
  );

  print('Sunrise: ${result.sunrise}');
  print('Sunset: ${result.sunset}');
  print('Solar Noon: ${result.solarNoon}');
  print('Zenith: ${result.zenith}°');
  print('Azimuth: ${result.azimuth}°');
}
```

### Advanced Usage - Custom Zenith Angles

```dart
import 'package:nrel_spa/nrel_spa.dart';

// Calculate civil twilight times (6° below horizon)
final civilTwilight = getSpa(
  DateTime.now(),
  latitude,
  longitude,
  timezoneOffset,
  zenith: 96.0,  // 90° + 6° for civil twilight
);

// Calculate nautical twilight (12° below horizon)
final nauticalTwilight = getSpa(
  DateTime.now(),
  latitude,
  longitude,
  timezoneOffset,
  zenith: 102.0,  // 90° + 12°
);

// Calculate astronomical twilight (18° below horizon)
final astronomicalTwilight = getSpa(
  DateTime.now(),
  latitude,
  longitude,
  timezoneOffset,
  zenith: 108.0,  // 90° + 18°
);
```

### Working with User Location

```dart
import 'package:nrel_spa/nrel_spa.dart';

class SunTimingService {
  /// Calculate sunrise/sunset for given location and date
  Map<String, DateTime> calculateSunTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required double timezoneOffset,
  }) {
    final result = getSpa(
      date,
      latitude,
      longitude,
      timezoneOffset,
    );

    return {
      'sunrise': result.sunrise,
      'sunset': result.sunset,
      'solarNoon': result.solarNoon,
    };
  }

  /// Check if current time is during daylight hours
  bool isDaytime({
    required double latitude,
    required double longitude,
    DateTime? dateTime,
  }) {
    final now = dateTime ?? DateTime.now();
    final offset = now.timeZoneOffset.inHours.toDouble();

    final result = getSpa(now, latitude, longitude, offset);

    return now.isAfter(result.sunrise) && now.isBefore(result.sunset);
  }

  /// Get hours of daylight for a given date
  Duration getDaylightDuration({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final offset = date.timeZoneOffset.inHours.toDouble();
    final result = getSpa(date, latitude, longitude, offset);

    return result.sunset.difference(result.sunrise);
  }
}
```

### Repository & License
- **GitHub:** https://github.com/acamarata/nrel-spa-dart
- **License:** MIT
- **Publisher:** ariccamarata.com (verified)

---

## Alternative: daylight

If you prefer a more established package with a larger user base, **daylight** is an excellent alternative.

### Why daylight?

1. **Most Popular** - 47 likes, 4.66k downloads, 66 GitHub stars
2. **Proven Track Record** - Published 23 months ago, well-tested in production
3. **Simple API** - Clean, intuitive interface
4. **Minimal Dependencies** - Only depends on equatable
5. **Verified Publisher** - blue-fire.xyz
6. **Multiple Zenith Types** - Built-in support for different twilight calculations

### Installation

```yaml
dependencies:
  daylight: ^3.1.0
```

### Basic Usage

```dart
import 'package:daylight/daylight.dart';

void main() {
  // Define location
  final berlin = DaylightLocation(52.518611, 13.408056);

  // Create calculator
  final calculator = DaylightCalculator(berlin);

  // Calculate for today
  final results = calculator.calculateForDay(
    DateTime.now(),
    Zenith.astronomical,  // or Zenith.civil, Zenith.nautical, Zenith.official
  );

  print('Sunrise: ${results.sunrise}');
  print('Sunset: ${results.sunset}');
}
```

### Zenith Types in daylight

```dart
// Official sunrise/sunset (0.833° refraction)
Zenith.official

// Civil twilight (6° below horizon)
Zenith.civil

// Nautical twilight (12° below horizon)
Zenith.nautical

// Astronomical twilight (18° below horizon)
Zenith.astronomical
```

### Complete Example with Location

```dart
import 'package:daylight/daylight.dart';

class SunTimingService {
  final double latitude;
  final double longitude;
  late final DaylightCalculator _calculator;

  SunTimingService({
    required this.latitude,
    required this.longitude,
  }) {
    _calculator = DaylightCalculator(
      DaylightLocation(latitude, longitude),
    );
  }

  DaylightResult getSunTimes(DateTime date, {Zenith? zenith}) {
    return _calculator.calculateForDay(
      date,
      zenith ?? Zenith.official,
    );
  }

  bool isDaytime(DateTime dateTime) {
    final result = getSunTimes(dateTime);
    return dateTime.isAfter(result.sunrise) &&
           dateTime.isBefore(result.sunset);
  }

  Duration getDaylightDuration(DateTime date) {
    final result = getSunTimes(date);
    return result.sunset.difference(result.sunrise);
  }
}
```

### Repository & License
- **GitHub:** https://github.com/renancaraujo/daylight
- **License:** MIT
- **Publisher:** blue-fire.xyz (verified)

---

## Other Notable Packages

### spa (1.3.0)
- **Pros:** Same high accuracy as nrel_spa (±0.0003°), good performance (16,529 calc/sec)
- **Cons:** Last updated May 2023, has 2 dependencies
- **Use Case:** Good choice if you need proven stability over latest updates

### solar_calculator (1.0.3)
- **Pros:** Zero dependencies, based on Jean Meeus equations
- **Cons:** Lower accuracy (~1 minute), last updated April 2022, manual timezone handling
- **Accuracy Range:** Best between ±72° latitude, years 1800-2100
- **Use Case:** Good for general use cases where minute-level accuracy is sufficient

### sunrise_sunset_calc (3.0.0)
- **Pros:** Simple API
- **Cons:** Last updated 3 years ago, has dependencies, less accurate
- **Use Case:** Legacy projects or simple requirements

---

## Algorithm Comparison

### NREL SPA (nrel_spa, spa)
- **Source:** National Renewable Energy Laboratory
- **Paper:** Reda & Andreas (2004) - NREL/TP-560-34302
- **Accuracy:** ±0.0003 degrees
- **Use Case:** Scientific applications, solar energy systems, precise calculations

### Jean Meeus Algorithms (solar_calculator)
- **Source:** "Astronomical Algorithms" book
- **Accuracy:** ~1 minute
- **Use Case:** General astronomical calculations, educational purposes

### Classic Sunrise/Sunset (daylight, sunrise_sunset_calc)
- **Source:** Traditional astronomical formulas
- **Accuracy:** Standard (few minutes)
- **Use Case:** General mobile apps, non-critical applications

---

## Recommendation Summary

### For Your Longevity App:

**Primary Recommendation: nrel_spa**
- Zero dependencies keeps your app lean
- Latest updates show active maintenance
- Scientific accuracy for reliable outdoor activity scheduling
- Simple API that's easy to integrate

**Implementation Path:**
1. Add `nrel_spa: ^1.0.0` to pubspec.yaml
2. Create a `SunTimingService` class (see example above)
3. Use with location service to get user's lat/long
4. Calculate daily sunrise/sunset times for outdoor activities
5. Add sunrise icon indicator to tasks scheduled relative to sun times

### When to Consider Alternatives:

**Choose daylight if:**
- You want a package with proven production usage
- You prefer a larger community and more examples
- You need built-in zenith type constants

**Choose spa if:**
- You need the same accuracy as nrel_spa
- You want more history/stability (published May 2023)
- Performance benchmarking is important

**Choose solar_calculator if:**
- You need calculations for years outside 1800-2100
- Minute-level accuracy is sufficient
- You want twilight period calculations built-in

---

## Integration Notes for Longevity App

Based on task #66 (Create SunTimingService) and related tasks:

1. **Location Service** (Task #64)
   - Use Flutter's `geolocator` package for location
   - Store user location in settings
   - Request permissions appropriately

2. **Sun Timing Service** (Task #66)
   - Use nrel_spa for calculations
   - Cache daily sunrise/sunset times
   - Provide helper methods for outdoor activity scheduling

3. **Task Generation** (Task #67)
   - Identify outdoor activities from schedule
   - Calculate optimal times based on sunrise/sunset
   - Apply offsets (e.g., 30 mins after sunrise for morning walk)

4. **UI Indicators** (Task #68)
   - Add sunrise icon to outdoor activities
   - Show relative times ("30 min after sunrise")
   - Display actual times in task details

---

## References

- NREL SPA: https://github.com/acamarata/nrel-spa-dart
- daylight: https://github.com/renancaraujo/daylight
- spa: https://github.com/PixelToast/dart-spa
- solar_calculator: https://github.com/mikljacq/solar_calculator
- Reda & Andreas (2004): NREL/TP-560-34302

---

**Next Steps:**
1. Add chosen package to pubspec.yaml
2. Implement SunTimingService class
3. Integrate with location service
4. Update task generation logic
5. Add UI indicators for outdoor activities

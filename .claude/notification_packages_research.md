# Flutter Local Notifications - Package Research
**Date:** 2026-04-01
**Project:** Longevity
**Flutter SDK:** 3.11.4

## Executive Summary

After comprehensive research, **flutter_local_notifications** is the recommended package for this project.

### Recommendation: flutter_local_notifications v21.0.0

**Rationale:**
- Flutter Favorite package with proven stability
- Excellent cross-platform support including Linux
- Active maintenance (2.6k stars, frequent updates)
- Superior documentation and community support
- Better reliability for core scheduling features
- More mature codebase with established patterns

---

## Package Comparison

### 1. flutter_local_notifications (RECOMMENDED)

**Package Details:**
- Latest Version: 21.0.0 (published 32 days ago)
- Pub Points: 160/160
- Popularity: 7.28k likes, 1.52M downloads
- Publisher: dexterx.dev (verified)
- License: BSD-3-Clause
- Repository: https://github.com/MaikuB/flutter_local_notifications
- Stars: 2.6k

**Platform Support:**
- Android (min API 24 / Android 7.0)
- iOS (min iOS 13)
- Linux ✓
- macOS (min 10.15)
- Windows ✓

**Key Features:**
✓ Schedule notifications at specific times (zonedSchedule)
✓ Daily recurring notifications (via matchDateTimeComponents)
✓ Notification tap handling with deep linking
✓ Time zone aware scheduling
✓ Background notification handling
✓ Notification actions and payloads
✓ Group notifications
✓ Platform-specific customization

**Pros:**
- Flutter Favorite designation (quality vetted by Flutter team)
- Extensive documentation with working examples
- Active maintenance (815 commits, regular releases)
- Mature API with stable patterns
- Large community (means more Stack Overflow answers)
- Better reliability for scheduled notifications
- Supports exact alarm scheduling on Android
- Works with timezone package for precise scheduling

**Cons:**
- iOS has 64 notification limit (platform limitation, not plugin)
- Requires timezone package initialization
- Windows doesn't support repeating notifications
- Some reliability issues with Android scheduled notifications in terminated state (being addressed)
- Slightly more verbose API compared to alternatives

**Dependencies Required:**
```yaml
dependencies:
  flutter_local_notifications: ^21.0.0
  timezone: ^0.9.0  # Required for scheduling
```

---

### 2. awesome_notifications

**Package Details:**
- Latest Version: 0.11.0
- Pub Points: 140/160
- Popularity: 3.42k likes
- Publisher: carda.me (verified)
- License: Apache 2.0
- Repository: https://github.com/rafaelsetragni/awesome_notifications
- Stars: 827

**Platform Support:**
- Android (min API 23 / Android 6.0)
- iOS (min iOS 15)
- Linux (listed but limited documentation)
- macOS ✓
- Windows ✓
- Web ✓

**Key Features:**
✓ Schedule notifications with NotificationCalendar
✓ Recurring notifications (min 60-second interval)
✓ Action buttons and rich layouts
✓ Crontab-style scheduling
✓ Emoji support
✓ Progress bar notifications
✓ Push notifications (in addition to local)

**Pros:**
- More features out of the box (push + local)
- Simpler API for basic use cases
- Better visual customization options
- Crontab scheduling for complex patterns
- Active roadmap (Web and Desktop improvements planned)
- Doesn't require separate timezone package

**Cons:**
- Incompatible with other notification plugins (lock-in)
- Higher minimum iOS requirement (iOS 15 vs iOS 13)
- Less mature (marked as "under development")
- Smaller community
- Moving support to Discord (may affect issue tracking)
- Linux support less documented/tested
- More opinionated architecture

---

### 3. local_notifier (Desktop Only)

**Package Details:**
- Latest Version: 0.1.6
- Platform Support: Linux, macOS, Windows only
- Focus: Desktop notifications

**Notes:**
- NOT suitable for mobile (Android/iOS)
- Does not support scheduling
- Only useful if targeting desktop-only apps
- Requires libnotify-dev on Linux

---

## Setup Requirements by Platform

### Android Setup (flutter_local_notifications)

1. **Update AndroidManifest.xml:**
```xml
<manifest>
  <!-- Required for exact alarms (scheduled notifications) -->
  <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
  <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

  <!-- For notifications on Android 13+ -->
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
</manifest>
```

2. **Update build.gradle:**
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 24  // Required by v21.0.0
    }
}
```

3. **Add notification icon:**
- Place `app_icon.png` in `android/app/src/main/res/drawable/`
- Icon should be white on transparent background

### iOS Setup (flutter_local_notifications)

1. **Update Info.plist:**
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

2. **Request permissions in code:**
```dart
await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
```

### Linux Setup (flutter_local_notifications)

1. **System Dependencies:**
```bash
# Install libnotify for Linux notifications
sudo apt-get install libnotify-dev
```

2. **No additional Flutter configuration required**
- The flutter_local_notifications_linux package is included automatically

---

## Implementation Guide

### Basic Setup

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  // Initialize time zones
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/New_York')); // Set your timezone

  // Android settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  // iOS settings
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Linux settings
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');

  // Combined settings
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    linux: initializationSettingsLinux,
  );

  // Initialize with tap handler
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onNotificationTap,
    onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
  );
}

// Foreground notification tap
void onNotificationTap(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null) {
    // Navigate based on payload
    // Example: Navigator.pushNamed(context, '/task', arguments: payload);
  }
}

// Background notification tap
@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  print('Notification tapped in background: ${response.payload}');
}
```

### Schedule Notification at Specific Time

```dart
Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
  String? payload,
}) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_tasks',
        'Daily Tasks',
        channelDescription: 'Notifications for daily supplement and exercise tasks',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: payload,
  );
}
```

### Schedule Daily Recurring Notification

```dart
Future<void> scheduleDailyNotification({
  required int id,
  required String title,
  required String body,
  required Time notificationTime,
  String? payload,
}) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    _nextInstanceOfTime(notificationTime),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_tasks',
        'Daily Tasks',
        channelDescription: 'Daily reminders for health tasks',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // This makes it daily
    payload: payload,
  );
}

// Helper to calculate next occurrence of a time
tz.TZDateTime _nextInstanceOfTime(Time time) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
    time.second,
  );

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}
```

### Cancel Notification

```dart
Future<void> cancelNotification(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}
```

### Check Pending Notifications

```dart
Future<List<PendingNotificationRequest>> getPendingNotifications() async {
  return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
}
```

---

## Known Issues and Considerations

### flutter_local_notifications

1. **Android Scheduled Notifications in Terminated State:**
   - Some reliability issues reported when app is fully terminated
   - Use `AndroidScheduleMode.exactAllowWhileIdle` for better reliability
   - May require battery optimization exemption on some devices

2. **iOS 64 Notification Limit:**
   - iOS limits apps to 64 scheduled notifications
   - Not a plugin limitation, this is an iOS platform restriction
   - Manage notification IDs carefully

3. **Windows Recurring Notifications:**
   - Windows does not support repeating notifications
   - Must manually reschedule on Windows platform

4. **Timezone Package Required:**
   - Must initialize timezone database before scheduling
   - Adds ~1MB to app size
   - Remember to set local timezone

### awesome_notifications

1. **Plugin Incompatibility:**
   - Cannot use alongside flutter_local_notifications
   - Creates lock-in to this package

2. **Higher Platform Requirements:**
   - iOS 15 minimum (vs iOS 13 for flutter_local_notifications)
   - May exclude older devices

3. **Linux Support:**
   - Listed as supported but less documented
   - May require additional testing

---

## Testing Strategy

1. **Test on Multiple Platforms:**
   - Android (various manufacturers for battery optimization differences)
   - iOS (check 64 notification limit)
   - Linux desktop (if targeting desktop)

2. **Test Scenarios:**
   - App in foreground
   - App in background
   - App terminated
   - Device restart
   - Multiple scheduled notifications
   - Notification tap navigation

3. **Permission Testing:**
   - First launch permission request
   - Denied permissions
   - Revoked permissions after granting

---

## Integration Checklist for Longevity Project

- [ ] Add flutter_local_notifications and timezone dependencies to pubspec.yaml
- [ ] Update Android minSdkVersion to 24
- [ ] Add Android notification permissions to AndroidManifest.xml
- [ ] Create notification icon (app_icon.png) for Android
- [ ] Update iOS Info.plist for background modes
- [ ] Create NotificationService class
- [ ] Initialize notifications in main()
- [ ] Initialize timezone database
- [ ] Implement notification tap routing
- [ ] Schedule notifications for supplements (using database times)
- [ ] Schedule notifications for exercises (using database times)
- [ ] Handle notification ID management
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Test on Linux desktop (if applicable)
- [ ] Add notification settings UI
- [ ] Implement enable/disable notifications toggle
- [ ] Test battery optimization impacts
- [ ] Document notification behavior for users

---

## Additional Resources

- flutter_local_notifications docs: https://pub.dev/packages/flutter_local_notifications
- GitHub repository: https://github.com/MaikuB/flutter_local_notifications
- Example implementation: https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications/example
- timezone package: https://pub.dev/packages/timezone
- Android notification best practices: https://developer.android.com/develop/ui/views/notifications

---

## Conclusion

**flutter_local_notifications** is the clear choice for this project due to:
- Proven reliability and maturity
- Flutter Favorite status
- Better documentation and community support
- Lower platform requirements (iOS 13 vs iOS 15)
- No plugin incompatibilities
- Stronger Linux support

The API is slightly more verbose but offers better control and reliability for scheduled notifications, which is critical for a health tracking app like Longevity.

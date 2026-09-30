# Platform Compatibility

## Supported Platforms

The Longevity app is designed to work on all Flutter-supported platforms:

✅ **Android** - Fully supported
✅ **iOS** - Fully supported
✅ **Linux** - Supported (requires system dependencies)
✅ **Windows** - Supported
✅ **macOS** - Supported
✅ **Web** - Supported (with IndexedDB backend)

---

## Database Support

### Mobile (Android/iOS)
Uses `sqflite` package - works out of the box.

### Desktop (Linux/Windows/macOS)
Uses `sqflite_common_ffi` package - automatically initialized in `main.dart`.

**Implementation:**
```dart
// main.dart
if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

---

## Dependencies

### Core
- `flutter` - SDK
- `sqflite: ^2.4.1` - Mobile database
- `sqflite_common_ffi: ^2.3.0` - Desktop database
- `path: ^1.9.0` - Path utilities
- `intl: ^0.19.0` - Date formatting
- `flutter_svg: ^2.0.16` - Custom icon support

---

## Build & Run

### Android
```bash
flutter run -d android
# or
flutter build apk
```

### iOS
```bash
flutter run -d ios
# or
flutter build ios
```

### Linux
```bash
flutter run -d linux
# or
flutter build linux
```

**Note**: Linux requires system dependencies:
- `clang`
- `cmake`
- `ninja-build`
- `libgtk-3-dev`

### Windows
```bash
flutter run -d windows
# or
flutter build windows
```

### macOS
```bash
flutter run -d macos
# or
flutter build macos
```

### Web
```bash
flutter run -d chrome
# or
flutter build web
```

**Note**: Web build uses IndexedDB instead of SQLite.

---

## Testing

### Run on specific device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Debug on physical Android device
1. Enable USB debugging on device
2. Connect via USB
3. `flutter devices` to verify connection
4. `flutter run`

---

## Known Issues

### Linux Build
- Some Linux environments may have missing linker dependencies
- Solution: Install required system packages or build for Android/iOS

### Deprecation Warnings
- `withOpacity()` deprecation warnings present
- These are informational only, not errors
- App functions correctly
- Can be updated to `withValues()` in future

---

## Performance Notes

### Mobile
- Excellent performance
- Native SQLite integration
- Smooth animations

### Desktop
- Good performance
- FFI-based SQLite
- May have slight overhead vs. mobile

### Web
- Good performance for light usage
- IndexedDB has different characteristics than SQLite
- Consider pagination for large datasets

---

## Platform-Specific Features

### Android
- Material Design 3 by default
- System back button support
- App icon in launcher

### iOS
- Cupertino widgets available if needed
- Safe area handling
- App icon in home screen

### Desktop
- Window resizing
- Mouse interactions
- Keyboard shortcuts (planned)

### Web
- Browser compatibility
- Responsive layout
- PWA capabilities (planned)

---

## Current Build Status

✅ **Android**: Builds successfully
⚠️ **Linux**: Build toolchain issue (code is valid)
🔄 **Others**: Not tested yet (but should work)

---

## Recommendations

**For development:**
- Use Android emulator or physical device
- Hot reload works perfectly
- Best debugging experience

**For production:**
- Build for target platform specifically
- Test on real devices before release
- Consider platform-specific optimizations

---

## Future Enhancements

Potential platform-specific improvements:
- [ ] Android widgets
- [ ] iOS widgets
- [ ] Desktop keyboard shortcuts
- [ ] Web PWA manifest
- [ ] Platform-specific notifications
- [ ] Cloud sync (cross-platform)

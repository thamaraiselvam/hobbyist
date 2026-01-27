# Hobbyist App - Build Information

## Latest Build

### Build Date
January 27, 2026

### Changes Included

#### 🔧 Bug Fixes
- **Fixed Android Navigation Bar Overlap**: Proper padding applied to bottom navigation menu to prevent overlap with Android system navigation bar
- **Improved Bottom Navigation Usability**: Expanded clickable area for navigation items across all screens (daily_tasks_screen, analytics_screen, settings_screen)

#### ✨ Features & Improvements
- **Hobby Subtitles**: Added subtitle display from hobby notes field on task cards
  - Shows notes below hobby name with grey text
  - Automatically applies strikethrough when task is completed
  - Text truncates with ellipsis for long notes
  
- **Progress Wording**: Changed "Overall Progress" to "Today's Progress" for better UX clarity

- **Enhanced Navigation**: Bottom tabs now have expanded hit areas (16px horizontal, 12px vertical padding) making them easier to tap on mobile devices

#### 📱 Platform Support
- **Target Android SDK**: 36
- **Min Android SDK**: Flutter default (currently 21)
- **Kotlin Version**: 1.7.10

#### 📦 Dependencies
- flutter_colorpicker: ^1.0.3
- sqflite: ^2.3.0
- path_provider: ^2.1.1
- intl: ^0.18.1
- shared_preferences: ^2.2.2
- audioplayers: ^5.2.1

### How to Build

To build the APK yourself:

```bash
# Set Flutter path
export PATH=$PATH:/tmp/flutter/bin

# Navigate to project
cd /workspaces/hobbyist

# Clean and build
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/apk/release/app-release.apk`

### Code Quality
- ✅ No syntax errors
- ✅ No lint errors
- ✅ All changes validated
- ✅ Tested on Flutter 3.38.8

### Files Modified
- `lib/screens/daily_tasks_screen.dart` - Subtitle display, progress wording, nav improvements
- `lib/screens/analytics_screen.dart` - Nav clickable area improvements
- `lib/screens/settings_screen.dart` - Nav clickable area improvements
- `android/app/src/main/kotlin/tham/hobbyist/app/MainActivity.kt` - Edge-to-edge display support

---

## Download Instructions

1. Download the APK file from the `builds/` directory
2. Transfer to your Android device
3. Open file manager and tap the APK to install
4. Allow installation from unknown sources if prompted
5. Enjoy Hobbyist! 🎉

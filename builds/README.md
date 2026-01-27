# Hobbyist APK Builds

This directory contains pre-built APK files for the Hobbyist app.

## Latest Build Information

**Build Date**: January 27, 2026  
**Flutter Version**: 3.38.8  
**Android Target SDK**: 36  

## What's New in This Version

### 🐛 Bug Fixes
- ✅ Fixed Android navigation bar overlapping with app menu
- ✅ Improved bottom navigation tab hit area for better usability

### ✨ New Features
- ✅ Added subtitle display on hobby list items (shows hobby notes)
- ✅ Changed progress label to "Today's Progress" for clarity
- ✅ Expanded clickable areas on all navigation tabs

### 📋 Technical Details

#### Files Modified
```
lib/screens/daily_tasks_screen.dart       - Core UI improvements
lib/screens/analytics_screen.dart         - Navigation improvements  
lib/screens/settings_screen.dart          - Navigation improvements
android/app/src/main/kotlin/.../MainActivity.kt  - Edge-to-edge support
```

#### Key Improvements

1. **Bottom Navigation Bar Padding**
   - Added system insets handling to prevent overlap with Android nav bar
   - Applied to all 3 screens: daily_tasks, analytics, settings
   - Formula: `bottom: 12 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom`

2. **Task Card Subtitles**
   - Display hobby notes below hobby name
   - Grey text styling (Colors.white54)
   - Auto-truncates with ellipsis
   - Applies strikethrough when completed

3. **Navigation Tab Improvements**
   - Expanded hit area: 16px horizontal, 12px vertical padding
   - Much easier to tap on mobile devices
   - Consistent styling across all screens

4. **Android Edge-to-Edge Support**
   - Added cutout mode support for notched devices
   - Compatible with Android 10+ (API level 29+)

## Installation Instructions

### Method 1: Using Android Studio
1. Connect your Android phone via USB
2. Enable USB Debugging in Developer Options
3. Place the APK in the `builds/` folder
4. Open Terminal and run:
   ```bash
   adb install builds/hobbyist-release-*.apk
   ```

### Method 2: Direct Installation
1. Download the APK file to your phone
2. Open File Manager on your phone
3. Navigate to Downloads (or where you saved the APK)
4. Tap the APK file to install
5. Allow installation from "Unknown Sources" if prompted

### Method 3: GitHub Release
1. Check the Releases section of this repository
2. Download the APK from the latest release
3. Follow Method 2 above

## Supported Devices

- **Android Version**: Android 5.0+ (API Level 21+)
- **Target**: Android 14 (API Level 36)
- **Architecture**: Recommended for ARMv8 (arm64-v8a)

## Troubleshooting

### "App not installed" Error
- The APK might be corrupted. Try downloading again.
- Ensure your device has at least 100MB free space.
- Try uninstalling any previous version first.

### "Unknown Sources" Warning
- This is normal for apps not from Play Store.
- Go to Settings → Security → Unknown Sources and enable it.

### App Crashes on Launch
- Try clearing app cache: Settings → Apps → Hobbyist → Clear Cache
- Uninstall and reinstall the app.
- Ensure Android 5.0 or higher is installed.

## Features

### Core Functionality
- 📝 Track multiple hobbies
- ✓ Daily task completion tracking
- 🔥 Streak counter for motivation
- 📊 Analytics and progress visualization
- 🎯 Customizable hobby priorities
- 🔧 Personalized settings

### User Experience
- 🎨 Beautiful dark theme
- 💫 Smooth animations
- 📱 Responsive design
- 🔔 Completion notifications with sound
- 🎉 Celebration animations

## Support & Feedback

For issues or feature requests, please open an issue on GitHub:
- GitHub Repository: [thamaraiselvam/hobbyist](https://github.com/thamaraiselvam/hobbyist)

## License

All rights reserved. See LICENSE file for details.

---

**Happy tracking! Keep building those hobbies! 🚀**

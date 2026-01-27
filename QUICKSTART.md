# Hobby Tracker - Quick Start Guide

## 🎯 Overview
A complete Flutter app for tracking daily hobbies with GitHub-style contribution analytics.

## ✨ Features Implemented

### 1. **Hobby Management**
- ✅ Create new hobbies with name, description, and custom color
- ✅ Edit existing hobbies
- ✅ Delete hobbies with confirmation dialog
- ✅ Color picker for visual identification

### 2. **Daily Tracking**
- ✅ Mark hobbies complete/incomplete by tapping
- ✅ Track completions by date
- ✅ Persistent storage using SharedPreferences

### 3. **Analytics Dashboard**
- ✅ GitHub-style contribution chart (12 weeks)
- ✅ Heatmap visualization (darker = more completions)
- ✅ Month labels and day indicators
- ✅ Legend showing activity levels
- ✅ Today's hobby list with completion status

## 📁 Project Structure

```
hobby_tracker/
├── lib/
│   ├── main.dart                      # App entry & theme
│   ├── models/
│   │   └── hobby.dart                 # Data model with JSON serialization
│   ├── services/
│   │   └── hobby_service.dart         # CRUD operations & storage
│   ├── screens/
│   │   ├── dashboard_screen.dart      # Main screen with chart
│   │   └── hobby_form_screen.dart     # Add/edit form
│   └── widgets/
│       └── contribution_chart.dart    # GitHub-style heatmap
├── android/                           # Android configuration
├── ios/                               # iOS configuration
├── pubspec.yaml                       # Dependencies
└── README.md                          # Documentation
```

## 🚀 How to Run

### Prerequisites
- Flutter SDK installed (3.0.0 or higher)
- Android Studio / Xcode (for emulators)
- VS Code with Flutter extension (recommended)

### Steps

1. **Navigate to project directory:**
   ```bash
   cd hobby_tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on emulator/device:**
   ```bash
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device_id>
   
   # Or just run on first available device
   flutter run
   ```

4. **For web (if needed):**
   ```bash
   flutter run -d chrome
   ```

## 📱 How to Use the App

### Creating Your First Hobby
1. Tap the **+** button (bottom right)
2. Enter hobby name (e.g., "Morning Yoga")
3. Add description (e.g., "15 minutes stretching")
4. Tap the color bar to choose a color
5. Tap **Create Hobby**

### Tracking Daily Progress
- Tap any hobby card to mark it complete for today
- The checkmark appears when completed
- Tap again to mark as incomplete

### Viewing Analytics
- The contribution chart shows 12 weeks of history
- Each square represents one day
- Darker greens = more hobbies completed that day
- Scroll horizontally to see full chart

### Editing a Hobby
1. Tap the **edit** icon on any hobby card
2. Modify details
3. Tap **Update Hobby**

### Deleting a Hobby
1. Tap the **delete** icon
2. Confirm deletion in dialog

## 🎨 Color Coding
- Empty hobby list shows helpful onboarding message
- Each hobby has a unique color for easy identification
- Contribution chart uses green intensity (like GitHub)

## 💾 Data Storage
- All data stored locally using SharedPreferences
- Data persists between app sessions
- No internet connection required

## 🔧 Technologies Used
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **shared_preferences**: Local storage
- **intl**: Date formatting
- **flutter_colorpicker**: Color selection widget

## 📊 Chart Details
- **12 weeks** of historical data
- **7 days** per week (Sunday to Saturday)
- **5 intensity levels**: 0, 1, 2, 3, 4+ completions
- Month labels at top
- Day labels (M, W, F) on left

## 🐛 Troubleshooting

### "flutter: command not found"
- Install Flutter SDK or use FVM (Flutter Version Manager)
- Add Flutter to your PATH

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

### Hot reload not working
- Press 'r' in terminal for hot reload
- Press 'R' for hot restart

## 🎯 Future Enhancements Ideas
- Export data to CSV
- Weekly/monthly statistics
- Habit streaks counter
- Reminders/notifications
- Multiple themes
- Cloud sync
- Share achievements

## 📄 License
Created for personal use and learning purposes.

---

**Happy Habit Tracking! 🚀**

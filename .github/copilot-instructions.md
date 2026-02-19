# Hobbyist - Development Guidelines

Hobbyist is a Flutter app for tracking hobbies with a GitHub-style contribution chart. It uses SQLite for local persistence and integrates with Firebase for analytics, authentication, and cloud features.

## Copilot CLI Workflow

**After every code change:**
1. Build and run the app on connected physical device: `flutter run`
2. Do NOT wait for the app to finish launching or stay running
3. Once `flutter run` command is executed, provide a brief summary of changes made
4. Wait for the next user prompt

This ensures changes are tested on real hardware immediately after implementation.

## Commands

### Development
```bash
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device/emulator
flutter analyze                    # Run static analysis
```

### Testing
```bash
flutter test                       # Run all tests
flutter test test/unit/            # Run unit tests only
flutter test test/widget/          # Run widget tests only
flutter test --coverage            # Generate coverage report
flutter test test/unit/models/hobby_test.dart  # Run single test file
```

### Building
```bash
flutter build apk --debug          # Build debug APK
flutter build apk --release        # Build release APK
./build-apk.sh                     # Build and copy to builds/ directory
flutter build ios --release        # Build iOS release
```

### Clean Build
```bash
flutter clean && flutter pub get && flutter run
```

## Architecture

### Service Layer Pattern
All services use singleton pattern with factory constructors:
```dart
class ServiceName {
  static final ServiceName _instance = ServiceName._internal();
  factory ServiceName() => _instance;
  ServiceName._internal();
}
```

Services include:
- `AuthService` - Google Sign-In and Firebase Auth
- `HobbyService` - CRUD operations via DatabaseHelper
- `NotificationService` - Local notifications with timezone support
- `AnalyticsService`, `CrashlyticsService`, `PerformanceService` - Firebase integrations
- `RemoteConfigService` - Feature flags from Firebase
- `QuoteService` - Random motivational quotes
- `SoundService` - Completion sound effects

### Database Architecture
- **Local-first**: All hobby data stored in SQLite (`hobbyist.db`)
- **Database access**: Always through `DatabaseHelper.instance` singleton
- **Schema**: See `lib/database/database_helper.dart` for table definitions
  - `hobbies` table: Core hobby metadata (id, name, notes, repeat_mode, priority, color, reminder_time, etc.)
  - `completions` table: Daily completion records with foreign key to hobbies
  - `settings` table: User preferences (name, preferences)
- **Migrations**: Version-based with `onUpgrade` callback
- **Foreign keys**: Enabled with `PRAGMA foreign_keys = ON`

### Hobby Model Structure
The `Hobby` class includes computed properties:
- `currentStreak` - Calculates consecutive days completed (includes today if completed)
- `longestStreak` - Historical best streak
- `totalCompletions` - Lifetime completion count
- Completions stored as `Map<String, HobbyCompletion>` with date keys (yyyy-MM-dd format)

### State Management
- No external state management library (Provider, Riverpod, etc.)
- State managed with `setState()` in StatefulWidgets
- Data flows: Screen → Service → DatabaseHelper → SQLite
- Widgets rebuild on data changes via `setState()` after service calls

## Code Conventions

### Linting
Extends `package:flutter_lints/flutter.yaml` with additional rules:
- `prefer_const_constructors`
- `prefer_const_literals_to_create_immutables`
- `avoid_print` (use for debugging only, Firebase Crashlytics for production logs)
- `prefer_single_quotes`

### Firebase Integration
- **Privacy-first**: Never send hobby names, notes, or completion data to Firebase
- **Analytics**: Track screen views and feature usage only (no PII)
- **Crashlytics**: Automatic crash reporting (disable hobby data in reports)
- **Auth**: Google Sign-In optional - app works fully offline
- **Remote Config**: Used for feature flags and A/B testing

### Google Sign-In Setup
- Requires SHA-1 certificate added to Firebase Console (Android)
- Must enable Google Sign-In in Firebase Authentication settings
- See `GOOGLE_SIGNIN_SETUP.md` and `QUICKSTART.md` for setup instructions
- Users can skip sign-in and use app fully offline

### Testing Patterns
- Unit tests: Test services and models in isolation
- Widget tests: Use `WidgetTester` to test UI components
- E2E UI tests: Maestro flows in `maestro-tests/` (run with `maestro test maestro-tests/suite.yml`)
- Mock database with `sqflite_common_ffi` for unit tests (see test setup files)

### File Organization
```
lib/
├── main.dart                      # Entry point, Firebase initialization
├── database/
│   └── database_helper.dart       # SQLite schema and migrations
├── models/
│   └── hobby.dart                 # Hobby model with computed properties
├── services/                      # Business logic layer (all singletons)
├── screens/                       # Full-page views
│   ├── splash_screen.dart
│   ├── landing_screen.dart        # Entry with Google Sign-In or offline
│   ├── name_input_screen.dart     # Onboarding
│   ├── daily_tasks_screen.dart    # Main dashboard
│   ├── add_hobby_screen.dart      # Create/edit hobbies
│   ├── analytics_screen.dart
│   └── settings_screen.dart       # Shows email for Google users
├── widgets/                       # Reusable components
│   ├── contribution_chart.dart    # GitHub-style heatmap (12 weeks)
│   └── animated_checkbox.dart
└── utils/                         # Helper functions

test/
├── unit/                          # Service and model tests
└── widget/                        # UI component tests
maestro-tests/                     # E2E UI flows (Maestro)
```

## Platform-Specific Notes

### Android
- Min SDK: 23 (Android 6.0)
- Requires `google-services.json` in `android/app/`
- SHA-1 certificate needed for Google Sign-In (debug and release keystores)
- Notification permissions requested at runtime

### iOS
- Requires `GoogleService-Info.plist`
- Bundle identifier must match Firebase configuration
- Notification permissions requested at runtime

## Common Patterns

### Adding a New Screen
1. Create screen file in `lib/screens/`
2. Extend `StatefulWidget` or `StatelessWidget`
3. Use `Navigator.push()` or `Navigator.pushReplacement()` for navigation
4. Track screen view with `AnalyticsService().logScreenView()`

### Adding a New Service Method
1. Add method to appropriate service class
2. Access database via `DatabaseHelper.instance.database`
3. Use transactions for multi-step database operations
4. Handle errors with try-catch and log to Crashlytics

### Working with Completions
- Date keys always use format: `yyyy-MM-dd` (via `DateFormat('yyyy-MM-dd')`)
- Query completions within date ranges using SQL `WHERE date BETWEEN ? AND ?`
- Update completion status: `completions[dateKey] = HobbyCompletion(...)`
- Trigger sound and animation on completion in UI

### Notifications
- Schedule via `NotificationService().scheduleNotification(hobby)`
- Cancel via `NotificationService().cancelNotification(hobbyId)`
- Update when hobby reminder time changes
- Uses timezone package for proper scheduling across timezones

## Documentation

- `README.md` - Project overview and basic setup
- `QUICKSTART.md` - Google Sign-In setup and common issues
- `GOOGLE_SIGNIN_SETUP.md` - Detailed OAuth configuration
- `docs/DATABASE_SCHEMA.md` - Complete database structure
- `docs/FIREBASE_FEATURES_STATUS.md` - Firebase integration status
- `FEATURES_LIST.md` - Complete feature inventory

## Known Constraints

- No backend server - all data local to device
- Google Sign-In used only for user identity, not data sync
- Contribution chart shows 12 weeks maximum (performance optimization)
- Notifications require platform permissions (may fail silently if denied)
- Firebase services require internet connection (app works offline otherwise)

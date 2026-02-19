# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Compact instructions

When you are using compact, please focus on test output and code changes

## About This Project

Hobbyist is a Flutter mobile app (Android + iOS) for tracking hobbies with a GitHub-style contribution heatmap, streak counting, and analytics. All hobby data is stored locally in SQLite; Firebase is used only for analytics, crash reporting, and feature flags — never for syncing user data.


## Commands

```bash
# Development
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device/emulator
flutter analyze                    # Static analysis (lint)
flutter clean && flutter pub get && flutter run  # Clean rebuild

# Testing
flutter test                       # All tests
flutter test test/unit/            # Unit tests only
flutter test test/widget/          # Widget tests only
flutter test test/unit/models/hobby_test.dart  # Single test file
flutter test --coverage            # Generate coverage report

# Building
flutter build apk --debug          # Debug APK
flutter build apk --release        # Release APK
./build-apk.sh                     # Build + copy to builds/ directory
```

## Architecture

### Data Flow
Screen → Service → DatabaseHelper → SQLite (`hobbyist.db`)

There is no external state management library — all state is managed with `setState()` in `StatefulWidget`s.

### Service Layer
All services in `lib/services/` use the singleton pattern:
```dart
class ServiceName {
  static final ServiceName _instance = ServiceName._internal();
  factory ServiceName() => _instance;
  ServiceName._internal();
}
```
Key services: `HobbyService` (CRUD), `AuthService` (Google Sign-In), `NotificationService`, `AnalyticsService`, `CrashlyticsService`, `RemoteConfigService`/`FeatureFlagsService`.

### Database
- SQLite accessed exclusively through `DatabaseHelper.instance` singleton
- Schema version 5 with migrations in `lib/database/database_helper.dart`
- 3 tables: `hobbies`, `completions` (daily records, FK to hobbies with CASCADE DELETE), `settings` (key-value)
- Date keys always use `yyyy-MM-dd` format
- Foreign keys enforced via `PRAGMA foreign_keys = ON`

### Feature Flags
Developer features are gated by email via `FeatureFlagsService`, which reads a JSON map from Firebase Remote Config (`allow_developer_settings`). Telemetry is off by default (`telemetry_enabled = 'false'` in settings).

### Navigation
Named routes via `onGenerateRoute` in `MaterialApp` for the main flow: `/` (SplashScreen) → `/landing` → `/name-input` → `/dashboard`. All other screens use `Navigator.push()`.

### Testing Patterns
- Unit tests use `sqflite_common_ffi` for an in-memory SQLite database
- Services are mocked with `mockito` (run `flutter pub run build_runner build` after editing mock annotations)
- Integration tests in `integration_test/` require a physical device or emulator to run

### Maestro UI Tests (`maestro-tests/`)

**Pre-test setup (run once per emulator session):**
```bash
# 1. Extract and install Maestro driver APKs
cd /tmp && jar xf ~/.maestro/lib/maestro-client.jar maestro-app.apk maestro-server.apk
adb install -r maestro-app.apk && adb install -r maestro-server.apk

# 2. Start the driver (run in background)
adb shell am instrument -w dev.mobile.maestro.test/androidx.test.runner.AndroidJUnitRunner &
adb forward tcp:7001 tcp:7001

# 3. For onboarding.yml — clear app state first
adb shell pm clear tham.hobbyist.app && adb shell am start -n tham.hobbyist.app/.MainActivity

# 4. For add_hobby.yml — grant notification permission to avoid OS dialog
adb shell pm grant tham.hobbyist.app android.permission.POST_NOTIFICATIONS
adb shell am start -n tham.hobbyist.app/.MainActivity
# Then run onboarding.yml first to complete onboarding
```

**Running tests:**
```bash
maestro test maestro-tests/onboarding.yml
maestro test maestro-tests/add_hobby.yml
```

**Known issues and rules for writing Maestro YAML:**
- `launchApp` (with or without `clearState`) crashes on this emulator due to a Maestro 2.1.0 TcpForwarder bug — never use it; manage app lifecycle via ADB instead
- `timeout:` is **not** a valid property on `assertVisible` or `tapOn` — use `extendedWaitUntil: visible: ... timeout: N` when a wait is needed
- Use `waitForAnimationToEnd` (not `waitForAnimationToSettle` — wrong name)
- `text:` in `assertVisible` uses anchored regex — `Hello` won't match `Hello, John Doe!`; use `Hello.*`
- After `adb shell pm clear`, Firebase init fails and crashes `AuthService` — fixed in code, but always re-grant permissions and restart cleanly

**Flutter widget IDs for Maestro:**
- `Key()` alone does **not** expose `resource-id` in the Android accessibility tree
- Every testable widget needs `Semantics(identifier: TestKeys.xxx, child: Widget(key: const Key(TestKeys.xxx), ...))`
- All TestKey string values are defined in `lib/constants/test_keys.dart`

## Code Conventions

- Lint config extends `package:flutter_lints/flutter.yaml` — use `prefer_single_quotes`, avoid `print()` in production code
- Track screen views with `AnalyticsService().logScreenView()` when adding new screens
- Use transactions for multi-step database operations
- **Firebase privacy rule**: Never send hobby names, notes, or completion data to Firebase

## Firebase Setup

Firebase config files are not committed. Use environment variables or the `google-services.json` / `GoogleService-Info.plist` files locally. See `docs/BUILD_WITH_ENV.md` for environment-based build instructions.

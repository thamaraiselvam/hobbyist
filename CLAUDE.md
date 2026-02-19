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

## Code Conventions

- Lint config extends `package:flutter_lints/flutter.yaml` — use `prefer_single_quotes`, avoid `print()` in production code
- Track screen views with `AnalyticsService().logScreenView()` when adding new screens
- Use transactions for multi-step database operations
- **Firebase privacy rule**: Never send hobby names, notes, or completion data to Firebase

## Firebase Setup

Firebase config files are not committed. Use environment variables or the `google-services.json` / `GoogleService-Info.plist` files locally. See `docs/BUILD_WITH_ENV.md` for environment-based build instructions.

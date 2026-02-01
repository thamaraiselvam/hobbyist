# hobbyist Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-02-01

## Active Technologies

- Flutter (Dart SDK `>=3.0.0 <4.0.0`) + `sqflite`, `flutter_local_notifications`, `timezone`, `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`, `firebase_remote_config`, `firebase_auth`, `google_sign_in`, `shared_preferences`, `intl`, `audioplayers` (001-hobbyist)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Flutter (Dart SDK `>=3.0.0 <4.0.0`)

## Code Style

Flutter (Dart SDK `>=3.0.0 <4.0.0`): Follow standard conventions

## Recent Changes

- 001-hobbyist: Added Flutter (Dart SDK `>=3.0.0 <4.0.0`) + `sqflite`, `flutter_local_notifications`, `timezone`, `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`, `firebase_remote_config`, `firebase_auth`, `google_sign_in`, `shared_preferences`, `intl`, `audioplayers`

<!-- MANUAL ADDITIONS START -->
## Manual Overrides (Flutter repo)

### Actual Project Structure

```text
lib/
test/
integration_test/
android/
ios/
assets/
docs/
specs/
```

### Common Commands

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter test --coverage`
- `flutter test integration_test`
- `flutter run`

### Repo Notes

- Local persistence uses SQLite via `sqflite` (`hobbyist.db`), schema defined in `lib/database/database_helper.dart`.
- Notifications use `flutter_local_notifications` + `timezone`; OS permissions may be required.
- Firebase is integrated (Analytics/Crashlytics/Performance/Remote Config/Auth); avoid sending PII or hobby content.
<!-- MANUAL ADDITIONS END -->

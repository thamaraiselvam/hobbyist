# Quickstart: Hobbyist

**Branch**: `001-hobbyist`

## Run the app

From repository root:

- `flutter pub get`
- `flutter run`

## Core smoke test (offline)

1. Launch app → Landing
2. Choose offline flow → enter display name
3. Create a hobby (name + optional notes + color + repeat mode)
4. Toggle completion for today
5. Force close + reopen → confirm hobby + completion persists
6. Open Analytics → confirm contribution history/streaks reflect data
7. Open Settings → confirm toggles persist

## Notifications smoke test

1. In Settings, enable push notifications
2. For a hobby, set a reminder time
3. Accept notification permissions when prompted
4. Confirm a scheduled reminder appears (platform dependent)

Notes:
- Android exact alarms may require extra permission; the app should degrade gracefully if not granted.

## Google sign-in smoke test (optional)

Prerequisites:
- Android: `android/app/google-services.json` present and SHA-1 registered in Firebase console
- iOS: URL scheme configured with `REVERSED_CLIENT_ID` and Firebase iOS config present

Test:
1. Landing → Continue with Google
2. Choose account
3. Confirm navigation to dashboard
4. Settings shows email and name (for Google user)

## Tests

- Unit/widget tests: `flutter test`
- Integration tests: `flutter test integration_test`

## Database debugging

The SQLite DB is `hobbyist.db` stored in the app documents directory.

If needed, add a debug action to print `DatabaseHelper.getDatabasePath()` and inspect with platform tooling.

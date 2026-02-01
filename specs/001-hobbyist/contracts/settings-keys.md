# Settings Keys Contract (SQLite + SharedPreferences)

This contract documents known configuration keys and their meaning.

## SQLite `settings` table

**Source**: `lib/database/database_helper.dart`, `lib/services/hobby_service.dart`

### Default keys (created on first DB creation)
- `user_name`: display name (string)
- `push_notifications`: global notifications enabled (string boolean: `true`/`false`)
- `completion_sound`: completion sound enabled (string boolean)
- `has_seen_landing`: onboarding/landing seen (string boolean)

### Telemetry keys
- `telemetry_enabled`: telemetry enabled (string boolean: `true`/`false`, default `true` - enabled by default, no PII collected)

Notes:
- When `telemetry_enabled=false`, Analytics/Crashlytics/Performance collection MUST be disabled.
- Default is `true` (enabled) as no PII is collected (hobby names, notes, completion data not sent).
- User can opt-out via Settings screen.

### Keys written by auth flow (current implementation)
- `userName`: display name (string)
- `userEmail`: email (string)

**Note**: The codebase currently uses both snake_case and camelCase keys. Plan/design should standardize this to avoid conflicting reads/writes.

## SharedPreferences

**Source**: `lib/services/auth_service.dart`

- `hasCompletedOnboarding` (bool)
- `authMethod` (string: `offline` or `google`)

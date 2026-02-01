# Research: Hobbyist

**Branch**: `001-hobbyist`  
**Date**: 2026-02-01  
**Spec**: [spec.md](spec.md)

This document consolidates technical decisions based on the current codebase (Flutter app already implemented) and the project constitution.

## Decisions

### 1) Local persistence via SQLite (sqflite)

- **Decision**: Use SQLite (`hobbyist.db`) with three primary tables: `hobbies`, `completions`, `settings`.
- **Rationale**: Matches existing implementation; provides offline-first durability and efficient queries with indexes.
- **Alternatives considered**: Hive (simpler key/value), Drift (typed queries), SharedPreferences-only (insufficient relational modeling).

### 2) Completion identity and date format

- **Decision**: Record completions keyed by `(hobby_id, date)` where `date` is a `YYYY-MM-DD` string and treated as the device’s local calendar date at the moment of toggling.
- **Rationale**: Matches DB unique constraint and model logic; avoids double entries and supports consistent history display.
- **Alternatives considered**: Store UTC date only (timezone edge cases), store epoch-only and compute date view (harder queries).

### 3) Schema versioning and migrations

- **Decision**: Maintain incremental DB schema versions and lightweight `ALTER TABLE` migrations.
- **Rationale**: Current `DatabaseHelper` uses DB version 3 with upgrades adding `reminder_time` then `custom_day`.
- **Alternatives considered**: Full migration framework; destructive migrations (violates data preservation expectations).

### 4) Reminder scheduling

- **Decision**: Schedule notifications per hobby using `flutter_local_notifications` with `timezone` support, honoring both:
  1) OS-level notification permissions, and
  2) an app-level `push_notifications` setting.
- **Rationale**: Current `NotificationService` checks both and degrades gracefully if exact alarms aren’t available.
- **Alternatives considered**: Simple periodic timers (unreliable), background fetch scheduling (platform constraints).

### 5) Repeat modes and custom day semantics

- **Decision**: Support repeat modes: `daily`, `weekly`, `monthly`.
  - For `weekly`, `custom_day` stores day-of-week (0–6, Mon–Sun).
  - For `monthly`, `custom_day` stores day-of-month (1–31).
- **Rationale**: Matches existing `Hobby` model fields and notification scheduling.
- **Alternatives considered**: Arbitrary cron-like rules (too complex for current scope).

### 6) Firebase integrations and “privacy by default” alignment

- **Decision**: Keep Firebase integrations already present (Analytics, Crashlytics, Performance, Remote Config, Auth), but make data collection transparent and user-controllable.
- **Rationale**: Codebase currently initializes Firebase services at startup, but the constitution requires privacy-first operation and optional cloud features.
- **Alternatives considered**:
  - Remove Firebase entirely (conflicts with existing feature set and instrumentation).
  - Keep Firebase always-on without disclosure (conflicts with constitution).

**Planned alignment actions** (explicit opt-in telemetry):
- Add clear disclosure in Settings (and/or first-run screen) describing:
  - what is collected (non-PII event telemetry, crash reports),
  - what is not collected (hobby content/history),
  - how to disable analytics/crash reporting.
- Gate analytics/crash/performance collection behind a local preference defaulting to OFF and respect it immediately.

### 7) UI theme and navigation

- **Decision**: Use Material 3, dark-first, purple primary palette, with routed screens:
  - Splash → Landing → Name Input → Dashboard
  - Bottom navigation (Dashboard / Analytics / Settings)
- **Rationale**: Matches `MaterialApp` theme config and screen structure in current implementation.
- **Alternatives considered**: None (out of scope).

## Notes on known mismatches
- **Settings keys**: DB defaults use snake_case keys (e.g., `user_name`), while auth flow also writes camelCase keys (e.g., `userName`). Plan/design should standardize keys or document both.

## Additional product decisions (per updated requirements)

### 8) Unlimited streaks

- **Decision**: Streak calculations are unbounded (no maximum streak day cap).
- **Rationale**: Product requirement: “there is no limit for streaks.”
- **Alternatives considered**: Keep `max_streak_days` from Remote Config as a hard cap (rejected).

Implementation note: Remote Config currently defines `max_streak_days`, but it will be treated as deprecated and not enforced.

### 9) No automatic deletion/archival (user deletion allowed)

- **Decision**: The system MUST NOT automatically delete or archive hobbies/tasks or completion history (no retention window, no background cleanup). Users MAY delete a hobby explicitly, which also removes its associated completion history.
- **Rationale**: Product requirement: no auto delete/auto archive and no storage-time limit imposed by the system.
- **Alternatives considered**: Automatic archival after inactivity (rejected), auto-cleanup after N days (rejected).

Implementation note: Current code uses explicit delete + DB constraints (including cascading completion cleanup). This is compatible with “no automatic deletion/archival” as long as deletion is always user-initiated.

# Data Model: Hobbyist

**Branch**: `001-hobbyist`  
**Date**: 2026-02-01  
**Spec**: [spec.md](spec.md)

This document describes the functional data model as implemented (SQLite + in-memory models) and the constraints required by the feature spec.

## Entities

### 1) Hobby

**Represents**: A tracked habit/task.

**Primary fields (SQLite `hobbies`)**
- `id` (TEXT, PK): Unique hobby identifier.
- `name` (TEXT, NOT NULL): Display name.
- `notes` (TEXT, nullable): Optional description.
- `repeat_mode` (TEXT, NOT NULL, default `daily`): One of `daily`, `weekly`, `monthly`.
- `priority` (TEXT, NOT NULL, default `medium`): One of `low`, `medium`, `high`.
- `color` (INTEGER, NOT NULL): UI color value.
- `reminder_time` (TEXT, nullable): Time in `HH:mm`.
- `custom_day` (INTEGER, nullable):
  - weekly: 0–6 (Mon–Sun)
  - monthly: 1–31
- `created_at` (INTEGER, NOT NULL): Unix epoch milliseconds.
- `updated_at` (INTEGER, NOT NULL): Unix epoch milliseconds.

**Validation rules**
- `name` must be non-empty.
- `repeat_mode` must be one of the supported values.
- If `reminder_time` is provided, it must match `HH:mm` and be a valid time.
- If `repeat_mode` is `weekly` or `monthly`, `custom_day` must be present and within range.

**Relationships**
- 1 Hobby → many Completions (via `completions.hobby_id`)

**Retention rule**
- There is no automatic deletion/archival or retention window.
- Users may delete a hobby; when deleted, its completion history is removed with it.

### 2) Completion

**Represents**: Whether a hobby was completed on a given day.

**Primary fields (SQLite `completions`)**
- `id` (INTEGER, PK AUTOINCREMENT)
- `hobby_id` (TEXT, FK → `hobbies.id`)
- `date` (TEXT, NOT NULL): `YYYY-MM-DD` string in device local calendar.
- `completed` (INTEGER, NOT NULL, default 0): 0/1.
- `completed_at` (INTEGER, nullable): Unix epoch milliseconds.

**Validation rules**
- Unique constraint on (`hobby_id`, `date`) — at most one completion row per hobby per day.
- If `completed = 1`, `completed_at` SHOULD be set.

**State transitions**
- Incomplete → Complete: set `completed = 1`, set `completed_at = now`.
- Complete → Incomplete: set `completed = 0`, set `completed_at = null`.

### 3) Preferences / Settings

**Represents**: App-level and user-level preferences.

**Storage**
- SQLite `settings` table: (`key`, `value`, `updated_at`)
- `shared_preferences`: onboarding/auth flags (e.g., `hasCompletedOnboarding`, `authMethod`)

**Known keys (current implementation)**
- SQLite defaults:
  - `user_name`: display name default
  - `push_notifications`: global reminders toggle
  - `completion_sound`: sound effects toggle
  - `has_seen_landing`: whether landing screen was seen
- Auth flow also writes:
  - `userName` and `userEmail` (camelCase keys)

**Note**: Keys should be standardized (recommended) or documented as both supported.

### 4) UserProfile

**Represents**: A user identity for display and (optional) sign-in.

**Fields**
- `display_name`: from offline entry or from Google account.
- `email` (optional): only for signed-in users.
- `auth_method`: `offline` or `google`.

**Privacy rule**
- Hobby content/history remains local and MUST NOT be sent to Firebase as PII.

## Derived metrics

### Streak

**Definition (as implemented)**
- Current streak is counted by checking consecutive completed days going backward from yesterday.
- Today’s completion counts towards streak if completed.

**Upper bound**
- No upper bound. Streak calculations are unbounded.

### Contribution history

**Definition**
- A calendar-like heatmap showing at least the last 12 weeks.
- Each day cell intensity is based on number of completions that day.

## Relationships

```text
hobbies (1) ──< completions (many)

Deletions:
- User-initiated hobby deletion removes associated completions.

settings (key/value)
shared_preferences (onboarding/auth flags)
```

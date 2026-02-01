# Analytics Events Contract (Firebase Analytics)

**Scope**: Anonymous telemetry events emitted by the app. MUST NOT include hobby names/notes or other PII.

**Source**: `lib/services/analytics_service.dart`

## Events

### Onboarding
- `user_onboarding_complete`
  - `timestamp` (ms)
- `landing_page_viewed`

### Hobby management
- `hobby_created`
  - `hobby_id`
  - `priority`
  - `repeat_mode`
  - `color`
  - `timestamp`
- `hobby_updated`
  - `hobby_id`
  - `priority` (optional)
  - `repeat_mode` (optional)
  - `timestamp`
- `hobby_deleted`
  - `hobby_id`
  - `reason` (default `user_action`)
  - `timestamp`

### Completions
- `completion_toggled`
  - `hobby_id`
  - `completed` (bool)
  - `current_streak` (int)
  - `timestamp`
- `streak_milestone` (only for milestone streaks)
  - `hobby_id`
  - `streak_count`
  - `milestone`
  - `timestamp`
- `completion_sound_played`

### Engagement
- `analytics_viewed`
  - `timestamp`
- `setting_changed`
  - `setting_name`
  - `setting_value`
  - `timestamp`
- `quote_displayed`

### Performance
- `db_query_performance`
  - `query_type`
  - `duration_ms`
  - `timestamp`

### Daily stats
- `daily_stats`
  - `total_hobbies`
  - `completed_today`
  - `avg_completion_rate`
  - `timestamp`

### Session
- `session_end`
  - `duration_seconds`
  - `timestamp`

## Privacy constraints

- MUST NOT include user-entered hobby names, notes, or free-form text.
- User email MUST NOT be sent as analytics event parameter.
- Prefer stable non-PII identifiers (`hobby_id`) and coarse-grained metrics.

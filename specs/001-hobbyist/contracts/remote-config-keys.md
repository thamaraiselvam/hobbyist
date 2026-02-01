# Remote Config Contract

**Source**: `lib/services/remote_config_service.dart`

Defaults and expected types:

## Feature flags
- `enable_analytics_screen` (bool)
- `enable_notifications` (bool)
- `enable_sound_feedback` (bool)
- `enable_streak_milestones` (bool)

## UI configuration
- `show_motivational_quotes` (bool)
- `max_hobbies_limit` (int) — default 50
- `default_theme_mode` (string) — default `dark`

## Performance settings
- `cache_duration_hours` (int) — default 12
- `fetch_timeout_seconds` (int) — default 60

## Feature limits
- `max_streak_days` (int) — default 365 (deprecated; not enforced because streaks are unlimited)
- `enable_premium_features` (bool)

## A/B testing
- `onboarding_flow_version` (string) — default `v1`
- `completion_animation_style` (string) — default `default`

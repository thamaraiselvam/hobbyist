# Maestro Test ID Mapping for Hobbyist

This document maps all critical UI elements to their required Maestro test IDs (`Key`s).

## Overview

Maestro uses Flutter's `Key` system to identify and interact with widgets. Each element below needs to be wrapped with its corresponding `Key`.

---

## 1. Landing Screen
**File**: `lib/screens/landing_screen.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| "Continue Offline" Button | Line 196 | `continue_offline_button` | `tapOn` | **CRITICAL** |

---

## 2. Name Input Screen
**File**: `lib/screens/name_input_screen.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| Name TextField | Line 100 | `name_input_field` | `inputText` | **CRITICAL** |
| "Start My Journey" Button | Line 136 | `start_journey_button` | `tapOn` | **CRITICAL** |

---

## 3. Daily Tasks Screen (Dashboard)
**File**: `lib/screens/daily_tasks_screen.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| Add Hobby FAB | Line 1368 | `add_hobby_fab` | `tapOn` | **CRITICAL** |
| Hobby Checkbox (dynamic) | Line 1069 | `hobby_checkbox_${hobby.id}` | `tapOn` | **CRITICAL** |
| Day Selector Today Pill | Line 920 | `day_selector_today` | `tapOn` | HIGH |
| Bottom Nav - Home | Line 1356 | `bottom_nav_home` | `tapOn` | **CRITICAL** |
| Bottom Nav - Lists | Line 1357 | `bottom_nav_lists` | `tapOn` | HIGH |
| Bottom Nav - Analytics | Line 1359 | `bottom_nav_analytics` | `tapOn` | **CRITICAL** |
| Bottom Nav - Settings | Line 1360 | `bottom_nav_settings` | `tapOn` | **CRITICAL** |

---

## 4. Add Hobby Screen
**File**: `lib/screens/add_hobby_screen.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| Hobby Name Input | Line 306 | `hobby_name_input` | `inputText` | **CRITICAL** |
| Frequency: Daily Button | Line 431 | `daily_frequency_button` | `tapOn` | **CRITICAL** |
| Frequency: Weekly Button | Line 432 | `weekly_frequency_button` | `tapOn` | **CRITICAL** |
| Frequency: Monthly Button | Line 434 | `monthly_frequency_button` | `tapOn` | **CRITICAL** |
| Color Palette Buttons (0-9) | Line 776 | `color_palette_button_${index}` | `tapOn` | HIGH |
| Notify Toggle | Line 626 | `notify_toggle` | `tapOn` | HIGH |
| Reminder Time Picker | Line 691 | `reminder_time_picker` | `tapOn` | HIGH |
| Create/Update Hobby Button | Line 784 | `create_hobby_button` | `tapOn` | **CRITICAL** |
| Cancel Button | Line 810 | `cancelHobbyButton` | `tapOn` | MEDIUM |

---

## 5. Analytics Screen
**File**: `lib/screens/analytics_screen.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| Current Streak Card | Line 572 | `current_streak_card` | `assertVisible` | **CRITICAL** |
| Best Streak Card | Line 663 | `best_streak_card` | `assertVisible` | **CRITICAL** |
| Total Done Card | Line 755 | `total_done_card` | `assertVisible` | **CRITICAL** |
| Period: Weekly Button | Line 1018 | `period_weekly_button` | `tapOn` | **CRITICAL** |
| Period: Monthly Button | Line 1020 | `period_monthly_button` | `tapOn` | **CRITICAL** |
| Period: Yearly Button | Line 1022 | `period_yearly_button` | `tapOn` | **CRITICAL** |
| Activity Map Section | Line 1205 | `activity_map_section` | `assertVisible` | HIGH |
| Completion Calendar Section | Line 1401 | `completion_calendar_section` | `assertVisible` | HIGH |

---

## 6. Settings Screen
**File**: `lib/screens/settings_screen.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| Push Notifications Toggle | Line 527 | `push_notifications_toggle` | `tapOn` | HIGH |
| Sound & Vibration Toggle | Line 538 | `completion_sound_toggle` | `tapOn` | HIGH |
| Send Feedback Button | Line 725 | `send_feedback_button` | `tapOn` | **CRITICAL** |
| Privacy Policy Link | Line 740 | `privacy_policy_link` | `tapOn` | MEDIUM |
| Logout Button | Line 879 | `logout_button` | `tapOn` | MEDIUM |

---

## 7. Feedback Screen
**File**: `lib/screens/feedback_screen.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| Feedback TextArea | Line 129 | `feedback_textarea` | `inputText` | **CRITICAL** |
| Email Input | Line 181 | `email_input` | `inputText` | HIGH |
| Submit Feedback Button | Line 208 | `submit_feedback_button` | `tapOn` | **CRITICAL** |

---

## 8. Widgets
**File**: `lib/widgets/animated_checkbox.dart`

| Element | Location | Key ID | Maestro Action | Priority |
|---------|----------|--------|-----------------|----------|
| Animated Checkbox (parent) | Line 68 | `hobby_checkbox_${hobby.id}` | `tapOn` | **CRITICAL** |

---

## Implementation Strategy

### Step 1: Add Keys to Critical Paths
Start with **CRITICAL** priority items (marked in red). These are required for E2E test flows.

### Step 2: Naming Convention
Use snake_case for all key IDs. For dynamic elements, use parameterized names:
```dart
Key('hobby_checkbox_${hobby.id}')
Key('color_palette_button_$index')
```

### Step 3: Apply Keys
```dart
ElevatedButton(
  key: const Key('continue_offline_button'),
  onPressed: () { ... },
  child: const Text('Continue Offline'),
)
```

### Step 4: Validation
Run these commands after adding keys:
```bash
flutter analyze
flutter test
maestro test maestro-tests/onboarding.yml
```

---

## Test Flow Mapping

| Flow | Test File | Key IDs Used | Status |
|------|-----------|-------------|--------|
| Onboarding | `onboarding.yml` | landing, name_input, start_journey, bottom_nav | ✅ Ready |
| Add Hobby | `add_hobby.yml` | add_hobby_fab, hobby_name_input, frequency, color, notify, create | ✅ Ready |
| Complete Hobby | `complete_hobby.yml` | hobby_checkbox, completion states | ✅ Ready |
| View Analytics | `view_analytics.yml` | bottom_nav_analytics, period_buttons, cards | ✅ Ready |
| Settings & Feedback | `settings_feedback.yml` | bottom_nav_settings, feedback_textarea, submit | ✅ Ready |

---

## Notes

- All keys should be immutable constants (`const Key(...)`)
- Avoid using widget text as identifiers (brittle to localization)
- Test keys are compile-time safe in Flutter
- Maestro runs tests against actual device/emulator
- Consider accessibility when adding keys (don't duplicate semanticLabels)


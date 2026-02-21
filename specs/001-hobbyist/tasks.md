---
description: "Implementation task breakdown for Hobbyist"
---

# Tasks: Hobbyist

**Input**: Design documents from `/specs/001-hobbyist/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Ensure the repo is ready to implement and validate this feature slice.

- [ ] T001 Confirm smoke-test steps are accurate and runnable in specs/001-hobbyist/quickstart.md
- [ ] T002 Confirm feature constraints and “no auto-delete/archive + unlimited streaks” are reflected in specs/001-hobbyist/plan.md
- [ ] T003 [P] Confirm DB/telemetry contracts match implementation expectations in specs/001-hobbyist/contracts/sqlite-schema.sql
- [ ] T004 [P] Confirm analytics event names/params match implementation expectations in specs/001-hobbyist/contracts/analytics-events.md
- [ ] T005 [P] Add/confirm a test command baseline and coverage output path in specs/001-hobbyist/quickstart.md
- [ ] T006 Run `flutter analyze` and record any constitution-blocking warnings in specs/001-hobbyist/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Cross-cutting behavior that must be correct before user-story work is considered complete.

- [ ] T007 Audit for any automatic deletion/archival/retention logic and remove it if present in lib/services/hobby_service.dart
- [ ] T008 Audit for any max-streak cap usage and remove/ignore it (treat as deprecated) in lib/services/remote_config_service.dart
- [ ] T009 Remove any max-streak cap logic from streak calculations in lib/models/hobby.dart
- [ ] T010 Add a single source of truth for “local calendar date” (YYYY-MM-DD) used for completions in lib/utils/date_utils.dart
- [ ] T011 Update completion toggle code to use the shared date utility in lib/services/hobby_service.dart
- [ ] T012 Add/verify DB helper methods needed for story slices (hobbies CRUD, completions CRUD, history queries) in lib/database/database_helper.dart
- [ ] T013 Standardize settings key usage for display name reads/writes to avoid conflicts in lib/services/hobby_service.dart
- [ ] T014 Standardize auth-flow settings writes for display name/email to avoid conflicting keys in lib/services/auth_service.dart
- [ ] T015 Define a consistent non-technical error UX pattern (snackbar/dialog copy guidelines) in lib/utils/error_presenter.dart
- [ ] T016 Add a shared helper for showing user-facing errors and apply it to core flows in lib/screens/daily_tasks_screen.dart
- [ ] T017 Add a shared helper for showing user-facing errors and apply it to core flows in lib/screens/settings_screen.dart
- [ ] T018 Add baseline unit tests for date parsing/formatting in test/unit/date_utils_test.dart
- [ ] T019 Add baseline unit tests for streak calculation (unbounded) in test/unit/streak_calculation_test.dart
- [ ] T020 Add baseline unit tests for hobby persistence/service invariants in test/unit/hobby_service_test.dart
- [ ] T021 Run `flutter test --coverage` and confirm it meets the constitution gate (80% overall; targeted 100% for DB/models/core services where feasible) in docs/TEST_SUMMARY.md

**Checkpoint**: Foundational behavior is consistent (no retention jobs, no streak caps, consistent date semantics, stable settings keys).

---

## Phase 3: User Story 1 - Create hobbies and track daily completion (Priority: P1) 🎯 Core

**Goal**: Create a hobby, show it on Today, toggle completion for today, persist across restarts.

**Independent Test**: Fresh install → offline or sign-in → create hobby → mark complete → restart app → completion persists (specs/001-hobbyist/spec.md).

### Implementation (US1)

- [ ] T022 [US1] Ensure offline onboarding path can proceed without sign-in in lib/screens/landing_screen.dart
- [ ] T023 [US1] Ensure offline display name capture + persistence works in lib/screens/name_input_screen.dart
- [ ] T024 [US1] Ensure hobby create UI captures name/notes/color/repeat mode in lib/screens/daily_tasks_screen.dart
- [ ] T025 [US1] Persist new hobbies to SQLite (and reload on app start) in lib/services/hobby_service.dart
- [ ] T026 [US1] Ensure Today list renders all active hobbies and completion state for today in lib/screens/daily_tasks_screen.dart
- [ ] T027 [US1] Implement completion toggle for today with rapid-toggle safety in lib/services/hobby_service.dart
- [ ] T028 [US1] Wire completion toggle UI + optimistic update behavior in lib/screens/daily_tasks_screen.dart
- [ ] T029 [US1] Implement hobby edit while preserving history in lib/services/hobby_service.dart
- [ ] T030 [US1] Wire hobby edit UI (notes/color/repeat/priority/reminder fields) in lib/screens/daily_tasks_screen.dart
- [ ] T031 [US1] Implement delete hobby confirmation and user-initiated delete in lib/screens/daily_tasks_screen.dart
- [ ] T032 [US1] Ensure hobby deletion removes associated completion history via DB constraints in lib/database/database_helper.dart

**Checkpoint**: US1 can be demoed end-to-end without network.

---

## Phase 4: User Story 2 - Visualize progress with contribution history and streaks (Priority: P2)

**Goal**: Show contribution-style history and streak metrics based on completion history.

**Independent Test**: Record completions across multiple days → Analytics shows correct history + current/best streak with no maximum cap (specs/001-hobbyist/spec.md).

### Implementation (US2)

- [ ] T033 [US2] Implement query helpers for contributions (last 12 weeks) in lib/services/hobby_service.dart
- [ ] T034 [US2] Implement streak calculation helpers (current + best) without caps in lib/models/hobby.dart
- [ ] T035 [US2] Render contribution history heatmap (0 vs 1+ completions distinct) in lib/screens/analytics_screen.dart
- [ ] T036 [US2] Render per-hobby streak metrics (current + best) in lib/screens/analytics_screen.dart
- [ ] T037 [US2] Ensure timezone/date-boundary rules match “local calendar date at toggle time” in lib/utils/date_utils.dart

**Checkpoint**: US2 works with offline data and matches recorded completions.

---

## Phase 5: User Story 3 - Get reminders and manage preferences (Priority: P3)

**Goal**: Optional reminders with respectful permissions; settings persist; app remains usable when permissions denied.

**Independent Test**: Enable reminders → set hobby reminder time → observe scheduled reminder (platform dependent) → disable reminders → future reminders stop (specs/001-hobbyist/quickstart.md).

### Implementation (US3)

- [ ] T038 [US3] Ensure global reminders toggle is persisted and respected immediately in lib/screens/settings_screen.dart
- [ ] T039 [US3] Implement/verify notification permission request + explanatory copy in lib/screens/settings_screen.dart
- [ ] T040 [US3] Ensure reminder scheduling respects both OS permissions and app-level toggle in lib/services/notification_service.dart
- [ ] T041 [US3] Ensure per-hobby reminder_time is saved and used for scheduling in lib/services/hobby_service.dart
- [ ] T042 [US3] Ensure changing reminder time reschedules notifications correctly in lib/services/notification_service.dart
- [ ] T043 [US3] Ensure disabling reminders cancels scheduled notifications in lib/services/notification_service.dart
- [ ] T044 [US3] Ensure completion sound preference is persisted and respected in lib/screens/settings_screen.dart

### Privacy-by-default alignment (US3)

- [x] T045 [US3] Add a user-facing telemetry toggle (default ON - no PII collected) and persist it in lib/screens/settings_screen.dart
- [x] T046 [US3] Add a disclosure UI for telemetry collection (what is collected/not collected) in lib/screens/settings_screen.dart
- [x] T047 [US3] Gate Firebase Analytics event logging behind the telemetry toggle in lib/services/analytics_service.dart
- [x] T048 [US3] Gate Crashlytics collection behind the telemetry toggle in lib/services/crashlytics_service.dart
- [x] T049 [US3] Gate Performance traces behind the telemetry toggle in lib/services/performance_service.dart
- [x] T050 [US3] Document the new settings key(s) and behavior in specs/001-hobbyist/contracts/settings-keys.md

**Checkpoint**: Reminders and preferences work; telemetry is transparent and user-controllable.

---

## Phase 6: User Story 4 - Optional sign-in with offline-first behavior (Priority: P4)

**Goal**: Optional Google sign-in that never blocks offline usage.

**Independent Test**: One user completes onboarding offline; another completes Google sign-in; both reach dashboard and can track hobbies (specs/001-hobbyist/spec.md).

### Implementation (US4)

- [ ] T051 [US4] Ensure Google sign-in is optional and cancelable without blocking offline flow in lib/screens/landing_screen.dart
- [ ] T052 [US4] Ensure auth errors and offline scenarios degrade gracefully in lib/services/auth_service.dart
- [ ] T053 [US4] Ensure signed-in profile details render without exposing PII to analytics in lib/screens/settings_screen.dart
- [ ] T054 [US4] Ensure analytics never logs user email and only uses non-PII IDs in lib/services/analytics_service.dart

**Checkpoint**: Sign-in is purely additive; offline tracking remains first-class.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Hardening, perf, accessibility, and end-to-end validation.

- [ ] T055 [P] Run the offline smoke test and update any stale steps in specs/001-hobbyist/quickstart.md
- [ ] T057 [P] Verify analytics events emitted match the contract (no hobby names/notes) in lib/services/analytics_service.dart
- [ ] T058 [P] Add accessibility labels for key controls (toggle complete, add hobby, settings toggles) in lib/screens/daily_tasks_screen.dart
- [ ] T059 [P] Add accessibility labels for analytics charts/heatmap widgets in lib/screens/analytics_screen.dart
- [ ] T060 [P] Run performance spot-checks for DB queries and document any regressions in specs/001-hobbyist/research.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) → Foundational (Phase 2) → User Stories (Phases 3–6) → Polish (Phase 7)

### User Story Dependencies

- US1 is the base.
- US2 depends on US1 data being recorded (but can be implemented once foundational query/date utilities exist).
- US3 depends on US1 (hobby list + reminder_time persistence).
- US4 is additive and should never gate US1–US3.

---

## Parallel Execution Examples

### US1 parallel opportunities

- [P] Implement shared date utility in lib/utils/date_utils.dart (T010)
- [P] Improve hobby create/edit UI in lib/screens/daily_tasks_screen.dart (T024, T030)
- [P] Improve persistence/service logic in lib/services/hobby_service.dart (T025, T027, T029)

### US3 parallel opportunities

- [P] Notification scheduling/cancel logic in lib/services/notification_service.dart (T040, T042, T043)
- [P] Telemetry gating in lib/services/analytics_service.dart and lib/services/crashlytics_service.dart (T047, T048)

---

## Implementation Strategy

- Start with US1: complete Phases 1–3 (US1) and stop to validate independently.
- Incremental: add US2 → US3 → US4, validating each story independently using the acceptance scenarios in specs/001-hobbyist/spec.md.

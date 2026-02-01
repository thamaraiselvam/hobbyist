# Feature Specification: Hobbyist

**Feature Branch**: `001-hobbyist`  
**Created**: 2026-02-01  
**Status**: Draft  
**Input**: User description: "Build a hobby tracking mobile app using the existing codebase as reference and following the project constitution"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable first increment that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Create hobbies and track daily completion (Priority: P1)

As a user, I want to create a small set of hobbies and mark them complete for today so that I can build daily consistency.

**Why this priority**: This is the core value of the product. Without daily tracking, everything else is secondary.

**Independent Test**: A fresh install can be completed end-to-end by creating one hobby, marking it complete for today, and confirming it stays complete after restarting the app.

**Acceptance Scenarios**:

1. **Given** a first-time user with no hobbies, **When** they choose offline mode and enter a display name or they choose optional sign-in and complete it, and then create a hobby with a name, **Then** the hobby appears in today’s list.
2. **Given** a hobby in today’s list, **When** the user marks it complete, **Then** the UI reflects completion immediately and the completion is recorded for today.
3. **Given** a completed hobby for today, **When** the user toggles it back to incomplete, **Then** today’s completion is removed and streak/progress reflects the change.
4. **Given** the user has hobbies and today’s completion state, **When** they close and reopen the app while offline, **Then** the same hobbies and completion states are shown.

---

### User Story 2 - Visualize progress with contribution history and streaks (Priority: P2)

As a user, I want to see a visual history of my consistency so that I stay motivated and can understand my patterns.

**Why this priority**: After tracking exists, progress visualization is the next biggest driver of motivation and retention.

**Independent Test**: After the user has completion history recorded across multiple distinct days, they can open Analytics and verify that the contribution-style history and streak metrics match the recorded completions.

**Acceptance Scenarios**:

1. **Given** the user has recorded completions across multiple days, **When** they open the analytics view, **Then** they see a calendar-style contribution history representing those days.
2. **Given** a specific hobby with recorded history, **When** the user views that hobby’s streak information, **Then** the current streak and best streak match the recorded daily completions.
3. **Given** a day with zero completions, **When** the analytics view renders that day, **Then** it is visually distinct from days with one or more completions.

---

### User Story 3 - Get reminders and manage preferences (Priority: P3)

As a user, I want reminders and simple preferences so that the app supports my habit without becoming noisy or annoying.

**Why this priority**: Reminders increase consistency, but must remain optional and respectful of user control.

**Independent Test**: A user can enable reminders, set a reminder time on a hobby, observe at least one reminder delivery, and disable reminders to stop future reminders.

**Acceptance Scenarios**:

1. **Given** notifications are disabled, **When** the user enables reminders, **Then** the app requests permission (when required) and explains what will be notified.
2. **Given** reminders are enabled, **When** the user sets or changes a reminder schedule for a hobby, **Then** future reminders follow the updated schedule.
3. **Given** reminders are enabled, **When** the user disables reminders globally, **Then** no further reminders are delivered.

---

### User Story 4 - Optional sign-in with offline-first behavior (Priority: P4)

As a user, I want the option to sign in or continue offline so that I can choose convenience without sacrificing privacy or offline usability.

**Why this priority**: This improves convenience for some users, but the product must remain fully usable without sign-in.

**Independent Test**: A user can complete onboarding in offline mode and use the full tracking experience, and a separate user can sign in and see their profile details without blocking core tracking.

**Acceptance Scenarios**:

1. **Given** the user does not want to sign in, **When** they choose offline mode, **Then** they can set a display name and immediately start using the app.
2. **Given** the user chooses to sign in, **When** sign-in completes successfully, **Then** the user is taken to the main dashboard without additional required steps.
3. **Given** the user cancels sign-in, **When** they return to the entry screen, **Then** they can still proceed offline.

---

### Edge Cases
- No hobbies exist: dashboard shows a helpful empty state with a clear next action.
- Duplicate hobby names: system allows duplicate hobby names; users can differentiate by notes, color, and priority.
- Rapid toggling: multiple quick completion toggles do not corrupt the final state for the day.
- Timezone/date boundary: a completion is recorded against the device’s local calendar date at the time the user toggles completion.
- Reminder permission denied: the app remains fully usable and provides guidance to re-enable permissions.
- Large hobby list: the main list remains usable and responsive with at least 50 hobbies.
- Delete hobby with history: the user is warned deletion removes its history; nothing is automatically deleted or archived by the system.
- Device offline: all core tracking works; sign-in-related actions degrade gracefully.

## Requirements *(mandatory)*

### Functional Requirements

Assumptions used to make this spec complete:
- The product is a personal habit tracker focused on daily consistency.
- The app supports iOS and Android.
- The default mode is offline-first with on-device storage.
- The UI includes a contribution-style history visualization.

- **FR-001**: System MUST allow a user to proceed in offline mode without creating an online account.
- **FR-002**: System MUST allow a user to set and edit a display name.
- **FR-003**: System MUST allow users to create a hobby with: name, optional notes/description, visual color, and a repeat mode (daily/weekly/monthly).
- **FR-004**: System MUST allow users to edit an existing hobby while preserving its completion history.
- **FR-005**: System MUST allow users to delete a hobby and its associated completion history only after explicit confirmation.
- **FR-006**: System MUST NOT automatically delete or archive hobbies/tasks or completion history (no auto-cleanup, no retention window).
- **FR-007**: System MUST present a “today” dashboard that lists active hobbies and clearly indicates completion status for the current day.
- **FR-008**: Users MUST be able to mark a hobby complete/incomplete for the current day.
- **FR-009**: System MUST persist hobby definitions, completion history, and user preferences across app restarts.
- **FR-010**: System MUST function for core tracking features without network connectivity (create/edit/delete hobbies, toggle completions, view history).
- **FR-011**: System MUST record completion timestamps and the calendar date associated with each completion.
- **FR-012**: System MUST provide a contribution-style history view that represents at least the last 12 weeks of activity.
- **FR-013**: System MUST visually distinguish days with 0 completions vs days with 1+ completions.
- **FR-014**: System MUST calculate and display, per hobby, a current streak and a best streak (no maximum cap / hard limit).
- **FR-015**: System MUST provide a settings area where the user can manage notification/reminder preferences and basic app preferences.
- **FR-016**: System MUST support optional reminders per hobby, including a user-selected reminder time.
- **FR-017**: System MUST provide a global control to enable/disable reminders and MUST respect the user’s choice immediately.
- **FR-018**: System MUST handle notification permissions gracefully: if denied, it MUST not block core app usage and MUST provide a clear path to enable later.
- **FR-019**: System MUST provide clear, non-technical error messaging for user-facing failures (e.g., save failed, permission denied).
- **FR-020**: System MUST protect user privacy by default: hobby and completion data MUST remain on-device unless the user explicitly opts into cloud features.
- **FR-021**: If sign-in is offered, it MUST be optional and MUST not block offline-first usage.
- **FR-022**: Telemetry collection (Firebase Analytics, Crashlytics, Performance) is ENABLED by default as no PII is collected. Users MAY opt-out via settings, and the change MUST take effect immediately when toggled.
- **FR-023**: System MUST provide a clear disclosure UI describing what telemetry is collected and what is not collected (no hobby names/notes/history; no user email in analytics).

### Key Entities *(include if feature involves data)*

- **UserProfile**: Represents the user’s display identity and chosen mode (offline vs signed-in), plus user-visible profile attributes.
- **Hobby**: Represents a tracked habit (name, optional notes, color, repeat mode, priority).
- **Completion**: Represents whether a hobby was completed on a given calendar day, including the completion timestamp.
- **Reminder**: Represents a per-hobby reminder schedule and whether it is enabled.
- **Preferences**: Represents global user preferences (e.g., reminders enabled, sound/vibration enabled, reduced motion).
- **Quote**: Represents a short motivational message shown on the dashboard.

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: New users can complete onboarding and record their first completion in under 2 minutes.
- **SC-002**: Users can create a new hobby in under 60 seconds (name + optional details) without needing a network connection.
- **SC-003**: 95% of “mark complete” actions visibly confirm completion in under 0.3 seconds on a mid-range device.
- **SC-004**: 99%+ of user sessions are crash-free over a rolling 7-day period after release.
- **SC-005**: 90% of users can successfully interpret their contribution history and find their current streak without instructions (measured via a usability test).
- **SC-006**: 0 instances of hobby/completion data being transmitted off-device without explicit user opt-in (validated via privacy review and telemetry inspection).

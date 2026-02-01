# Implementation Plan: Hobbyist

**Branch**: `001-hobbyist` | **Date**: 2026-02-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-hobbyist/spec.md`

## Summary

Deliver an offline-first hobby tracking mobile app where users can create hobbies, mark daily completion, and view streaks + a contribution-style history. Persist data locally in SQLite, support optional Google sign-in, and provide optional reminders; use Firebase services for analytics/crash reporting/performance/remote configuration while remaining privacy-first.

## Technical Context

**Language/Version**: Flutter (Dart SDK `>=3.0.0 <4.0.0`)  
**Primary Dependencies**: `sqflite`, `flutter_local_notifications`, `timezone`, `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`, `firebase_remote_config`, `firebase_auth`, `google_sign_in`, `shared_preferences`, `intl`, `audioplayers`  
**Storage**: SQLite (`hobbyist.db`) via `sqflite` with DB schema version 3; limited onboarding/auth flags in `shared_preferences`  
**Testing**: `flutter_test`, `integration_test`, `sqflite_common_ffi`  
**Target Platform**: iOS + Android (Android: `minSdkVersion 23`, `targetSdkVersion 36`; iOS: Flutter runner, app supports iOS 12+)  
**Project Type**: Mobile (Flutter)  
**Performance Goals**: 60 FPS interactions, cold start < 2s mid-range device, DB queries < 100ms typical case  
**Constraints**: Offline-capable core flows, privacy-by-default (local data), telemetry enabled by default (opt-out available, no PII collected), minimal UI jank, non-blocking permission flows, no automatic deletion/archival, unlimited streaks  
**Scale/Scope**: Single-user local app; hobby list target limit 50 (Remote Config default)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Minimalism & Purpose**: PASS — scope maps to core habit tracking flows already in repo; no additional dependencies introduced.
- **II. Test-First (Non-negotiable)**: PASS (process) — implementation must add/adjust unit + integration tests for DB/services and critical flows; no feature work without tests.
- **III. Performance as a Feature**: PASS — DB indexes exist; `PerformanceService` traces DB queries; avoid expensive rebuilds/jank.
- **IV. Privacy by Default**: PASS WITH ACTION — hobby/completion data remains local SQLite; Firebase usage must be transparent and user-controllable (see research/design decisions).
- **V. Accessibility & Inclusivity**: PASS (requires verification) — ensure interactive controls have semantics labels and respect reduced motion.
- **VI. Code Quality & Architecture**: PASS — current structure follows `lib/models`, `lib/services`, `lib/screens`, `lib/widgets`, `lib/database`, `lib/utils`.
- **VII. Versioning & Release Discipline**: PASS — semantic versioning already in `pubspec.yaml`; quality gates apply.

### Post-Design Re-check (after Phase 0/1 artifacts)

- Privacy-by-default alignment is explicitly documented in [research.md](research.md) and reinforced by contracts that exclude PII (see [contracts/analytics-events.md](contracts/analytics-events.md)).
- Data model is consistent with the implemented schema and upgrade path (see [data-model.md](data-model.md) and [contracts/sqlite-schema.sql](contracts/sqlite-schema.sql)).
- Remaining constitution mismatches are captured as explicit, justified exceptions in this plan (Firebase opt-in expectations).

## Project Structure

### Documentation (this feature)

```text
specs/001-hobbyist/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md             # Created by /speckit.tasks (not by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── firebase_options.dart
├── database/
│   └── database_helper.dart
├── models/
│   └── hobby.dart
├── screens/
│   ├── splash_screen.dart
│   ├── landing_screen.dart
│   ├── name_input_screen.dart
│   ├── daily_tasks_screen.dart
│   ├── analytics_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── hobby_service.dart
│   ├── notification_service.dart
│   ├── auth_service.dart
│   ├── analytics_service.dart
│   ├── crashlytics_service.dart
│   ├── performance_service.dart
│   └── remote_config_service.dart
└── widgets/

test/
integration_test/
android/
ios/
assets/
docs/
```

**Structure Decision**: Single Flutter mobile app. No separate backend/API project; “contracts” for this plan capture local DB schema + telemetry/event contracts.

## Complexity Tracking

> Filled because Constitution Check has justified violations or required policy work

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Firebase “optional” vs initialized at startup | Current app initializes Firebase services on launch; constitution expects optional + transparent data collection | “No Firebase at all” conflicts with existing analytics/crash/perf integration and remote flags; instead implement clear disclosure + opt-out/consent gating |

Additional planned functional deltas from current implementation:
- Remove any max streak cap logic; streak calculations are unbounded.
- Ensure there is no automatic deletion/archival (no retention window, no background cleanup jobs).
- Add explicit opt-in gating for telemetry (Analytics/Crashlytics/Performance) with clear disclosure UI.
- Provide consistent, non-technical error messaging for key user-facing failures.

Planned refactor for consistency:
- Introduce a shared local-date helper (e.g., `lib/utils/date_utils.dart`) as the single source of truth for `YYYY-MM-DD` completion dates.

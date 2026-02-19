<!--
SYNC IMPACT REPORT
==================
Version: 1.0.0 → 2.0.0
Bump Rationale: MAJOR version - Raise Android minimum supported SDK to match the implemented build requirements

Modified Principles: Platform Standards (Android Min SDK)
Added Sections: N/A
Removed Sections: N/A

Templates Status:
✅ plan-template.md - Verified compatible (existing constitution checks apply)
✅ spec-template.md - Verified compatible (user story prioritization aligns)
✅ tasks-template.md - Verified compatible (task organization supports principles)

Follow-up TODOs:
- Define project ownership roles (Project Owner, Lead Developer) in Appendix B
- Consider establishing Architecture Decision Records (ADR) process
-->

# Hobbyist Constitution

**Platform**: Flutter (iOS & Android)

## Core Principles

### I. Minimalism & Purpose-Driven Development
Every feature MUST serve a clear, documented purpose. Features without demonstrable user value MUST be rejected. This applies to:
- UI components (no decorative elements without functional purpose)
- Dependencies (justify every package added to `pubspec.yaml`)
- Code complexity (prefer simple solutions; complexity requires written justification)

**Rationale**: Feature bloat degrades app performance, increases maintenance burden, and confuses users. Disciplined minimalism ensures the app remains fast, maintainable, and focused on its core mission: habit tracking.

### II. Test-First Development (NON-NEGOTIABLE)
Test-Driven Development (TDD) is MANDATORY for all business logic and critical paths:
- Tests MUST be written before implementation
- Tests MUST fail initially (red phase)
- Implementation proceeds only after test failures are confirmed
- Minimum 80% code coverage; 100% for database operations, models, and core services

**Rationale**: TDD ensures correctness, prevents regressions, and serves as living documentation. The SQLite database and habit tracking logic are too critical to develop without tests.

### III. Performance as a Feature
Performance targets are NON-NEGOTIABLE quality gates:
- Cold start < 2 seconds on 3-year-old mid-range devices
- All UI interactions maintain 60 FPS (no jank)
- Database queries complete in < 100ms
- Screen transitions < 300ms
- Memory usage < 150MB at idle

**Rationale**: A sluggish app discourages daily use, undermining the core habit-building purpose. Performance requirements ensure the app feels instant and rewarding.

### IV. Privacy by Default
User data MUST remain on-device by default:
- SQLite is the primary data store (not Firebase)
- Firebase features MUST be optional and transparent
- GDPR/CCPA compliance for all data handling

**Rationale**: Users entrust the app with personal habit data. Privacy-first design builds trust and ensures the app can function fully offline.

### V. Accessibility & Inclusivity
Accessibility is a first-class requirement, not an afterthought:
- All interactive elements MUST have semantic labels
- WCAG AA color contrast compliance (4.5:1 text, 3:1 UI)
- Full TalkBack/VoiceOver support
- Support dynamic text sizing up to 200%
- Respect `MediaQuery.disableAnimations`

**Rationale**: Habit tracking should be accessible to everyone, regardless of abilities. Designing for accessibility improves the experience for all users.

### VI. Code Quality & Architecture
Architecture standards are enforced to maintain long-term codebase health:
- **Separation of Concerns**: `models/`, `services/`, `screens/`, `widgets/`, `database/`, `utils/` structure strictly enforced
- **Single Responsibility**: Each class/function does one thing well
- **Null Safety**: Full null safety; no nullable types without written justification
- **File Size Limit**: 400 lines maximum per file
- **Zero Warnings**: `flutter analyze` must produce zero warnings before any commit

**Rationale**: Consistent architecture enables team scalability, reduces cognitive load, and prevents the codebase from becoming unmaintainable.

### VII. Semantic Versioning & Release Discipline
Version management follows strict semantic versioning (`MAJOR.MINOR.PATCH+BUILD`):
- **MAJOR**: Breaking changes or feature removals (2-version deprecation notice required)
- **MINOR**: New features or significant enhancements
- **PATCH**: Bug fixes, performance improvements, minor refinements
- Release quality gates MUST pass: tests, coverage ≥80%, zero analyzer warnings, manual QA

**Rationale**: Predictable versioning communicates impact to users and enables safe upgrade planning.

## Development Standards

### Code Quality Gates
All code submissions MUST meet these requirements:
- Pass `flutter analyze` with zero warnings
- All tests pass (`flutter test --coverage`)
- Code coverage ≥ 80% (100% for `database/`, `models/`, core services)
- Follow linting rules: `prefer_const_constructors`, `avoid_print`, `prefer_single_quotes`
- Include dartdoc comments for all public APIs
- No hardcoded strings or magic numbers

### Testing Requirements
**Unit Tests**: All business logic in `services/` MUST have unit tests
**Widget Tests**: All custom widgets in `widgets/` MUST have widget tests
**Test Organization**: Follow structure in `test/unit/`, `test/widget/`
**Test Naming**: `test('should [expected behavior] when [condition]', () {})`

### Platform Standards
**Android**:
- Min SDK: API 23 (Marshmallow 6.0)
- Target SDK: Latest stable
- Material Design 3 compliance
- R8 optimization enabled for release builds

**iOS**:
- Min Version: iOS 12.0
- Target: Latest stable
- Apple Human Interface Guidelines compliance
- Proper code signing

## Security & Privacy

### Data Security
- Use secure storage for sensitive data
- API keys NEVER committed to source control
- Parameterized SQL queries (sqflite default)
- Input validation for all user inputs
- Code obfuscation enabled for release builds

### Firebase Security
- All Firebase features MUST be optional
- Clear disclosure of data collection practices
- Minimal analytics data collection (only essential events)
- Firebase Auth for secure authentication (Google Sign-In)
- Environment-specific configuration (dev/staging/production)

## Performance & Monitoring

### Performance Budgets
These budgets are enforced via monitoring and profiling:
- APK size < 30MB (release build)
- Memory leaks prevented (dispose all controllers/subscriptions)
- Battery usage profiled and minimized
- Database operations use indexes for frequently queried columns

### Monitoring Requirements
- Firebase Crashlytics: Crash-free rate ≥ 99.5%
- ANR rate < 0.1%
- Performance monitoring for app start time and screen rendering
- Custom logs for debugging (breadcrumbs for crashes)

## Governance

### Constitution Authority
This constitution supersedes all other development practices. In case of conflict between this document and other guidelines, the constitution prevails.

### Amendment Process
1. Propose changes with written rationale
2. Team consensus required for approval
3. Version bump according to semantic versioning rules
4. Update all dependent templates and documentation
5. Document changes in Sync Impact Report

### Compliance Review
- All pull requests MUST be verified against constitution requirements
- Code reviews MUST check for principle adherence
- Quarterly constitution review to assess relevance and effectiveness
- Complexity violations MUST be documented and justified in writing

### Exception Process
Temporary exceptions to principles require:
- Written documentation and justification
- Lead developer approval
- Remediation plan with timeline
- Documentation in pull request description

**Version**: 2.0.0 | **Ratified**: 2026-02-01 | **Last Amended**: 2026-02-01

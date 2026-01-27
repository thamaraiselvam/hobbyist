# Test Suite Documentation

This test suite provides comprehensive unit, widget, and integration tests for the Hobby Tracker application.

## Test Structure

```
test/
├── unit/
│   ├── models/
│   │   └── hobby_test.dart           # Hobby model tests
│   └── services/
│       └── hobby_service_test.dart   # HobbyService tests
├── widget/
│   ├── splash_screen_test.dart       # SplashScreen widget tests
│   ├── landing_screen_test.dart      # LandingScreen widget tests
│   ├── name_input_screen_test.dart   # NameInputScreen widget tests
│   ├── add_hobby_screen_test.dart    # AddHobbyScreen widget tests
│   └── settings_screen_test.dart     # SettingsScreen widget tests
└── integration/
    └── app_flow_test.dart             # Full app integration tests
```

## Test Coverage

### Unit Tests

#### Hobby Model Tests (`hobby_test.dart`)
- ✅ Create hobby with default values
- ✅ Create hobby with custom values
- ✅ Calculate current streak correctly
- ✅ Handle streak edge cases (no completions, single day, etc.)
- ✅ JSON serialization/deserialization
- ✅ Copy with new values
- ✅ HobbyCompletion model tests

#### HobbyService Tests (`hobby_service_test.dart`)
- ✅ Add and load hobby
- ✅ Update hobby
- ✅ Delete hobby
- ✅ Toggle completion
- ✅ Save and get settings
- ✅ Handle non-existent settings

### Widget Tests

#### SplashScreen Tests (`splash_screen_test.dart`)
- ✅ Display splash screen
- ✅ Navigate to landing screen when not onboarded
- ✅ Navigate to dashboard when onboarded
- ✅ Fade animation

#### LandingScreen Tests (`landing_screen_test.dart`)
- ✅ Display landing screen content
- ✅ Get Started button interaction
- ✅ Navigation flow
- ✅ Hero image display
- ✅ Correct styling

#### NameInputScreen Tests (`name_input_screen_test.dart`)
- ✅ Display name input screen
- ✅ Button enabled/disabled states
- ✅ Whitespace validation
- ✅ Input field properties (hint, capitalization, autofocus)

#### AddHobbyScreen Tests (`add_hobby_screen_test.dart`)
- ✅ Display add hobby form
- ✅ Save button enabled/disabled states
- ✅ Repeat mode options
- ✅ Priority options
- ✅ Color selection
- ✅ Navigation (back button)

#### SettingsScreen Tests (`settings_screen_test.dart`)
- ✅ Display settings screen
- ✅ User name section
- ✅ Clear data option with confirmation
- ✅ Version information
- ✅ Bottom navigation
- ✅ Navigation callbacks

### Integration Tests

#### App Flow Tests (`app_flow_test.dart`)
- ✅ Complete onboarding flow
- ✅ Skip onboarding for returning users
- ✅ Navigate between tabs
- ✅ Add new hobby flow
- ✅ Complete hobby task flow
- ✅ View analytics with/without data
- ✅ Change analytics period
- ✅ Settings navigation
- ✅ Pull to refresh

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suite
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests only
flutter test test/integration/
```

### Run Specific Test File
```bash
flutter test test/unit/models/hobby_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Generate HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Dependencies

The following packages are required for testing:
- `flutter_test`: Flutter testing framework
- `sqflite_common_ffi`: FFI implementation for testing SQLite
- `shared_preferences`: Mock support for SharedPreferences

## Test Patterns

### Widget Tests
- Use `pumpWidget` to render widgets
- Use `pumpAndSettle` for animations
- Use `find` to locate widgets
- Test user interactions with `tap`, `enterText`, etc.

### Integration Tests
- Test complete user flows
- Verify navigation between screens
- Test data persistence
- Verify UI updates after actions

## Notes

- Developer settings screen tests are excluded as requested
- All tests use mock data and don't affect production database
- Tests are isolated and can run in any order
- SharedPreferences is mocked for all tests

## CI/CD Integration

These tests can be integrated into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: flutter test
  
- name: Check Coverage
  run: |
    flutter test --coverage
    lcov --list coverage/lcov.info
```

## Troubleshooting

### Tests fail with database errors
Ensure `sqflite_common_ffi` is properly initialized in test setup:
```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});
```

### Widget tests timeout
Increase timeout or use `pumpAndSettle` with explicit duration:
```dart
await tester.pumpAndSettle(const Duration(milliseconds: 3000));
```

### Shared Preferences errors
Ensure mock initialization in setUp:
```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

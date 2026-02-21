# Maestro E2E Tests for Hobbyist

This directory contains end-to-end tests for the Hobbyist Flutter app using Maestro.

## Overview

Maestro is a mobile test automation framework that enables reliable E2E testing without flakiness. All tests in this directory follow Hobbyist's critical user journeys.

## Test Files

### Critical Journey Tests

1. **onboarding.yml** - Onboarding Flow
   - Splash screen → Landing screen → Name input → Dashboard
   - Tests: App launch, button taps, form input, navigation
   - Duration: ~15 seconds

2. **add_hobby.yml** - Add Hobby Workflow
   - Dashboard → Add Hobby modal → Form completion → Save
   - Tests: FAB tap, form filling, frequency selection, color picker, notifications
   - Duration: ~20 seconds

3. **complete_hobby.yml** - Hobby Completion Flow
   - Dashboard → Find hobby → Mark complete → Verify state
   - Tests: Checkbox tap, animation, state change, accessibility
   - Duration: ~10 seconds

4. **view_analytics.yml** - Analytics Navigation
   - Dashboard → Analytics screen → View charts and metrics
   - Tests: Bottom nav, period selection, chart rendering
   - Duration: ~20 seconds

5. **settings_feedback.yml** - Settings and Feedback
   - Dashboard → Settings → Feedback → Submit feedback
   - Tests: Toggle switches, form submission, navigation
   - Duration: ~25 seconds

## Setup Instructions

### Prerequisites

1. **Install Maestro**
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   export PATH="$PATH:$HOME/.maestro/bin"
   ```

2. **iOS Simulator or Android Emulator**
   ```bash
   # iOS
   open -a Simulator

   # Android
   emulator -avd Pixel_6_API_31
   ```

3. **Build Debug APK/App**
   ```bash
   flutter build apk --debug
   # or for iOS
   flutter build ios
   ```

### Running Tests

**Run all tests:**
```bash
maestro test maestro-tests/
```

**Run specific test:**
```bash
maestro test maestro-tests/onboarding.yml
```

**Run with verbose output:**
```bash
maestro test --verbose maestro-tests/onboarding.yml
```

**Run with custom timeout:**
```bash
maestro test --timeout=300 maestro-tests/onboarding.yml
```

## Configuration

### App ID
```yaml
appId: com.example.hobbyist
```

Change this to match your app's package name:
- **Android**: Check `android/app/build.gradle`
- **iOS**: Check `ios/Runner.xcodeproj`

## Test ID Requirements

### Critical Widgets That Need Keys

All tests depend on Flutter widgets having `Key` identifiers. See `test_id_mapping.md` for complete list.

**Quick start - add to main widgets:**

```dart
// Landing Screen
ElevatedButton(
  key: const Key('continue_offline_button'),
  onPressed: () { ... },
  child: const Text('Continue Offline'),
)

// Name Input Screen
TextField(
  key: const Key('name_input_field'),
  controller: _nameController,
  ...
)

// Add Hobby FAB
FloatingActionButton(
  key: const Key('add_hobby_fab'),
  onPressed: () { ... },
)
```

## Maestro YAML Syntax

### Common Actions

```yaml
# Tap an element by ID
- tapOn:
    id: button_id
    timeout: 3000

# Tap by text
- tapOn:
    text: "Button Text"

# Input text
- inputText: "My text here"

# Assert element is visible
- assertVisible:
    id: element_id
    timeout: 5000

# Wait for animations
- waitForAnimationToSettle:
    timeout: 500

# Swipe
- swipe:
    direction: UP
    duration: 500

# Launch app fresh
- launchApp:
    clearState: true
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  maestro:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-java@v3
        with:
          java-version: '11'

      - uses: actions/setup-ruby@v1
        with:
          ruby-version: '2.7'

      - run: curl -Ls "https://get.maestro.mobile.dev" | bash

      - run: flutter build apk --debug

      - run: |
          $HOME/.maestro/bin/maestro test maestro-tests/ \
            --format junit \
            --output-dir test-results

      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: maestro-results
          path: test-results
```

## Debugging Failed Tests

### Check Maestro Logs
```bash
maestro test --verbose --headless-pause maestro-tests/onboarding.yml
```

### Common Issues

1. **"Element not found"**
   - Verify the `id` in YAML matches Flutter `Key`
   - Check that animations have settled before asserting
   - Add longer timeout if element takes time to appear

2. **"Timeout waiting for animation"**
   - Increase timeout in YAML
   - Add explicit `waitForAnimationToSettle` after actions

3. **"App keeps crashing"**
   - Check emulator/device has enough resources
   - Rebuild app: `flutter clean && flutter pub get && flutter build apk --debug`
   - Check device logs: `adb logcat` or `xcrun simctl log`

4. **Test passes locally but fails in CI**
   - CI may have slower devices - increase timeouts
   - Some animations may be disabled in headless mode - add explicit waits
   - Device state may differ - use `clearState: true` in launch

## Test Results Format

Maestro outputs test results in JUnit XML format. Parse these with:
- GitHub Actions: `junit-report-action`
- GitLab CI: Built-in JUnit support
- Jenkins: JUnit plugin

## Best Practices

1. **Keep tests independent** - Each test should work in isolation
2. **Use reasonable timeouts** - 3-5 seconds for typical actions
3. **Wait for animations** - Maestro is smart but add explicit waits for custom animations
4. **Name keys clearly** - Use snake_case, describe the element
5. **Test critical paths only** - Don't test every button, focus on user journeys
6. **Mock external services** - Tests should work offline
7. **Verify success states** - Always assert expected outcome

## Advanced Features

### Running Tests in Headless Mode
```bash
maestro test --headless maestro-tests/onboarding.yml
```

### Screenshots on Failure
Maestro automatically captures screenshots when tests fail. Find them in:
- Local: `./maestro-screenshots/`
- CI: Check artifacts

### Custom Flows
Reuse common flows with `runFlow`:
```yaml
- runFlow: maestro-tests/flows/common_setup.yml
```

### Device Selection
```bash
maestro test --device ios maestro-tests/onboarding.yml
maestro test --device android maestro-tests/onboarding.yml
```

## Documentation

- [Maestro Official Docs](https://maestro.mobile.dev/)
- [YAML Syntax Guide](https://maestro.mobile.dev/cli/yaml-reference)
- [Troubleshooting](https://maestro.mobile.dev/cli/troubleshooting)

## Support

For issues with:
- **Test IDs**: See `test_id_mapping.md`
- **Maestro Syntax**: Check YAML files for examples
- **Flutter Keys**: See Flutter documentation


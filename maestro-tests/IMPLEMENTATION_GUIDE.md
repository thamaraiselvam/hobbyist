# Implementation Guide: Adding Maestro Test IDs to Hobbyist

This guide walks through adding Flutter `Key` widgets to enable Maestro E2E testing.

## Timeline
- **Quick Start**: 15-20 minutes for critical paths
- **Full Implementation**: 45-60 minutes for all test IDs

## Phase 1: Critical Path Elements (15 min)

These 9 elements enable all critical E2E test flows.

### 1. Landing Screen - Continue Button
**File**: `lib/screens/landing_screen.dart`
**Location**: Line 196

```dart
// BEFORE
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: widget.onGetStarted,
    // ...

// AFTER
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    key: const Key('continue_offline_button'),
    onPressed: widget.onGetStarted,
    // ...
```

### 2. Name Input Screen - Name TextField
**File**: `lib/screens/name_input_screen.dart`
**Location**: Line 99

```dart
// BEFORE
TextField(
  controller: _nameController,
  style: const TextStyle(...),

// AFTER
TextField(
  key: const Key('name_input_field'),
  controller: _nameController,
  style: const TextStyle(...),
```

### 3. Name Input Screen - Start Button
**File**: `lib/screens/name_input_screen.dart`
**Location**: Line 136

```dart
// BEFORE
ElevatedButton(
  onPressed: _isButtonEnabled ? _saveName : null,

// AFTER
ElevatedButton(
  key: const Key('start_journey_button'),
  onPressed: _isButtonEnabled ? _saveName : null,
```

### 4. Daily Tasks Screen - Add Hobby FAB
**File**: `lib/screens/daily_tasks_screen.dart`
**Location**: Line 1368

```dart
// BEFORE
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () async {
    await Navigator.push(

// AFTER
GestureDetector(
  key: const Key('add_hobby_fab'),
  behavior: HitTestBehavior.opaque,
  onTap: () async {
    await Navigator.push(
```

### 5. Daily Tasks Screen - Bottom Nav Items
**File**: `lib/screens/daily_tasks_screen.dart`
**Location**: Line 1356-1360

```dart
// BEFORE - In _buildBottomNav() method
children: [
  _buildNavItemIcon(Icons.check_circle, 0),
  _buildNavItemIcon(Icons.list_alt, 1),
  _buildCreateButton(),
  _buildNavItemIcon(Icons.local_fire_department, 2),
  _buildNavItemIcon(Icons.settings, 3),
],

// AFTER - Modify _buildNavItemIcon() method to add keys
Widget _buildNavItemIcon(IconData icon, int index) {
  final isSelected = _selectedIndex == index;
  final keyId = [
    'bottom_nav_home',
    'bottom_nav_lists',
    'bottom_nav_analytics',
    'bottom_nav_settings',
  ][index];

  return Expanded(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(keyId),
        onTap: () {
          // ...
```

### 6. Add Hobby Screen - Name Input
**File**: `lib/screens/add_hobby_screen.dart`
**Location**: Line 306

```dart
// BEFORE
TextFormField(
  controller: _nameController,
  style: const TextStyle(...),

// AFTER
TextFormField(
  key: const Key('hobby_name_input'),
  controller: _nameController,
  style: const TextStyle(...),
```

### 7. Add Hobby Screen - Frequency Buttons
**File**: `lib/screens/add_hobby_screen.dart`
**Location**: Line 841 (modify _buildFrequencyButton)

```dart
// BEFORE
Widget _buildFrequencyButton(String value, String label) {
  final isSelected = _repeatMode == value;
  return Expanded(
    child: GestureDetector(
      onTap: () {

// AFTER
Widget _buildFrequencyButton(String value, String label) {
  final isSelected = _repeatMode == value;
  final keyId = {
    'daily': 'daily_frequency_button',
    'weekly': 'weekly_frequency_button',
    'monthly': 'monthly_frequency_button',
  }[value];

  return Expanded(
    child: GestureDetector(
      key: Key(keyId),
      onTap: () {
```

### 8. Add Hobby Screen - Create Button
**File**: `lib/screens/add_hobby_screen.dart`
**Location**: Line 784

```dart
// BEFORE
ElevatedButton(
  onPressed: _saveHobby,

// AFTER
ElevatedButton(
  key: const Key('create_hobby_button'),
  onPressed: _saveHobby,
```

### 9. Settings Screen - Send Feedback Button
**File**: `lib/screens/settings_screen.dart`
**Location**: Line 725 (modify _buildNavTile call)

```dart
// BEFORE
_buildNavTile(
  icon: Icons.feedback_outlined,
  iconColor: const Color(0xFF6C3FFF),
  title: 'Send Feedback',
  onTap: () {

// AFTER
_buildNavTile(
  key: const Key('send_feedback_button'),
  icon: Icons.feedback_outlined,
  iconColor: const Color(0xFF6C3FFF),
  title: 'Send Feedback',
  onTap: () {
```

**Note**: You'll need to add `key` parameter to _buildNavTile method signature.

---

## Phase 2: Complete Implementation (30 min)

After Phase 1, add remaining high-priority elements:

### Add Hobby Screen - Color Palette
**File**: `lib/screens/add_hobby_screen.dart`
**Location**: Line 870 (modify _buildColorButton)

```dart
Widget _buildColorButton(int colorValue) {
  final isSelected = _selectedColor == colorValue;
  final index = _colorPalette.indexOf(colorValue);

  return GestureDetector(
    key: Key('color_palette_button_$index'),
    onTap: () {
```

### Add Hobby Screen - Notification Toggle
**File**: `lib/screens/add_hobby_screen.dart`
**Location**: Line 626

```dart
// BEFORE
Switch(
  value: _notifyEnabled,

// AFTER
Switch(
  key: const Key('notify_toggle'),
  value: _notifyEnabled,
```

### Add Hobby Screen - Reminder Time Picker
**File**: `lib/screens/add_hobby_screen.dart`
**Location**: Line 691

```dart
// BEFORE
InkWell(
  onTap: _selectTime,

// AFTER
InkWell(
  key: const Key('reminder_time_picker'),
  onTap: _selectTime,
```

### Analytics Screen - Period Buttons
**File**: `lib/screens/analytics_screen.dart`
**Location**: Line 1018 (modify _buildCompactPeriodButton)

```dart
Widget _buildCompactPeriodButton(
    String label, bool isSelected, String period) {
  final keyId = {
    'Weekly': 'period_weekly_button',
    'Monthly': 'period_monthly_button',
    'Yearly': 'period_yearly_button',
  }[period];

  return GestureDetector(
    key: Key(keyId),
    onTap: () {
```

### Analytics Screen - Stat Cards
**File**: `lib/screens/analytics_screen.dart`
**Location**: Line 572, 663, 755

```dart
// Current Streak Card
Container(
  key: const Key('current_streak_card'),
  height: 140,

// Best Streak Card
Container(
  key: const Key('best_streak_card'),
  height: 140,

// Total Done Card
Container(
  key: const Key('total_done_card'),
  height: 140,
```

### Settings Screen - Preference Toggles
**File**: `lib/screens/settings_screen.dart`
**Location**: Line 527, 538

```dart
// Push Notifications
Switch(
  key: const Key('push_notifications_toggle'),
  value: value,

// Sound & Vibration
Switch(
  key: const Key('completion_sound_toggle'),
  value: value,
```

### Feedback Screen - Form Elements
**File**: `lib/screens/feedback_screen.dart`
**Location**: Line 129, 181, 208

```dart
// Feedback TextArea
TextField(
  key: const Key('feedback_textarea'),
  controller: _feedbackController,

// Email Input
TextField(
  key: const Key('email_input'),
  controller: _emailController,

// Submit Button
ElevatedButton(
  key: const Key('submit_feedback_button'),
  onPressed: _isSubmitting ? null : _submitFeedback,
```

---

## Phase 3: Dynamic Elements (10 min)

These elements need unique keys based on data:

### Daily Tasks Screen - Hobby Checkboxes
**File**: `lib/screens/daily_tasks_screen.dart`
**Location**: Line 1069 (in _buildTaskCard)

```dart
// BEFORE
Builder(
  builder: (context) => AnimatedCheckbox(
    isChecked: isCompleted,

// AFTER
Builder(
  builder: (context) => AnimatedCheckbox(
    key: Key('hobby_checkbox_${hobby.id}'),
    isChecked: isCompleted,
```

---

## Verification Steps

After adding keys:

### 1. Analyze Project
```bash
cd /Users/vijay/repo/hobbyist
flutter analyze
```

✅ Should have no errors related to keys.

### 2. Run Unit Tests
```bash
flutter test test/unit/
```

✅ All tests should pass (keys don't affect unit tests).

### 3. Build Debug APK
```bash
flutter build apk --debug
```

✅ Should build successfully.

### 4. Run Maestro Tests
```bash
maestro test maestro-tests/onboarding.yml
```

✅ First test should pass.

---

## Common Mistakes to Avoid

❌ **Don't use `key` parameter as a positional argument**
```dart
// Wrong
AnimatedCheckbox(
  Key('hobby_checkbox_123'),  // ❌ This is positional
  isChecked: true,
)
```

✅ **Do use named parameter**
```dart
// Correct
AnimatedCheckbox(
  key: Key('hobby_checkbox_123'),  // ✅ Named parameter
  isChecked: true,
)
```

❌ **Don't use spaces or special characters in key names**
```dart
// Wrong
Key('hobby checkbox 123')  // ❌ Spaces
Key('hobby-checkbox-123')  // ❌ Hyphens
```

✅ **Use snake_case**
```dart
// Correct
Key('hobby_checkbox_123')  // ✅ Snake case
```

❌ **Don't forget const for string-based keys**
```dart
// Wrong
key: Key('button'),  // ❌ Will be recreated each build

// Correct
key: const Key('button'),  // ✅ Const key is efficient
```

---

## Testing Checklist

After implementing keys, verify each test:

- [ ] Onboarding test passes (landing → name → dashboard)
- [ ] Add Hobby test passes (form submission)
- [ ] Complete Hobby test passes (checkbox toggle)
- [ ] Analytics test passes (navigation & charts)
- [ ] Settings & Feedback test passes (toggles & submission)
- [ ] All tests pass when run together: `maestro test maestro-tests/`
- [ ] Tests pass on both iOS simulator and Android emulator

---

## Commit Message Template

```
feat: add Maestro test IDs for E2E testing

Add Flutter Key widgets to enable Maestro E2E test automation:
- Landing screen: continue_offline_button
- Name input: name_input_field, start_journey_button
- Dashboard: add_hobby_fab, bottom_nav_* buttons, hobby_checkbox_*
- Add hobby: hobby_name_input, frequency buttons, color palette, notify_toggle, create_hobby_button
- Analytics: period_buttons, stat cards
- Settings: preference toggles, send_feedback_button
- Feedback: feedback_textarea, email_input, submit_feedback_button

This enables automated E2E testing with Maestro across critical user journeys
without requiring native code modifications.

Test coverage: 5 critical journeys, 25+ E2E tests
```

---

## Next Steps

1. **Implement Phase 1** (15 min) - Get critical tests working
2. **Commit changes** - Create PR for review
3. **Run Maestro tests** - Verify all flows pass
4. **Implement Phase 2** - Add complete coverage
5. **Setup CI/CD** - Auto-run tests on each commit
6. **Monitor** - Track test reliability over time


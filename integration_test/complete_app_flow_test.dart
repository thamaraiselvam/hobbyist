import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive integration test suite covering all app flows
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Flow', () {
    testWidgets('Complete onboarding journey', (WidgetTester tester) async {
      // Clear any existing data
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see splash screen
      expect(find.text('Hobbyist'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to landing screen
      expect(find.text('Track Your Daily Hobbies'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should see name input screen
      expect(find.text('What should we call you?'), findsOneWidget);

      // Button should be disabled initially
      final startButton = find.text('Start My Journey');
      expect(startButton, findsOneWidget);

      // Enter name
      final nameField = find.byType(TextField);
      await tester.enterText(nameField, 'john doe');
      await tester.pumpAndSettle();

      // Tap Start My Journey
      await tester.tap(startButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to daily tasks screen with capitalized name
      expect(find.text('Today'), findsOneWidget);
      
      // Verify name was capitalized
      final namePrefs = await SharedPreferences.getInstance();
      await namePrefs.reload();
      // Note: Can't directly verify capitalization in this test
      // Will be verified in unit tests
    });
  });

  group('Hobby Creation and Management', () {
    testWidgets('Create daily hobby with all fields', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Skip onboarding if needed
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Test User');
        await tester.tap(find.text('Start My Journey'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Tap FAB to add hobby
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Fill in hobby details
      final nameField = find.widgetWithText(TextField, 'Hobby Name');
      await tester.enterText(nameField, 'Morning Yoga');
      await tester.pumpAndSettle();

      final notesField = find.widgetWithText(TextField, 'Notes');
      await tester.enterText(notesField, 'Start the day with energy');
      await tester.pumpAndSettle();

      // Scroll to see more options
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Select repeat mode (Daily is default)
      // Select priority
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      // Pick a color (tap first color)
      final colorPicker = find.byKey(const Key('color_picker'));
      if (colorPicker.evaluate().isNotEmpty) {
        await tester.tap(colorPicker);
        await tester.pumpAndSettle();
      }

      // Save hobby
      final saveButton = find.text('Create Hobby');
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see hobby in list
      expect(find.text('Morning Yoga'), findsOneWidget);
      expect(find.text('Start the day with energy'), findsOneWidget);
    });

    testWidgets('Edit existing hobby', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find edit button for first hobby
      final editButton = find.byIcon(Icons.edit).first;
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Modify name
      final nameField = find.widgetWithText(TextField, 'Hobby Name');
      await tester.enterText(nameField, 'Evening Yoga');
      await tester.pumpAndSettle();

      // Save changes
      final updateButton = find.text('Update Hobby');
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Verify changes
      expect(find.text('Evening Yoga'), findsOneWidget);
    });

    testWidgets('Delete hobby with confirmation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap delete button
      final deleteButton = find.byIcon(Icons.delete).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Should see confirmation dialog
      expect(find.text('Delete Hobby?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Hobby should be removed
      // (Can't verify specific text as we don't know which hobby was deleted)
    });
  });

  group('Task Completion Flow', () {
    testWidgets('Toggle task completion', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find first hobby card
      final hobbyCard = find.byType(Card).first;
      
      // Tap to complete
      await tester.tap(hobbyCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see celebration animation
      // (Visual verification, can't assert directly)

      // Tap again to uncomplete
      await tester.tap(hobbyCard);
      await tester.pumpAndSettle();
    });
  });

  group('Navigation Flow', () {
    testWidgets('Navigate through all main screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Start at Dashboard
      expect(find.text('Today'), findsOneWidget);

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // Navigate back to Dashboard
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    });
  });

  group('Settings Flow', () {
    testWidgets('Toggle push notifications', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find and toggle push notifications switch
      final notificationSwitch = find.widgetWithText(ListTile, 'Push Notifications');
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Toggle back
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();
    });

    testWidgets('Toggle sound and vibration', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find and toggle sound switch
      final soundSwitch = find.widgetWithText(ListTile, 'Sound and Vibration');
      await tester.tap(soundSwitch);
      await tester.pumpAndSettle();
    });

    testWidgets('Edit user name', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Tap edit name button
      final editNameButton = find.byIcon(Icons.edit).first;
      await tester.tap(editNameButton);
      await tester.pumpAndSettle();

      // Should see dialog
      expect(find.text('Edit Name'), findsOneWidget);

      // Enter new name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'new user');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify name was updated and capitalized
      expect(find.text('New User'), findsOneWidget);
    });
  });

  group('Developer Settings Flow', () {
    testWidgets('Access developer settings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Scroll to find Developer Settings
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap Developer Settings
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      // Verify screen opened
      expect(find.text('Developer Settings'), findsOneWidget);
      expect(find.text('TESTING TOOLS'), findsOneWidget);
    });

    testWidgets('Test notification feature', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Developer Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      // Tap Test Notification
      await tester.tap(find.text('Test Notification'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see success snackbar
      expect(find.text('✅ Test notification sent!'), findsOneWidget);
    });

    testWidgets('Generate random hobbies', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Developer Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      // Tap Generate Random Hobbies
      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see success message
      expect(find.textContaining('Created'), findsOneWidget);
    });
  });

  group('Analytics Flow', () {
    testWidgets('View contribution chart', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should see chart components
      expect(find.text('Analytics'), findsOneWidget);
      
      // Should see legend
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('Scroll through contribution history', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Scroll horizontally on chart
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(-200, 0));
      await tester.pumpAndSettle();
    });
  });

  group('Complete User Journey', () {
    testWidgets('Full flow: Onboard -> Create -> Complete -> View Analytics', 
        (WidgetTester tester) async {
      // Clear data
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Complete onboarding
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.tap(find.text('Start My Journey'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Create a hobby
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Hobby Name'), 'Reading');
      await tester.enterText(find.widgetWithText(TextField, 'Notes'), '30 minutes daily');
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Complete the task
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // View Analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);

      // Return to dashboard
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('Reading'), findsOneWidget);
    });
  });
}

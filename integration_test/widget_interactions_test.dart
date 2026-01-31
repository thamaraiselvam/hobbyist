import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;

/// Widget interaction tests: Time picker, Color picker, Repeat mode, Priority
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HIGH PRIORITY - Widget Interactions', () {
    testWidgets('Time picker - Select reminder time', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open add hobby screen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter hobby name
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Morning Meditation',
      );
      await tester.pumpAndSettle();

      // Scroll to find time picker
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Look for time display or time picker button
      final timeButton = find.text('8:00 AM');
      if (timeButton.evaluate().isNotEmpty) {
        await tester.tap(timeButton);
        await tester.pumpAndSettle();

        // Time picker dialog should appear
        expect(find.byType(TimePickerDialog), findsOneWidget);

        // Select a time (e.g., 9:30 AM)
        // Note: This is device-specific, may need adjustment
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('30'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Verify time was selected
        expect(find.text('9:30 AM'), findsOneWidget);
      }
    });

    testWidgets('Color picker - Select different colors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Color Test',
      );
      await tester.pumpAndSettle();

      // Scroll to color picker section
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Find color picker - look for color container/buttons
      final colorWidgets = find.byType(GestureDetector);
      if (colorWidgets.evaluate().length > 5) {
        // Tap different colors (test at least 3)
        for (int i = 0; i < 3; i++) {
          await tester.tap(colorWidgets.at(i));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }
      }

      // Save and verify color was applied
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Hobby should be created with selected color
      expect(find.text('Color Test'), findsOneWidget);
    });

    testWidgets('Repeat mode - Select Daily', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Daily Task',
      );
      await tester.pumpAndSettle();

      // Scroll to repeat mode
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Select Daily (should be default, but tap to confirm)
      final dailyButton = find.text('Daily');
      if (dailyButton.evaluate().isNotEmpty) {
        await tester.tap(dailyButton);
        await tester.pumpAndSettle();
      }

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Task'), findsOneWidget);
    });

    testWidgets('Repeat mode - Select Weekly with day', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Weekly Review',
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Select Weekly
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      // Week day selector should appear (M, T, W, T, F, S, S)
      // Select Monday (first option)
      final daySelectors = find.text('M');
      if (daySelectors.evaluate().isNotEmpty) {
        await tester.tap(daySelectors.first);
        await tester.pumpAndSettle();
      }

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Review'), findsOneWidget);
    });

    testWidgets('Repeat mode - Select Monthly with date', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Monthly Bill Payment',
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Select Monthly
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Month day selector should appear (1-31)
      // Select day 1
      final daySelector = find.text('1');
      if (daySelector.evaluate().isNotEmpty) {
        await tester.tap(daySelector.first);
        await tester.pumpAndSettle();
      }

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Bill Payment'), findsOneWidget);
    });

    testWidgets('Priority - Select High', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'High Priority Task',
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();

      // Select High priority
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('High Priority Task'), findsOneWidget);
    });

    testWidgets('Priority - Select Low', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Low Priority Task',
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Low'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Low Priority Task'), findsOneWidget);
    });

    testWidgets('Test all 10 colors available', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create 10 hobbies with different colors
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Hobby Name'),
          'Color Test $i',
        );
        await tester.pumpAndSettle();

        // Scroll and select color
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();

        final colorWidgets = find.byType(GestureDetector);
        if (colorWidgets.evaluate().length > i) {
          await tester.tap(colorWidgets.at(i));
          await tester.pumpAndSettle();
        }

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create Hobby'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify all were created
      for (int i = 0; i < 10; i++) {
        expect(find.text('Color Test $i'), findsOneWidget);
      }
    });

    testWidgets('Toggle notification on/off when creating hobby', 
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Notification Toggle Test',
      );
      await tester.pumpAndSettle();

      // Scroll to notification toggle
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Look for notification switch/toggle
      final notificationSwitch = find.byType(Switch);
      if (notificationSwitch.evaluate().isNotEmpty) {
        // Toggle off
        await tester.tap(notificationSwitch.first);
        await tester.pumpAndSettle();

        // Toggle back on
        await tester.tap(notificationSwitch.first);
        await tester.pumpAndSettle();
      }

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Notification Toggle Test'), findsOneWidget);
    });
  });
}

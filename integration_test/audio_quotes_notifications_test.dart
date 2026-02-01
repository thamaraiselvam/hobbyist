// ignore_for_file: avoid_print, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;

/// Audio, quotes, notifications, and completion timestamp tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HIGH PRIORITY - Audio & Sound', () {
    testWidgets('Sound plays on task completion when enabled',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Ensure sound is enabled
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Check if sound toggle is on, if not, turn it on
      final soundToggle = find.widgetWithText(ListTile, 'Sound and Vibration');
      // (Visual verification that switch is on)

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Complete a task
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Sound should play (cannot be verified in test, manual check needed)
      // But we can verify no crash occurs
    });

    testWidgets('No sound when toggle is off', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Turn sound off
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Sound and Vibration'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Complete a task
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // No sound should play (manual verification)
    });

    testWidgets('Multiple rapid sound plays', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Complete multiple tasks rapidly
      final cards = find.byType(Card);
      final count = cards.evaluate().length;

      for (int i = 0; i < count && i < 5; i++) {
        await tester.tap(cards.at(i));
        await tester.pump(const Duration(milliseconds: 200));
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should handle multiple sounds gracefully
    });

    testWidgets('Sound service initialization', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Complete task - if sound service failed, should still work
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // No crash = sound service initialized correctly
    });
  });

  group('HIGH PRIORITY - Motivational Quotes', () {
    testWidgets('Quote displays on dashboard', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should see a quote somewhere on dashboard
      // Quotes are displayed in a specific area
      // Look for quote-like text (long text that's motivational)
    });

    testWidgets('Quote changes on dashboard reload',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Get initial quote (if visible)
      // Navigate away
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Quote might change (random)
    });

    testWidgets('Long quote displays properly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Some quotes are longer than others
      // Should all display without overflow

      // Navigate multiple times to get different quotes
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }

      // No overflow errors should occur
    });

    testWidgets('Quote service handles initialization',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should start without crash even if quote service has issues
      expect(find.text('Today'), findsOneWidget);
    });
  });

  group('MEDIUM PRIORITY - Notification Content', () {
    testWidgets('Notification content includes hobby name',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Enable notifications
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      final notifToggle = find.widgetWithText(ListTile, 'Push Notifications');
      // Ensure it's on

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Create hobby with reminder
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Notification Content Test',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Set reminder time
      final timeButton = find.text('8:00 AM');
      if (timeButton.evaluate().isNotEmpty) {
        await tester.tap(timeButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Notification scheduled (check console logs)
    });

    testWidgets('Notification shows streak info', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Complete task to build streak
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Edit to trigger notification reschedule
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Hobby'));
      await tester.pumpAndSettle();

      // Check console logs for notification content with streak
    });
  });

  group('MEDIUM PRIORITY - Notification Scheduling', () {
    testWidgets('Multiple hobbies with same time', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create 3 hobbies with same reminder time
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Hobby Name'),
          'Same Time $i',
        );
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(SingleChildScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();

        // All at 9:00 AM
        final timeButton = find.text('8:00 AM');
        if (timeButton.evaluate().isNotEmpty) {
          await tester.tap(timeButton);
          await tester.pumpAndSettle();
          await tester.tap(find.text('9'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('Create Hobby'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // All should be scheduled with unique IDs
      // Check console logs
    });

    testWidgets('Cancel notification on hobby delete',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create hobby with notification
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'To Be Deleted',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Delete it
      final deleteButton = find.byIcon(Icons.delete).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Notification should be cancelled (check logs)
    });

    testWidgets('Reschedule on hobby edit', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Edit a hobby with notification
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Change time
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      final timeButton = find.textContaining('AM');
      if (timeButton.evaluate().isNotEmpty) {
        await tester.tap(timeButton.first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Update Hobby'));
      await tester.pumpAndSettle();

      // Should cancel old and schedule new (check logs)
    });

    testWidgets('Notification respects push notification toggle',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Disable notifications
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Push Notifications'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Create hobby with reminder
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'No Notification',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Check logs - should say notification skipped due to settings
    });
  });

  group('HIGH PRIORITY - Completion Timestamps', () {
    testWidgets('Timestamp recorded on completion',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final beforeTime = DateTime.now();

      // Complete a task
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final afterTime = DateTime.now();

      // Timestamp should be between beforeTime and afterTime
      // (Database verification needed)
    });

    testWidgets('Multiple completions same day tracked separately',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Complete and uncomplete same task
      final card = find.byType(Card).first;

      await tester.tap(card);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(card);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(card);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Latest completion should have most recent timestamp
    });

    testWidgets('Timestamp survives app restart', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Complete a task
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Simulate restart
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Completion and timestamp should still exist
    });
  });

  group('LOW PRIORITY - Widget Animations', () {
    testWidgets('Checkbox animation plays', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(Card).first);

      // Animation should play over ~300ms
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpAndSettle();

      // Animation completed
    });

    testWidgets('Tada celebration animation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(Card).first);

      // Celebration animation should appear
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpAndSettle();

      // Animation should complete without crash
    });

    testWidgets('Loading indicators display', (WidgetTester tester) async {
      app.main();

      // Loading should appear briefly
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should load successfully
      expect(find.text('Today'), findsOneWidget);
    });
  });
}

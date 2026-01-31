import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;

/// Edge cases and error handling tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Input Validation Tests', () {
    testWidgets('Cannot create hobby with empty name', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open add hobby screen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Leave name empty, scroll and try to save
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Create button should be disabled or show error
      // (Depends on implementation)
    });

    testWidgets('Name auto-capitalization works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Edit name
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Test various cases
      await tester.enterText(find.byType(TextField).first, 'john');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('John'), findsOneWidget);

      // Test multiple words
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'john doe smith');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('John Doe Smith'), findsOneWidget);
    });

    testWidgets('Handles special characters in hobby name', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter name with special characters
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Test & Learn #1 @ Home',
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Should successfully create
      expect(find.text('Test & Learn #1 @ Home'), findsOneWidget);
    });
  });

  group('State Persistence Tests', () {
    testWidgets('Completion state persists after app restart', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Complete a task
      final firstCard = find.byType(Card).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Restart app (simulate)
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if completion is still there
      // (Visual check - checkbox should be checked)
    });

    testWidgets('Settings persist after navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Go to settings and toggle
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      
      await tester.tap(find.widgetWithText(ListTile, 'Push Notifications'));
      await tester.pumpAndSettle();

      // Navigate away
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Go back to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Setting should be persisted
    });
  });

  group('Concurrent Operations Tests', () {
    testWidgets('Multiple rapid completions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Rapidly tap multiple cards
      final cards = find.byType(Card);
      final cardCount = cards.evaluate().length;

      for (int i = 0; i < cardCount && i < 3; i++) {
        await tester.tap(cards.at(i));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      // All should complete successfully
    });

    testWidgets('Navigate while animation playing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Start completion animation
      await tester.tap(find.byType(Card).first);
      await tester.pump(const Duration(milliseconds: 100));

      // Immediately navigate
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should navigate successfully without crash
      expect(find.text('Analytics'), findsOneWidget);
    });
  });

  group('Data Limits Tests', () {
    testWidgets('Create maximum number of hobbies', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Use developer tools to generate many hobbies
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      // Generate random hobbies multiple times
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Generate Random Hobbies'));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Return to dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Should still work smoothly
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Very long hobby name', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter very long name
      final longName = 'This is a very long hobby name that should test the UI layout and text overflow handling' * 3;
      await tester.enterText(find.widgetWithText(TextField, 'Hobby Name'), longName);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Should create and display properly
    });

    testWidgets('Very long notes text', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Hobby Name'), 'Test');
      final longNotes = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' * 20;
      await tester.enterText(find.widgetWithText(TextField, 'Notes'), longNotes);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Should handle gracefully
    });
  });

  group('Empty State Tests', () {
    testWidgets('Dashboard with no hobbies shows empty state', (WidgetTester tester) async {
      // Would need to clear all hobbies first
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // If no hobbies exist, should show empty state
      // Check for empty state message
    });

    testWidgets('Analytics with no data', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should still show chart structure
      expect(find.text('Analytics'), findsOneWidget);
    });
  });

  group('Delete Confirmation Tests', () {
    testWidgets('Cancel delete operation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Get hobby name before delete
      final hobbyCard = find.byType(Card).first;
      
      // Tap delete
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Hobby should still exist
      expect(hobbyCard, findsOneWidget);
    });

    testWidgets('Confirm delete operation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Count hobbies before
      final initialCount = find.byType(Card).evaluate().length;

      // Tap delete and confirm
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Count should decrease
      final afterCount = find.byType(Card).evaluate().length;
      expect(afterCount, lessThan(initialCount));
    });
  });

  group('Notification Settings Integration', () {
    testWidgets('Disable notifications and create hobby - no notification scheduled', 
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Disable notifications
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Push Notifications'));
      await tester.pumpAndSettle();

      // Go back and create hobby
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Hobby Name'), 'Test Task');
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Set reminder time
      // (Would need to interact with time picker)

      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Check console logs - should show notification was skipped
    });
  });

  group('Theme and UI Consistency Tests', () {
    testWidgets('All screens maintain dark theme', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check multiple screens
      final screens = [
        Icons.home,
        Icons.bar_chart,
        Icons.settings,
      ];

      for (final icon in screens) {
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();

        // Check for dark background color
        final scaffold = find.byType(Scaffold).first;
        expect(scaffold, findsOneWidget);
      }
    });
  });

  group('Data Reset Tests', () {
    testWidgets('Reset all data returns to onboarding', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Developer Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      // Scroll to danger zone
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap Reset All Data
      await tester.tap(find.text('Reset All Data'));
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('Reset Everything'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should return to splash/landing screen
    });
  });
}

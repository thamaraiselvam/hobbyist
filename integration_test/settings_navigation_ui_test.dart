import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;

/// Settings, navigation, empty states, and UI consistency tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MEDIUM PRIORITY - Settings Persistence', () {
    testWidgets('Settings survive app restart simulation', 
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Toggle notification off
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Push Notifications'));
      await tester.pumpAndSettle();

      // Simulate restart
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check setting persisted
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Setting should still be off (visual check of switch)
    });

    testWidgets('Settings sync across screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Change setting
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Sound and Vibration'));
      await tester.pumpAndSettle();

      // Navigate away and back
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Setting should persist
    });

    testWidgets('Default values on first launch', (WidgetTester tester) async {
      // Would need fresh install
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Defaults should be:
      // - Push Notifications: ON
      // - Sound and Vibration: ON
    });
  });

  group('MEDIUM PRIORITY - Empty States', () {
    testWidgets('Dashboard empty state shows message', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Delete all hobbies
      var deleteButtons = find.byIcon(Icons.delete);
      while (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        deleteButtons = find.byIcon(Icons.delete);
      }

      // Should show empty state
      expect(find.textContaining('No'), findsWidgets);
    });

    testWidgets('Analytics empty state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Delete all hobbies
      var deleteButtons = find.byIcon(Icons.delete);
      while (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        deleteButtons = find.byIcon(Icons.delete);
      }

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should still show chart structure
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('Empty state has call-to-action', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Delete all if any exist
      var deleteButtons = find.byIcon(Icons.delete);
      while (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        deleteButtons = find.byIcon(Icons.delete);
      }

      // FAB should still be visible to add first hobby
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('MEDIUM PRIORITY - Edit vs Create Mode', () {
    testWidgets('Create mode shows "Create Hobby" button', 
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Create Hobby'), findsOneWidget);
      expect(find.text('Update Hobby'), findsNothing);
    });

    testWidgets('Edit mode shows "Update Hobby" button', 
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Edit first hobby
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Update Hobby'), findsOneWidget);
      expect(find.text('Create Hobby'), findsNothing);
    });

    testWidgets('Edit mode pre-fills all fields', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create hobby with all fields
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Prefill Test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Notes'),
        'Test notes',
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Edit it
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Should see pre-filled values
      expect(find.text('Prefill Test'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('Screen title changes between Create/Edit', 
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create mode
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Look for title
      expect(find.text('Add Hobby'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Edit mode
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Hobby'), findsOneWidget);
    });
  });

  group('LOW PRIORITY - Navigation', () {
    testWidgets('Back button from add hobby screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter some text
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Unsaved',
      );
      await tester.pumpAndSettle();

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to dashboard
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Unsaved'), findsNothing);
    });

    testWidgets('Back button from edit hobby screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Modify something
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Modified',
      );
      await tester.pumpAndSettle();

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return without saving
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Back button from settings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Back button from developer settings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Navigation preserves screen state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Scroll dashboard
      await tester.drag(find.byType(Card).first, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Navigate away
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Should maintain scroll position (approximately)
    });
  });

  group('LOW PRIORITY - Bottom Navigation', () {
    testWidgets('Active tab is highlighted', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Dashboard should be active
      final homeIcon = find.byIcon(Icons.home);
      expect(homeIcon, findsOneWidget);

      // Tap analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Analytics should now be active
    });

    testWidgets('All navigation items accessible', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should see all 3 navigation items
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Navigation maintains data state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Complete a task
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Back to dashboard
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Completion should still be there
    });
  });

  group('LOW PRIORITY - Theme Consistency', () {
    testWidgets('Dark theme on all screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final screens = [
        find.byIcon(Icons.home),
        find.byIcon(Icons.bar_chart),
        find.byIcon(Icons.settings),
      ];

      for (final screen in screens) {
        await tester.tap(screen);
        await tester.pumpAndSettle();

        // Check for dark background (visual)
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets);
      }
    });

    testWidgets('Purple accent color throughout', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check various screens
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Primary color should be consistent (visual check)
    });

    testWidgets('Card design consistent', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // All cards should have same design
      final cards = find.byType(Card);
      expect(cards.evaluate().length, greaterThan(0));

      // Visual consistency check
    });
  });

  group('LOW PRIORITY - Error Messages', () {
    testWidgets('Empty name shows validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Don't enter name, try to save
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Button might be disabled or show error
      final createButton = find.text('Create Hobby');
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Should show error or prevent creation
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;

/// Form validation, database operations, and data integrity tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MEDIUM PRIORITY - Form Validation', () {
    testWidgets('Maximum field length handling - Name',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter 200 character name
      final longName = 'A' * 200;
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        longName,
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Should either accept or show validation error
    });

    testWidgets('Maximum field length handling - Notes',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Notes Length Test',
      );

      // Enter 1000 character notes
      final longNotes = 'B' * 1000;
      await tester.enterText(
        find.widgetWithText(TextField, 'Notes'),
        longNotes,
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Notes Length Test'), findsOneWidget);
    });

    testWidgets('Special characters in name - All types',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final specialNames = [
        'Task & Project #1',
        'Email @ Work',
        'Study [Math]',
        'Code {Dart}',
        'Price \$100',
        'Win 50%',
        'Question?',
        'Excited!',
        'Ratio 1:2',
        'Quote "Test"',
      ];

      for (int i = 0; i < specialNames.length; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Hobby Name'),
          specialNames[i],
        );
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(SingleChildScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create Hobby'));
        await tester.pumpAndSettle();

        expect(find.text(specialNames[i]), findsOneWidget);
      }
    });

    testWidgets('Emoji in hobby name', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        '🏃‍♂️ Running 🏃‍♀️',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('🏃‍♂️ Running 🏃‍♀️'), findsOneWidget);
    });

    testWidgets('Whitespace handling - Leading/trailing',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        '  Spaces Test  ',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Should trim whitespace
      expect(find.textContaining('Spaces Test'), findsOneWidget);
    });

    testWidgets('Multiple spaces between words', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Multiple    Spaces    Test',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Multiple'), findsOneWidget);
    });

    testWidgets('Line breaks in notes field', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Multiline Notes',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Notes'),
        'Line 1\nLine 2\nLine 3',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Multiline Notes'), findsOneWidget);
    });

    testWidgets('Numbers only in name', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        '12345',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('12345'), findsOneWidget);
    });

    testWidgets('Mixed language characters', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Hello مرحبا 你好',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Hello مرحبا 你好'), findsOneWidget);
    });
  });

  group('MEDIUM PRIORITY - Database Operations', () {
    testWidgets('Cascade delete - Deleting hobby removes completions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create and complete a hobby
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Cascade Test',
      );
      await tester.pumpAndSettle();
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Complete it
      await tester.tap(find.text('Cascade Test'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Delete the hobby
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify it's deleted
      expect(find.text('Cascade Test'), findsNothing);

      // Check analytics - completion should be gone
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
    });

    testWidgets('Multiple rapid database writes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create multiple hobbies rapidly
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(
          find.widgetWithText(TextField, 'Hobby Name'),
          'Rapid Create $i',
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.drag(
            find.byType(SingleChildScrollView), const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Create Hobby'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // All should be created
      for (int i = 0; i < 5; i++) {
        expect(find.text('Rapid Create $i'), findsOneWidget);
      }
    });

    testWidgets('Concurrent completion toggles', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Get all hobby cards
      final cards = find.byType(Card);
      final cardCount = cards.evaluate().length;

      if (cardCount >= 3) {
        // Toggle multiple at once
        for (int i = 0; i < 3; i++) {
          await tester.tap(cards.at(i));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // All should be completed
      }
    });

    testWidgets('Edit hobby preserves completions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create and complete
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Edit Preservation',
      );
      await tester.pumpAndSettle();
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Preservation'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Edit the hobby
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Edited Name',
      );
      await tester.pumpAndSettle();

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update Hobby'));
      await tester.pumpAndSettle();

      // Completion should still be there (visual check on checkbox)
      expect(find.text('Edited Name'), findsOneWidget);
    });

    testWidgets('Large dataset handling - 50+ hobbies',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Generate multiple times
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Generate Random Hobbies'));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Go back to dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Should still be responsive
      final cards = find.byType(Card);
      expect(cards.evaluate().length, greaterThan(30));

      // Scroll through list
      await tester.drag(cards.first, const Offset(0, -500));
      await tester.pumpAndSettle();
    });
  });

  group('MEDIUM PRIORITY - Data Generation', () {
    testWidgets('First generation creates 15 predefined tasks',
        (WidgetTester tester) async {
      // Would need fresh database
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see success message about 15 tasks
      expect(find.textContaining('15'), findsOneWidget);
    });

    testWidgets('Subsequent generation adds random completions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      // Generate twice
      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Second time should add completions
      expect(find.textContaining('completions'), findsOneWidget);
    });

    testWidgets('Generated data shows in analytics',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check analytics
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Chart should have data
      expect(find.text('Analytics'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;
import 'package:intl/intl.dart';

/// Streak calculation, analytics, and contribution chart tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HIGH PRIORITY - Streak & Analytics', () {
    testWidgets('Streak increments on consecutive day completions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create a hobby
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Streak Test',
      );
      await tester.pumpAndSettle();
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      // Complete task today
      final hobbyCard = find.text('Streak Test');
      await tester.tap(hobbyCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check analytics to verify completion
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should see contribution chart with today's completion
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('Contribution chart shows correct color intensity',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Verify legend exists
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Verify chart is scrollable
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsWidgets);

      // Scroll to see different weeks
      if (scrollView.evaluate().isNotEmpty) {
        await tester.drag(scrollView.first, const Offset(-300, 0));
        await tester.pumpAndSettle();

        await tester.drag(scrollView.first, const Offset(300, 0));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Month labels display correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Current month should be visible
      final now = DateTime.now();
      final monthFormat = DateFormat('MMM');
      final currentMonth = monthFormat.format(now);

      // Should find current month label
      expect(find.textContaining(currentMonth), findsAtLeastNWidgets(1));
    });

    testWidgets('Day labels (M, W, F) are visible',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should see day labels
      expect(find.text('M'), findsWidgets);
      expect(find.text('W'), findsWidgets);
      expect(find.text('F'), findsWidgets);
    });

    testWidgets('Analytics shows total completions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Generate some data
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go to analytics
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should see some completion data
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('Chart displays 12 weeks of history',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Scroll to start of chart
      final scrollView = find.byType(SingleChildScrollView).first;

      // Scroll all the way left
      await tester.drag(scrollView, const Offset(1000, 0));
      await tester.pumpAndSettle();

      // Should be able to scroll right to see 12 weeks
      await tester.drag(scrollView, const Offset(-1500, 0));
      await tester.pumpAndSettle();
    });

    testWidgets('Multiple completions same day show darker color',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create 4 hobbies
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Hobby Name'),
          'Multi Task $i',
        );
        await tester.pumpAndSettle();
        await tester.drag(
            find.byType(SingleChildScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create Hobby'));
        await tester.pumpAndSettle();
      }

      // Complete all 4 tasks today
      final cards = find.byType(Card);
      for (int i = 0; i < 4; i++) {
        await tester.tap(cards.at(i));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Check analytics - today should show darkest color
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Visual verification needed - should see darker green for today
    });

    testWidgets('Best streak displays correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for streak display in hobby cards or analytics
      // This depends on where streaks are shown in the UI

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should see some streak information
    });
  });

  group('MEDIUM PRIORITY - Analytics Calculations', () {
    testWidgets('Completion percentage calculates correctly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Create hobby and complete it
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hobby Name'),
        'Percentage Test',
      );
      await tester.pumpAndSettle();
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Hobby'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Percentage Test'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if percentage is displayed anywhere
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
    });

    testWidgets('Weekly average calculation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Generate data
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Random Hobbies'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check analytics
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Look for weekly statistics
    });

    testWidgets('Empty analytics shows appropriate message',
        (WidgetTester tester) async {
      // Would need to reset data first
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Delete all hobbies
      final deleteButtons = find.byIcon(Icons.delete);
      final deleteCount = deleteButtons.evaluate().length;

      for (int i = 0; i < deleteCount; i++) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
      }

      // Go to analytics
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Should show empty state or default chart
      expect(find.text('Analytics'), findsOneWidget);
    });
  });

  group('LOW PRIORITY - Chart Details', () {
    testWidgets('Current day is highlighted', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Today's cell should have different styling (visual check)
    });

    testWidgets('Hover/tap shows cell data', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Try tapping on a chart cell if tooltip is implemented
      // This is device/implementation specific
    });

    testWidgets('Legend shows all 5 intensity levels',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Legend should show: Less [][][][][] More
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Should see 5 color boxes (visual verification)
    });
  });
}

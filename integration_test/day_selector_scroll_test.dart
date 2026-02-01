// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbyist/main.dart' as app;
import 'package:intl/intl.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Day Selector Scroll Behavior', () {
    testWidgets(
        'Day selector should scroll to selected date after creating hobby',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Skip login if present
      final skipButton = find.text('Skip for now');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Wait for the day selector animation to complete on launch
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the ListView with day selector
      final dayListView = find.byType(ListView).first;

      // Get initial scroll position (should be centered on today after launch animation)
      final initialScrollController =
          tester.widget<ListView>(dayListView).controller;
      final initialScrollPosition = initialScrollController?.offset ?? 0.0;

      print(
          '📍 Initial scroll position (centered on today): $initialScrollPosition');

      // Get today's date for verification
      final today = DateTime.now();
      final todayFormatted = DateFormat('d').format(today);
      print('📅 Today is: ${DateFormat('MMM d, yyyy').format(today)}');

      // Verify today's date pill exists and is visible
      final todayPill = find.text(todayFormatted);
      expect(todayPill, findsWidgets,
          reason: 'Today\'s date should be visible in day selector');

      // Tap the + button to create a hobby
      final createButton = find.byIcon(Icons.add);
      expect(createButton, findsOneWidget,
          reason: 'Create button should be visible');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // We're now on the Add Hobby screen
      print('📝 On Add Hobby screen');

      // Fill in hobby name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Test Hobby for Scroll');
      await tester.pumpAndSettle();

      // Scroll down to find the Save button
      await tester.drag(
          find.byType(SingleChildScrollView).first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap Save button
      final saveButton = find.text('Create Hobby');
      expect(saveButton, findsOneWidget,
          reason: 'Save button should be visible');
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // We're back on the main screen
      print('🏠 Back on main screen');

      // Wait for any animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Get the scroll position after returning from create hobby screen
      final afterScrollPosition = initialScrollController?.offset ?? 0.0;

      print('📍 Scroll position after creating hobby: $afterScrollPosition');
      print(
          '📍 Difference from initial: ${(afterScrollPosition - initialScrollPosition).abs()}');

      // Verify today's date pill is still visible (should be centered)
      expect(todayPill, findsWidgets,
          reason: 'Today\'s date should still be visible after creating hobby');

      // The scroll position should be approximately the same as initial (centered on today)
      // Allow some tolerance for animation differences
      expect(
        (afterScrollPosition - initialScrollPosition).abs(),
        lessThan(100),
        reason:
            'Scroll position should be re-centered on selected date (today) after creating hobby',
      );

      print(
          '✅ Test passed: Day selector properly scrolls to selected date after creating hobby');
    });

    testWidgets('Day selector scroll position matches selected date',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Skip login if present
      final skipButton = find.text('Skip for now');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Wait for initial animation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Get today's date
      final today = DateTime.now();
      final todayFormatted = DateFormat('d').format(today);

      // Find today's date pill - it should be centered
      final todayPills = find.text(todayFormatted);
      expect(todayPills, findsWidgets,
          reason: 'Today\'s date should be visible and centered');

      // Get screen width to check if today is approximately centered
      final screenSize = tester.getSize(find.byType(MaterialApp));
      final screenWidth = screenSize.width;
      print('📱 Screen width: $screenWidth');

      // Find the position of today's pill
      final todayPillWidget = todayPills.first;
      final todayPillPosition = tester.getTopLeft(todayPillWidget);
      print('📍 Today pill position: $todayPillPosition');

      // Check if today's pill is approximately in the center of the screen
      // It should be around screenWidth / 2 (with some tolerance)
      final distanceFromCenter = (todayPillPosition.dx - screenWidth / 2).abs();
      print('📏 Distance from screen center: $distanceFromCenter');

      expect(
        distanceFromCenter,
        lessThan(screenWidth * 0.2), // Within 20% of screen width from center
        reason: 'Today\'s date should be approximately centered on screen',
      );

      print('✅ Test passed: Selected date is properly centered in view');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('App Flow Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('complete onboarding flow', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Should show landing screen after splash
      expect(find.text('Track Your Daily\nHobbies with Ease'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should show name input screen
      expect(find.text('What should we call\nyou?'), findsOneWidget);

      // Enter name
      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.pump();

      // Tap Start My Journey
      await tester.tap(find.text('Start My Journey'));
      await tester.pumpAndSettle();

      // Should show daily tasks screen
      expect(find.text('Your Hobbies'), findsOneWidget);
    });

    testWidgets('skip onboarding if already completed', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Should go directly to daily tasks
      expect(find.text('Your Hobbies'), findsOneWidget);
    });
  });

  group('Navigation Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});
    });

    testWidgets('navigate between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Should be on Tasks tab
      expect(find.text('Your Hobbies'), findsOneWidget);

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.local_fire_department_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Hobby Streaks'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      // Navigate back to Tasks
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pumpAndSettle();

      expect(find.text('Your Hobbies'), findsOneWidget);
    });
  });

  group('Hobby Management Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});
    });

    testWidgets('add new hobby flow', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Tap add hobby button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show add hobby screen
      expect(find.text('Add New Hobby'), findsOneWidget);

      // Enter hobby details
      final nameFields = find.byType(TextField);
      await tester.tap(nameFields.first);
      await tester.enterText(nameFields.first, 'Morning Exercise');
      await tester.pump();

      // Select weekly repeat
      await tester.tap(find.text('Weekly'));
      await tester.pump();

      // Select high priority
      await tester.tap(find.text('High'));
      await tester.pump();

      // Save hobby
      await tester.tap(find.text('Save Hobby'));
      await tester.pumpAndSettle();

      // Should return to daily tasks with new hobby
      expect(find.text('Morning Exercise'), findsOneWidget);
    });

    testWidgets('complete hobby task flow', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Add a hobby first
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final nameFields = find.byType(TextField);
      await tester.tap(nameFields.first);
      await tester.enterText(nameFields.first, 'Test Hobby');
      await tester.pump();

      await tester.tap(find.text('Save Hobby'));
      await tester.pumpAndSettle();

      // Find and tap checkbox to complete
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Checkbox should be checked (visual verification would need custom matcher)
      expect(find.text('Test Hobby'), findsOneWidget);
    });
  });

  group('Analytics Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});
    });

    testWidgets('view analytics with no data', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.local_fire_department_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Hobby Streaks'), findsOneWidget);
      expect(find.text('CURRENT STREAK'), findsOneWidget);
      expect(find.text('TOTAL DONE'), findsOneWidget);
    });

    testWidgets('view analytics after completing task', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Add and complete a hobby
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final nameFields = find.byType(TextField);
      await tester.tap(nameFields.first);
      await tester.enterText(nameFields.first, 'Analytics Test');
      await tester.pump();

      await tester.tap(find.text('Save Hobby'));
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.local_fire_department_outlined));
      await tester.pumpAndSettle();

      // Should show updated stats
      expect(find.text('Hobby Streaks'), findsOneWidget);
    });

    testWidgets('change analytics period', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.local_fire_department_outlined));
      await tester.pumpAndSettle();

      // Tap Monthly tab
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly'), findsOneWidget);

      // Tap Yearly tab
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();

      expect(find.text('Yearly'), findsOneWidget);
    });
  });

  group('Settings Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});
    });

    testWidgets('navigate to settings and back', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pumpAndSettle();

      expect(find.text('Your Hobbies'), findsOneWidget);
    });

    testWidgets('view version information', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('Version'), findsOneWidget);
    });
  });

  group('Refresh Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});
    });

    testWidgets('pull to refresh on daily tasks', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Perform pull to refresh gesture
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should still show daily tasks
      expect(find.text('Your Hobbies'), findsOneWidget);
    });

    testWidgets('pull to refresh on analytics', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 3000));

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.local_fire_department_outlined));
      await tester.pumpAndSettle();

      // Perform pull to refresh gesture
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('Hobby Streaks'), findsOneWidget);
    });
  });
}

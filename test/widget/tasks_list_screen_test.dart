import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:hobbyist/screens/tasks_list_screen.dart';
import 'package:hobbyist/models/hobby.dart';
import '../helpers/firebase_mocks.dart';

void main() async {
  await setupFirebaseMocks();

  setUpAll(() async {
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (MethodCall methodCall) async {
      return '.';
    });

    // Mock shared_preferences
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{};
      }
      return true;
    });

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TasksListScreen Widget Tests', () {
    late List<Hobby> testHobbies;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      testHobbies = [
        Hobby(
          id: 'test-daily',
          name: 'Daily Task',
          notes: 'Daily notes',
          repeatMode: 'daily',
          color: 0xFF4285F4,
          completions: {},
          createdAt: DateTime.now(),
          bestStreak: 5,
        ),
        Hobby(
          id: 'test-weekly',
          name: 'Weekly Task',
          notes: '',
          repeatMode: 'weekly',
          color: 0xFF34A853,
          completions: {},
          createdAt: DateTime.now(),
          customDay: 1,
          bestStreak: 3,
        ),
        Hobby(
          id: 'test-monthly',
          name: 'Monthly Task',
          notes: '',
          repeatMode: 'monthly',
          color: 0xFFEA4335,
          completions: {},
          createdAt: DateTime.now(),
          customDay: 15,
          bestStreak: 2,
        ),
      ];
    });

    testWidgets('should display tasks list screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(TasksListScreen), findsOneWidget);
    });

    testWidgets('should display with empty hobbies list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: const [],
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(TasksListScreen), findsOneWidget);
    });

    testWidgets('should display tabs for filtering', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.text('All'), findsWidgets);
      expect(find.text('Daily'), findsWidgets);
      expect(find.text('Weekly'), findsWidgets);
      expect(find.text('Monthly'), findsWidgets);
    });

    testWidgets('should display hobby names', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.text('Daily Task'), findsOneWidget);
      expect(find.text('Weekly Task'), findsOneWidget);
      expect(find.text('Monthly Task'), findsOneWidget);
    });

    testWidgets('should have bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.local_fire_department), findsWidgets);
      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('should display tab bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('should respond to didUpdateWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      // Update with new hobbies
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: [testHobbies.first],
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(TasksListScreen), findsOneWidget);
      expect(find.text('Daily Task'), findsOneWidget);
    });

    testWidgets('should handle single hobby', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TasksListScreen(
            hobbies: [testHobbies.first],
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(TasksListScreen), findsOneWidget);
      expect(find.text('Daily Task'), findsOneWidget);
    });
  });
}

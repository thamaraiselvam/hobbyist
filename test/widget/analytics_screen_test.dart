import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:hobbyist/screens/analytics_screen.dart';
import 'package:hobbyist/models/hobby.dart';
import 'package:hobbyist/services/analytics_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../helpers/firebase_mocks.dart';
import 'analytics_screen_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AnalyticsService>()])
void main() async {
  await setupFirebaseMocks();

  late MockAnalyticsService mockAnalyticsService;

  setUpAll(() async {
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
      return '.';
    });

    // Mock shared_preferences
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{};
      }
      return true;
    });

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AnalyticsScreen Widget Tests', () {
    late List<Hobby> testHobbies;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAnalyticsService = MockAnalyticsService();
      AnalyticsService.instance = mockAnalyticsService;

      when(mockAnalyticsService.logAnalyticsViewed()).thenAnswer((_) async {});

      testHobbies = [
        Hobby(
          id: 'test-1',
          name: 'Test Hobby 1',
          notes: 'Test notes',
          repeatMode: 'daily',
          color: 0xFF4285F4,
          completions: {},
          createdAt: DateTime.now(),
          bestStreak: 5,
        ),
        Hobby(
          id: 'test-2',
          name: 'Test Hobby 2',
          notes: '',
          repeatMode: 'weekly',
          color: 0xFF34A853,
          completions: {},
          createdAt: DateTime.now(),
          bestStreak: 3,
        ),
      ];
    });

    testWidgets('should display analytics screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('should display with empty hobbies list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            hobbies: const [],
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('should have bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
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

    testWidgets('should display period selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            hobbies: testHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.text('W'), findsOneWidget);
    });

    testWidgets('should display hobbies with completions',
        (WidgetTester tester) async {
      final hobbyWithCompletions = Hobby(
        id: 'test-completed',
        name: 'Completed Hobby',
        notes: '',
        repeatMode: 'daily',
        color: 0xFF4285F4,
        completions: {
          '2024-01-01': HobbyCompletion(completed: true),
          '2024-01-02': HobbyCompletion(completed: true),
        },
        createdAt: DateTime.now(),
        bestStreak: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            hobbies: [hobbyWithCompletions],
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('should respond to didUpdateWidget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
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
          home: AnalyticsScreen(
            hobbies: [testHobbies.first],
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('should handle hobby with all repeat modes',
        (WidgetTester tester) async {
      final allModeHobbies = [
        Hobby(
          id: 'daily-hobby',
          name: 'Daily Hobby',
          notes: '',
          repeatMode: 'daily',
          color: 0xFF4285F4,
          completions: {},
          createdAt: DateTime.now(),
          bestStreak: 0,
        ),
        Hobby(
          id: 'weekly-hobby',
          name: 'Weekly Hobby',
          notes: '',
          repeatMode: 'weekly',
          color: 0xFF34A853,
          completions: {},
          createdAt: DateTime.now(),
          customDay: 1,
          bestStreak: 0,
        ),
        Hobby(
          id: 'monthly-hobby',
          name: 'Monthly Hobby',
          notes: '',
          repeatMode: 'monthly',
          color: 0xFFEA4335,
          completions: {},
          createdAt: DateTime.now(),
          customDay: 15,
          bestStreak: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            hobbies: allModeHobbies,
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('should display hobby with high streak',
        (WidgetTester tester) async {
      final highStreakHobby = Hobby(
        id: 'high-streak',
        name: 'High Streak Hobby',
        notes: '',
        repeatMode: 'daily',
        color: 0xFF4285F4,
        completions: {},
        createdAt: DateTime.now(),
        bestStreak: 100,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            hobbies: [highStreakHobby],
            onBack: () {},
            onNavigate: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });
  });
}

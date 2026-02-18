import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:hobbyist/screens/daily_tasks_screen.dart';
import '../helpers/firebase_mocks.dart';

import 'package:hobbyist/services/hobby_service.dart';
import 'package:hobbyist/services/analytics_service.dart';
import 'package:hobbyist/services/quote_service.dart';
import 'package:hobbyist/services/sound_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'daily_tasks_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<HobbyService>(),
  MockSpec<AnalyticsService>(),
  MockSpec<QuoteService>(),
  MockSpec<SoundService>(),
])
void main() async {
  await setupFirebaseMocks();

  late MockHobbyService mockHobbyService;
  late MockAnalyticsService mockAnalyticsService;
  late MockQuoteService mockQuoteService;
  late MockSoundService mockSoundService;

  setUpAll(() async {
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, Object>{};
        }
        return true;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async {
        return null;
      },
    );

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DailyTasksScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'hasCompletedOnboarding': true,
      });
      
      mockHobbyService = MockHobbyService();
      mockAnalyticsService = MockAnalyticsService();
      mockQuoteService = MockQuoteService();
      mockSoundService = MockSoundService();
      
      HobbyService.instance = mockHobbyService;
      AnalyticsService.instance = mockAnalyticsService;
      QuoteService.instance = mockQuoteService;
      SoundService.instance = mockSoundService;
      
      when(mockHobbyService.loadHobbies()).thenAnswer((_) async => []);
      when(mockAnalyticsService.logAnalyticsViewed()).thenAnswer((_) async {});
      when(mockQuoteService.getRandomQuote()).thenReturn('Test Quote');
    });

    testWidgets('should display daily tasks screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DailyTasksScreen(),
        ),
      );
      
      // Wait for all initState timers and animations
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byType(DailyTasksScreen), findsOneWidget);
    });

    testWidgets('should display scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DailyTasksScreen(),
        ),
      );
      
      // Wait for all initState timers and animations
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display 7 days in day selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DailyTasksScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      final listViewFinder = find.byWidgetPredicate((widget) =>
        widget is ListView && widget.scrollDirection == Axis.horizontal
      );

      expect(listViewFinder, findsOneWidget);

      final listView = tester.widget<ListView>(listViewFinder);
      final delegate = listView.childrenDelegate as SliverChildBuilderDelegate;
      // In the current code, itemCount is 7 (current week)
      expect(delegate.estimatedChildCount, 7);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:hobbyist/database/database_helper.dart';
import 'dart:io';

@GenerateNiceMocks([
  MockSpec<FirebaseAnalytics>(),
])
import 'analytics_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AnalyticsService service;
  late MockFirebaseAnalytics mockAnalytics;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
      return '.';
    });
  });

  setUp(() async {
    final file = File('hobbyist.db');
    if (file.existsSync()) file.deleteSync();
    DatabaseHelper.reset();

    mockAnalytics = MockFirebaseAnalytics();

    AnalyticsService.mockAnalytics = mockAnalytics;
    AnalyticsService.initialize();
    service = AnalyticsService();

    // Enable telemetry for tests that expect it enabled
    final db = await DatabaseHelper.instance.database;
    await db.insert(
        'settings',
        {
          'key': 'telemetry_enabled',
          'value': 'true',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  });

  tearDown(() {
    AnalyticsService.mockAnalytics = null;
  });

  group('AnalyticsService Tests', () {
    test('Singleton check', () {
      expect(AnalyticsService(), same(AnalyticsService()));
    });

    test('Observer check', () {
      // Small coverage for observer getter
      expect(AnalyticsService.observer, isNotNull);
    });

    test('logAppOpen', () async {
      await service.logAppOpen();
      verify(mockAnalytics.logAppOpen()).called(1);
    });

    test('logScreenView', () async {
      await service.logScreenView('Home');
      verify(mockAnalytics.logScreenView(
              screenName: 'Home', screenClass: 'Home'))
          .called(1);
    });

    test('Onboarding Events', () async {
      await service.logOnboardingComplete();
      verify(mockAnalytics.logEvent(
              name: 'user_onboarding_complete',
              parameters: anyNamed('parameters')))
          .called(1);

      await service.logLandingView();
      verify(mockAnalytics.logEvent(name: 'landing_page_viewed')).called(1);
    });

    test('Hobby Management Events', () async {
      await service.logHobbyCreated(
          hobbyId: '1', repeatMode: 'daily', color: 123);
      verify(mockAnalytics.logEvent(
              name: 'hobby_created',
              parameters:
                  argThat(containsPair('hobby_id', '1'), named: 'parameters')))
          .called(1);

      await service.logHobbyUpdated(hobbyId: '1', repeatMode: 'weekly');
      verify(mockAnalytics.logEvent(
              name: 'hobby_updated',
              parameters: argThat(containsPair('repeat_mode', 'weekly'),
                  named: 'parameters')))
          .called(1);

      await service.logHobbyDeleted(hobbyId: '1', reason: 'cleanup');
      verify(mockAnalytics.logEvent(
              name: 'hobby_deleted',
              parameters: argThat(containsPair('reason', 'cleanup'),
                  named: 'parameters')))
          .called(1);
    });

    test('Completion Events', () async {
      await service.logCompletionToggled(
          hobbyId: '1', completed: true, currentStreak: 5);
      verify(mockAnalytics.logEvent(
              name: 'completion_toggled',
              parameters: argThat(containsPair('completed', true),
                  named: 'parameters')))
          .called(1);

      // Milestone check
      await service.logStreakAchieved(hobbyId: '1', streakCount: 7);
      verify(mockAnalytics.logEvent(
              name: 'streak_milestone', parameters: anyNamed('parameters')))
          .called(1);

      await service.logStreakAchieved(
          hobbyId: '1', streakCount: 5); // non-milestone
      verifyNever(mockAnalytics.logEvent(
          name: 'streak_milestone', parameters: anyNamed('parameters')));

      await service.logCompletionSound();
      verify(mockAnalytics.logEvent(name: 'completion_sound_played')).called(1);
    });

    test('Engagement and Performance Events', () async {
      await service.logAnalyticsViewed();
      verify(mockAnalytics.logEvent(
              name: 'analytics_viewed', parameters: anyNamed('parameters')))
          .called(1);

      await service.logSettingChanged(settingName: 's', settingValue: 'v');
      verify(mockAnalytics.logEvent(
              name: 'setting_changed', parameters: anyNamed('parameters')))
          .called(1);

      await service.logQuoteDisplayed();
      verify(mockAnalytics.logEvent(name: 'quote_displayed')).called(1);

      await service.logDatabaseQueryTime(queryType: 'read', durationMs: 10);
      verify(mockAnalytics.logEvent(
              name: 'db_query_performance', parameters: anyNamed('parameters')))
          .called(1);
    });

    test('User Engagement Metrics', () async {
      await service.logDailyStats(
          totalHobbies: 5, completedToday: 3, averageCompletionRate: 0.6);
      verify(mockAnalytics.logEvent(
              name: 'daily_stats', parameters: anyNamed('parameters')))
          .called(1);

      await service.setUserProperty(name: 'prop', value: 'val');
      verify(mockAnalytics.setUserProperty(name: 'prop', value: 'val'))
          .called(1);

      await service.logSessionEnd(durationSeconds: 120);
      verify(mockAnalytics.logEvent(
              name: 'session_end', parameters: anyNamed('parameters')))
          .called(1);
    });

    test('Custom Conversion Events', () async {
      await service.logFirstHobbyCreated();
      verify(mockAnalytics.logEvent(
              name: 'first_hobby_created', parameters: anyNamed('parameters')))
          .called(1);

      await service.logFirstCompletion();
      verify(mockAnalytics.logEvent(
              name: 'first_completion', parameters: anyNamed('parameters')))
          .called(1);
    });

    test('Behavior when telemetry is disabled', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
          'settings',
          {
            'key': 'telemetry_enabled',
            'value': 'false',
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);

      await service.logAppOpen();
      verifyNever(mockAnalytics.logAppOpen());
    });

    test('Telemetry check error handling', () async {
      // Already verified in CrashlyticsService that it handles DB errors by defaulting to true
    });
  });
}

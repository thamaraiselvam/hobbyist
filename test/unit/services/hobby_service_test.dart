import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/hobby_service.dart';
import 'package:hobbyist/models/hobby.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:hobbyist/services/notification_service.dart';
import 'package:hobbyist/services/analytics_service.dart';
import 'package:hobbyist/services/performance_service.dart';
import 'package:hobbyist/services/crashlytics_service.dart';
import 'package:hobbyist/services/rating_service.dart';
import 'package:hobbyist/database/database_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'hobby_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DatabaseHelper>(),
  MockSpec<NotificationService>(),
  MockSpec<AnalyticsService>(),
  MockSpec<PerformanceService>(),
  MockSpec<CrashlyticsService>(),
  MockSpec<RatingService>(),
])
void main() {
  late HobbyService service;
  late MockNotificationService mockNotification;
  late MockAnalyticsService mockAnalytics;
  late MockPerformanceService mockPerformance;
  late MockCrashlyticsService mockCrashlytics;
  late MockRatingService mockRating;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
      return '.';
    });

    // Mock local_notifications
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('dexterous.com/flutter/local_notifications'),
            (MethodCall methodCall) async {
      return null;
    });

    // Mock shared_preferences
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{}; // Return empty map
      }
      return true;
    });

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    mockNotification = MockNotificationService();
    mockAnalytics = MockAnalyticsService();
    mockPerformance = MockPerformanceService();
    mockCrashlytics = MockCrashlyticsService();
    mockRating = MockRatingService();

    service = HobbyService.forTesting(
      dbHelper: DatabaseHelper.instance,
      notificationService: mockNotification,
      analytics: mockAnalytics,
      performance: mockPerformance,
      crashlytics: mockCrashlytics,
      ratingService: mockRating,
    );

    await DatabaseHelper.instance.clearAllData();

    // Default stubs
    when(mockPerformance.traceDatabaseQuery(any, any))
        .thenAnswer((invocation) async {
      final callback =
          invocation.positionalArguments[1] as Future<dynamic> Function();
      return await callback();
    });

    when(mockNotification.scheduleNotification(any))
        .thenAnswer((_) async => true);
    when(mockNotification.getPendingNotifications())
        .thenAnswer((_) async => []);
  });

  group('HobbyService Tests', () {
    test('should add and load hobby', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);
      final hobbies = await service.loadHobbies();

      expect(hobbies.any((h) => h.id == hobby.id), true);
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);
      expect(loadedHobby.name, 'Test Hobby');
      expect(loadedHobby.color, 0xFF6C3FFF);
    });

    test('should add hobby with all properties', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Complete Hobby',
        notes: 'Test notes',
        repeatMode: 'weekly',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);
      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);

      expect(loadedHobby.name, 'Complete Hobby');
      expect(loadedHobby.notes, 'Test notes');
      expect(loadedHobby.repeatMode, 'weekly');
    });

    test('should add hobby with completions', () async {
      final completions = {
        '2024-01-01':
            HobbyCompletion(completed: true, completedAt: DateTime(2024, 1, 1)),
        '2024-01-02': HobbyCompletion(completed: false),
      };

      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);
      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);

      expect(loadedHobby.completions.length, 2);
      expect(loadedHobby.completions['2024-01-01']?.completed, true);
      expect(loadedHobby.completions['2024-01-02']?.completed, false);
    });

    test('should load multiple hobbies', () async {
      final hobby1 = Hobby(
        id: 'test-1-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Hobby 1',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      final hobby2 = Hobby(
        id: 'test-2-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Hobby 2',
        color: 0xFFFF6B35,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby1);
      await service.addHobby(hobby2);

      final hobbies = await service.loadHobbies();
      expect(hobbies.length, greaterThanOrEqualTo(2));
      expect(hobbies.any((h) => h.name == 'Hobby 1'), true);
      expect(hobbies.any((h) => h.name == 'Hobby 2'), true);
    });

    test('should update hobby name', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Original Name',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);

      final updatedHobby = hobby.copyWith(name: 'Updated Name');
      await service.updateHobby(updatedHobby);

      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);
      expect(loadedHobby.name, 'Updated Name');
    });

    test('should update hobby properties', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        notes: 'Original notes',
        repeatMode: 'daily',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);

      final updatedHobby = hobby.copyWith(
        notes: 'Updated notes',
        repeatMode: 'weekly',
      );
      await service.updateHobby(updatedHobby);

      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);

      expect(loadedHobby.notes, 'Updated notes');
      expect(loadedHobby.repeatMode, 'weekly');
    });

    test('should update hobby completions', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);

      final updatedHobby = hobby.copyWith(
        completions: {
          '2024-01-01': HobbyCompletion(
              completed: true, completedAt: DateTime(2024, 1, 1)),
        },
      );
      await service.updateHobby(updatedHobby);

      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);
      expect(loadedHobby.completions['2024-01-01']?.completed, true);
    });

    test('should delete hobby', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);

      final hobbiesBefore = await service.loadHobbies();
      expect(hobbiesBefore.any((h) => h.id == hobby.id), true);

      await service.deleteHobby(hobby.id);

      final hobbiesAfter = await service.loadHobbies();
      expect(hobbiesAfter.any((h) => h.id == hobby.id), false);
    });

    test('should delete hobby with completions', () async {
      final completions = {
        '2024-01-01':
            HobbyCompletion(completed: true, completedAt: DateTime(2024, 1, 1)),
      };

      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);
      await service.deleteHobby(hobby.id);

      final hobbies = await service.loadHobbies();
      expect(hobbies.any((h) => h.id == hobby.id), false);
    });

    test('should toggle completion from false to true', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);

      const date = '2024-01-01';
      await service.toggleCompletion(hobby.id, date);

      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);
      expect(loadedHobby.completions[date]?.completed, true);
      expect(loadedHobby.completions[date]?.completedAt, isNotNull);
    });

    test('should toggle completion from true to false', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);

      const date = '2024-01-01';
      await service.toggleCompletion(hobby.id, date);
      await service.toggleCompletion(hobby.id, date);

      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);
      expect(loadedHobby.completions[date]?.completed, false);
    });

    test('should toggle multiple completions', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);

      await service.toggleCompletion(hobby.id, '2024-01-01');
      await service.toggleCompletion(hobby.id, '2024-01-02');
      await service.toggleCompletion(hobby.id, '2024-01-03');

      final hobbies = await service.loadHobbies();
      final loadedHobby = hobbies.firstWhere((h) => h.id == hobby.id);

      expect(loadedHobby.completions['2024-01-01']?.completed, true);
      expect(loadedHobby.completions['2024-01-02']?.completed, true);
      expect(loadedHobby.completions['2024-01-03']?.completed, true);
    });

    test('should save and get setting', () async {
      await service.setSetting('testKey', 'testValue');
      final value = await service.getSetting('testKey');
      expect(value, 'testValue');
    });

    test('should update existing setting', () async {
      await service.setSetting('testKey', 'value1');
      await service.setSetting('testKey', 'value2');
      final value = await service.getSetting('testKey');
      expect(value, 'value2');
    });

    test('should save multiple settings', () async {
      await service.setSetting('key1', 'value1');
      await service.setSetting('key2', 'value2');
      await service.setSetting('key3', 'value3');

      expect(await service.getSetting('key1'), 'value1');
      expect(await service.getSetting('key2'), 'value2');
      expect(await service.getSetting('key3'), 'value3');
    });

    test('should return null for non-existent setting', () async {
      final value = await service.getSetting(
          'nonExistentKey-${DateTime.now().millisecondsSinceEpoch}');
      expect(value, null);
    });

    test('should save hobbies using saveHobbies method', () async {
      final hobbies = [
        Hobby(
          id: 'test-1-${DateTime.now().millisecondsSinceEpoch}',
          name: 'Hobby 1',
          color: 0xFF6C3FFF,
          createdAt: DateTime.now(),
        ),
        Hobby(
          id: 'test-2-${DateTime.now().millisecondsSinceEpoch}',
          name: 'Hobby 2',
          color: 0xFFFF6B35,
          createdAt: DateTime.now(),
        ),
      ];

      await service.saveHobbies(hobbies);
      final loadedHobbies = await service.loadHobbies();

      expect(loadedHobbies.length, greaterThanOrEqualTo(2));
      expect(loadedHobbies.any((h) => h.name == 'Hobby 1'), true);
      expect(loadedHobbies.any((h) => h.name == 'Hobby 2'), true);
    });

    test('should reset database', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);
      await service.setSetting('testKey', 'testValue');

      await service.resetDatabase();

      final hobbies = await service.loadHobbies();
      final setting = await service.getSetting('testKey');

      expect(hobbies, isEmpty);
      expect(setting, null);
    });

    test('should clear all data', () async {
      final hobby = Hobby(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        createdAt: DateTime.now(),
      );

      await service.addHobby(hobby);
      await service.clearAllData();

      final hobbies = await service.loadHobbies();
      expect(hobbies, isEmpty);
    });

    test('should handle empty hobby list', () async {
      await service.resetDatabase();
      final hobbies = await service.loadHobbies();
      expect(hobbies, isEmpty);
    });

    test('should load hobbies in correct order', () async {
      final hobby1 = Hobby(
        id: 'test-1',
        name: 'First',
        color: 0xFF6C3FFF,
        createdAt: DateTime(2024, 1, 1),
      );

      final hobby2 = Hobby(
        id: 'test-2',
        name: 'Second',
        color: 0xFFFF6B35,
        createdAt: DateTime(2024, 1, 2),
      );

      await service.addHobby(hobby1);
      await Future.delayed(const Duration(milliseconds: 10));
      await service.addHobby(hobby2);

      final hobbies = await service.loadHobbies();
      final filtered =
          hobbies.where((h) => h.id == 'test-1' || h.id == 'test-2').toList();

      // Should be in descending order (newest first)
      expect(filtered.first.name, 'Second');
      expect(filtered.last.name, 'First');
    });
  });
}

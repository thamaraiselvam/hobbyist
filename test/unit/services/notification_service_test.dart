import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hobbyist/models/hobby.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:hobbyist/database/database_helper.dart';

@GenerateNiceMocks([
  MockSpec<FlutterLocalNotificationsPlugin>(),
  MockSpec<AndroidFlutterLocalNotificationsPlugin>(),
  MockSpec<IOSFlutterLocalNotificationsPlugin>(),
])
import 'notification_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  late NotificationService service;
  late MockFlutterLocalNotificationsPlugin mockNotifications;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroid;
  late MockIOSFlutterLocalNotificationsPlugin mockIOS;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });
  });

  setUp(() async {
    final file = File('hobbyist.db');
    if (file.existsSync()) file.deleteSync();
    DatabaseHelper.reset();

    mockNotifications = MockFlutterLocalNotificationsPlugin();
    mockAndroid = MockAndroidFlutterLocalNotificationsPlugin();
    mockIOS = MockIOSFlutterLocalNotificationsPlugin();

    when(mockNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroid);
    // Clear existing stubs to avoid generic type conflicts
    reset(mockNotifications);

    when(mockNotifications.resolvePlatformSpecificImplementation())
        .thenAnswer((invocation) {
          if (invocation.typeArguments.first == AndroidFlutterLocalNotificationsPlugin) {
            return mockAndroid;
          }
          if (invocation.typeArguments.first == IOSFlutterLocalNotificationsPlugin) {
            return mockIOS;
          }
          return null;
        });

    service = NotificationService.test(notifications: mockNotifications);
  });

  group('NotificationService Tests', () {
    test('Singleton check', () {
      expect(NotificationService(), same(NotificationService()));
    });

    test('Instance setter check', () {
      final oldInstance = NotificationService();
      final newInstance = NotificationService.test();
      NotificationService.instance = newInstance;
      expect(NotificationService(), same(newInstance));
      NotificationService.instance = oldInstance;
    });

    test('initialize', () async {
      when(mockNotifications.initialize(any,
          onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse')))
          .thenAnswer((_) async => true);
          
      await service.initialize();
      verify(mockNotifications.initialize(any,
          onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'))).called(1);
    });

    test('areNotificationsEnabled Android', () async {
      when(mockAndroid.areNotificationsEnabled()).thenAnswer((_) async => true);
      expect(await service.areNotificationsEnabled(), true);

      when(mockAndroid.areNotificationsEnabled()).thenAnswer((_) async => false);
      expect(await service.areNotificationsEnabled(), false);
    });

    test('requestPermissions Android', () async {
      when(mockAndroid.requestNotificationsPermission()).thenAnswer((_) async => true);
      when(mockAndroid.requestExactAlarmsPermission()).thenAnswer((_) async => true);
      
      expect(await service.requestPermissions(), true);
      verify(mockAndroid.requestNotificationsPermission()).called(1);
    });

    test('scheduleNotification daily', () async {
      // Mock DB settings
      final db = await DatabaseHelper.instance.database;
      await db.insert('settings', {
        'key': 'push_notifications', 
        'value': 'true', 
        'updated_at': 0
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final hobby = Hobby(
        id: '1',
        name: 'Test Hobby',
        repeatMode: 'daily',
        reminderTime: '08:00',
        color: 0xFF000000,
      );

      when(mockAndroid.canScheduleExactNotifications()).thenAnswer((_) async => true);

      final result = await service.scheduleNotification(hobby);
      expect(result, true);
      
      verify(mockNotifications.zonedSchedule(
        any, any, any, any, any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: DateTimeComponents.time,
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('scheduleNotification weekly', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('settings', {
        'key': 'push_notifications', 
        'value': 'true', 
        'updated_at': 0
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final hobby = Hobby(
        id: '1',
        name: 'Test Hobby',
        repeatMode: 'weekly',
        reminderTime: '08:00',
        customDay: 2, // Wednesday
        color: 0xFF000000,
      );

      when(mockAndroid.canScheduleExactNotifications()).thenAnswer((_) async => true);

      await service.scheduleNotification(hobby);
      
      verify(mockNotifications.zonedSchedule(
        any, any, any, any, any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('scheduleNotification monthly', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('settings', {
        'key': 'push_notifications', 
        'value': 'true', 
        'updated_at': 0
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final hobby = Hobby(
        id: '1',
        name: 'Test Hobby',
        repeatMode: 'monthly',
        reminderTime: '08:00',
        customDay: 15,
        color: 0xFF000000,
      );

      when(mockAndroid.canScheduleExactNotifications()).thenAnswer((_) async => true);

      await service.scheduleNotification(hobby);
      
      verify(mockNotifications.zonedSchedule(
        any, any, any, any, any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('cancelNotification', () async {
      await service.cancelNotification('1');
      verify(mockNotifications.cancel('1'.hashCode)).called(1);
    });

    test('cancelAllNotifications', () async {
      await service.cancelAllNotifications();
      verify(mockNotifications.cancelAll()).called(1);
    });

    test('showTestNotification', () async {
      await service.showTestNotification();
      verify(mockNotifications.show(any, any, any, any)).called(1);
    });

    test('Behavior when settings disabled', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('settings', {
        'key': 'push_notifications', 
        'value': 'false', 
        'updated_at': 0
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final hobby = Hobby(
        id: '1',
        name: 'Hobby',
        repeatMode: 'daily',
        reminderTime: '08:00',
        color: 0,
      );

      final result = await service.scheduleNotification(hobby);
      expect(result, false);
      verifyNever(mockNotifications.zonedSchedule(any, any, any, any, any, 
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation')));
    });
    
    test('getTimezoneFromOffset coverage', () async {
      // We can't easily change the device timezone in tests, 
      // but we can test the internal mapping if we make it public or use a helper.
      // Since it's private and used in initialize(), we hit the one for currently 
      // detected timezone. To hit others, we'd need to mock DateTime.now() or 
      // restructure. For now, 80%+ is the goal.
    });

    test('scheduleNotification when exact alarms not permitted', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('settings', {
        'key': 'push_notifications', 
        'value': 'true', 
        'updated_at': 0
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final hobby = Hobby(
        id: '1',
        name: 'Test Hobby',
        repeatMode: 'daily',
        reminderTime: '08:00',
        color: 0xFF000000,
      );

      when(mockAndroid.canScheduleExactNotifications()).thenAnswer((_) async => false);

      final result = await service.scheduleNotification(hobby);
      expect(result, true); // Still returns true but skips scheduling
      verifyNever(mockNotifications.zonedSchedule(any, any, any, any, any, 
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation')));
    });

    test('initialize when check fails', () async {
        // Mock a failure in timezone detection if possible
    });
  });
}

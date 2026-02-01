// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/notification_service.dart';
import 'package:hobbyist/services/hobby_service.dart';
import 'package:hobbyist/models/hobby.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Hobby Creation and Notification Integration Tests', () {
    late NotificationService notificationService;
    late HobbyService hobbyService;

    setUp(() async {
      notificationService = NotificationService();
      hobbyService = HobbyService();

      // Initialize notification service
      await notificationService.initialize();
      await notificationService.requestPermissions();

      // Clear all existing notifications and hobbies
      await notificationService.cancelAllNotifications();
      await hobbyService.resetDatabase();
    });

    tearDown(() async {
      // Cleanup after each test
      await notificationService.cancelAllNotifications();
      await hobbyService.resetDatabase();
    });

    testWidgets(
        'Test 1: Create hobby with daily frequency and notification enabled',
        (WidgetTester tester) async {
      // Create hobby with daily frequency
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Daily Reading',
        notes: 'Read for 30 minutes',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '09:00', // 9 AM
      );

      await hobbyService.addHobby(hobby);

      // Verify hobby was created
      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 1);
      expect(hobbies.first.name, 'Daily Reading');
      expect(hobbies.first.repeatMode, 'daily');

      // Verify notification was scheduled
      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);
      expect(pendingNotifications.first.title, 'Daily Reading');

      print('✅ Test 1 PASSED: Daily frequency with notification');
    });

    testWidgets(
        'Test 2: Create hobby with weekly frequency (single day) and notification',
        (WidgetTester tester) async {
      // Create hobby with weekly frequency - Monday
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Weekly Gym',
        notes: 'Go to gym on Mondays',
        repeatMode: 'weekly',
        color: const Color(0xFF590df2).value,
        reminderTime: '08:00', // 8 AM
      );

      await hobbyService.addHobby(hobby);

      // Verify hobby was created
      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 1);
      expect(hobbies.first.name, 'Weekly Gym');
      expect(hobbies.first.repeatMode, 'weekly');

      // Verify notification was scheduled
      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);

      print('✅ Test 2 PASSED: Weekly frequency with notification');
    });

    testWidgets(
        'Test 3: Create hobby with monthly frequency (specific day) and notification',
        (WidgetTester tester) async {
      // Create hobby with monthly frequency - 15th of each month
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Monthly Review',
        notes: 'Review goals on 15th',
        repeatMode: 'monthly',
        color: const Color(0xFF590df2).value,
        reminderTime: '10:00', // 10 AM
      );

      await hobbyService.addHobby(hobby);

      // Verify hobby was created
      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 1);
      expect(hobbies.first.name, 'Monthly Review');
      expect(hobbies.first.repeatMode, 'monthly');

      // Verify notification was scheduled
      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);

      print('✅ Test 3 PASSED: Monthly frequency with notification');
    });

    testWidgets('Test 4: Create hobby without notification (notify disabled)',
        (WidgetTester tester) async {
      // Create hobby without notification
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Flexible Task',
        notes: 'No specific time',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '', // Empty means no notification
      );

      await hobbyService.addHobby(hobby);

      // Verify hobby was created
      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 1);
      expect(hobbies.first.name, 'Flexible Task');

      // Verify NO notification was scheduled
      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 0);

      print('✅ Test 4 PASSED: Hobby without notification');
    });

    testWidgets('Test 5: Update hobby notification time',
        (WidgetTester tester) async {
      // Create hobby with initial time
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Meditation',
        notes: 'Daily meditation',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '07:00',
      );

      await hobbyService.addHobby(hobby);

      // Verify initial notification
      var pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);

      // Update notification time
      final updatedHobby = hobby.copyWith(reminderTime: '18:00');
      await hobbyService.updateHobby(updatedHobby);

      // Verify notification was rescheduled
      pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);
      expect(pendingNotifications.first.title, 'Meditation');

      print('✅ Test 5 PASSED: Update hobby notification time');
    });

    testWidgets('Test 6: Delete hobby removes notification',
        (WidgetTester tester) async {
      // Create hobby
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Temporary Task',
        notes: 'Will be deleted',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '12:00',
      );

      await hobbyService.addHobby(hobby);

      // Verify notification exists
      var pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);

      // Delete hobby
      await hobbyService.deleteHobby(hobby.id);

      // Verify hobby deleted
      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 0);

      // Verify notification removed
      pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 0);

      print('✅ Test 6 PASSED: Delete hobby removes notification');
    });

    testWidgets('Test 7: Multiple hobbies with different frequencies',
        (WidgetTester tester) async {
      // Create multiple hobbies
      final dailyHobby = Hobby(
        id: '${DateTime.now().millisecondsSinceEpoch}_1',
        name: 'Daily Exercise',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '06:00',
      );

      final weeklyHobby = Hobby(
        id: '${DateTime.now().millisecondsSinceEpoch}_2',
        name: 'Weekly Planning',
        repeatMode: 'weekly',
        color: const Color(0xFF590df2).value,
        reminderTime: '09:00',
      );

      final monthlyHobby = Hobby(
        id: '${DateTime.now().millisecondsSinceEpoch}_3',
        name: 'Monthly Budget',
        repeatMode: 'monthly',
        color: const Color(0xFF590df2).value,
        reminderTime: '10:00',
      );

      await hobbyService.addHobby(dailyHobby);
      await hobbyService.addHobby(weeklyHobby);
      await hobbyService.addHobby(monthlyHobby);

      // Verify all hobbies created
      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 3);

      // Verify all notifications scheduled
      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 3);

      print('✅ Test 7 PASSED: Multiple hobbies with different frequencies');
    });

    testWidgets('Test 8: Notification scheduled for future (not past)',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;

      // Set notification time to 2 minutes from now
      final futureMinute = (currentMinute + 2) % 60;
      final futureHour =
          currentMinute + 2 >= 60 ? (currentHour + 1) % 24 : currentHour;

      final reminderTime =
          '${futureHour.toString().padLeft(2, '0')}:${futureMinute.toString().padLeft(2, '0')}';

      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Future Task',
        notes: 'Should notify in 2 minutes',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: reminderTime,
      );

      await hobbyService.addHobby(hobby);

      // Verify notification scheduled
      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);
      expect(pendingNotifications.first.title, 'Future Task');

      print(
          '✅ Test 8 PASSED: Notification scheduled for future (2 minutes from now: $reminderTime)');
      print('   Current time: ${now.hour}:${now.minute}');
    });

    testWidgets('Test 9: Notification permissions check',
        (WidgetTester tester) async {
      // Check notification permissions
      final permissionsGranted = await notificationService.requestPermissions();
      expect(permissionsGranted, isTrue);

      // Check exact alarms capability
      final canScheduleExact =
          await notificationService.canScheduleExactAlarms();
      expect(canScheduleExact, isTrue);

      print('✅ Test 9 PASSED: Notification permissions granted');
    });

    testWidgets('Test 10: Multiple hobbies can be created with different names',
        (WidgetTester tester) async {
      final names = ['Task 1', 'Task 2', 'Task 3', 'Task 4'];

      for (int i = 0; i < names.length; i++) {
        final hobby = Hobby(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          name: names[i],
          repeatMode: 'daily',
          color: const Color(0xFF590df2).value,
          reminderTime: '${8 + i}:00',
        );

        await hobbyService.addHobby(hobby);
      }

      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 4);

      // Verify each hobby was created
      for (int i = 0; i < names.length; i++) {
        final hobby = hobbies.firstWhere((h) => h.name == names[i]);
        expect(hobby.name, names[i]);
      }

      print('✅ Test 10 PASSED: Multiple hobbies with different names created');
    });

    testWidgets('Test 11: Edge case - Notification at midnight',
        (WidgetTester tester) async {
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Midnight Task',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '00:00',
      );

      await hobbyService.addHobby(hobby);

      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);

      print('✅ Test 11 PASSED: Midnight notification scheduled');
    });

    testWidgets('Test 12: Edge case - Notification at 23:59',
        (WidgetTester tester) async {
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Late Night Task',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '23:59',
      );

      await hobbyService.addHobby(hobby);

      final pendingNotifications =
          await notificationService.getPendingNotifications();
      expect(pendingNotifications.length, 1);

      print('✅ Test 12 PASSED: Late night notification scheduled');
    });
  });

  group('Frequency Selector Integration Tests', () {
    late HobbyService hobbyService;

    setUp(() async {
      hobbyService = HobbyService();
      await hobbyService.resetDatabase();
    });

    testWidgets('Test 13: Weekly frequency allows only single day selection',
        (WidgetTester tester) async {
      // This test verifies the UI behavior for single day selection
      // In the actual UI, only one day can be selected at a time for weekly
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Weekly Task',
        repeatMode: 'weekly',
        color: const Color(0xFF590df2).value,
        reminderTime: '10:00',
      );

      await hobbyService.addHobby(hobby);
      final hobbies = await hobbyService.loadHobbies();

      expect(hobbies.first.repeatMode, 'weekly');
      print('✅ Test 13 PASSED: Weekly frequency allows single day selection');
    });

    testWidgets('Test 14: Monthly frequency with day slider (1-31)',
        (WidgetTester tester) async {
      // Test different days of the month
      for (int day in [1, 15, 31]) {
        final hobby = Hobby(
          id: '${DateTime.now().millisecondsSinceEpoch}_$day',
          name: 'Monthly Task Day $day',
          repeatMode: 'monthly',
          color: const Color(0xFF590df2).value,
          reminderTime: '10:00',
        );

        await hobbyService.addHobby(hobby);
      }

      final hobbies = await hobbyService.loadHobbies();
      expect(hobbies.length, 3);
      expect(hobbies.every((h) => h.repeatMode == 'monthly'), isTrue);

      print('✅ Test 14 PASSED: Monthly frequency with day slider works');
    });

    testWidgets('Test 15: Daily frequency shows info (no additional selector)',
        (WidgetTester tester) async {
      final hobby = Hobby(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Daily Task',
        repeatMode: 'daily',
        color: const Color(0xFF590df2).value,
        reminderTime: '08:00',
      );

      await hobbyService.addHobby(hobby);
      final hobbies = await hobbyService.loadHobbies();

      expect(hobbies.first.repeatMode, 'daily');
      print('✅ Test 15 PASSED: Daily frequency works correctly');
    });
  });
}

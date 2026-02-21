// ignore_for_file: avoid_print
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meta/meta.dart';
import 'dart:io';
import '../models/hobby.dart';

class NotificationService {
  static NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  @visibleForTesting
  static set instance(NotificationService value) => _instance = value;

  NotificationService._internal()
    : _notifications = FlutterLocalNotificationsPlugin();

  // For testing
  NotificationService.test({FlutterLocalNotificationsPlugin? notifications})
    : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notifications;

  bool _initialized = false;

  /// Auto-detect timezone from device offset
  String _getTimezoneFromOffset(Duration offset) {
    final offsetMinutes = offset.inMinutes;

    // Map offset to timezone (using common timezones)
    final Map<int, String> timezoneMap = {
      -720: 'Pacific/Auckland', // UTC-12
      -660: 'Pacific/Midway', // UTC-11
      -600: 'Pacific/Honolulu', // UTC-10
      -540: 'America/Anchorage', // UTC-9
      -480: 'America/Los_Angeles', // UTC-8
      -420: 'America/Denver', // UTC-7
      -360: 'America/Chicago', // UTC-6
      -300: 'America/New_York', // UTC-5
      -240: 'America/Caracas', // UTC-4
      -180: 'America/Sao_Paulo', // UTC-3
      -120: 'Atlantic/South_Georgia', // UTC-2
      -60: 'Atlantic/Azores', // UTC-1
      0: 'UTC', // UTC+0
      60: 'Europe/London', // UTC+1
      120: 'Europe/Paris', // UTC+2
      180: 'Europe/Moscow', // UTC+3
      240: 'Asia/Dubai', // UTC+4
      270: 'Asia/Kabul', // UTC+4:30
      300: 'Asia/Karachi', // UTC+5
      330: 'Asia/Kolkata', // UTC+5:30
      345: 'Asia/Kathmandu', // UTC+5:45
      360: 'Asia/Dhaka', // UTC+6
      390: 'Asia/Rangoon', // UTC+6:30
      420: 'Asia/Bangkok', // UTC+7
      480: 'Asia/Singapore', // UTC+8
      540: 'Asia/Tokyo', // UTC+9
      570: 'Australia/Adelaide', // UTC+9:30
      600: 'Australia/Sydney', // UTC+10
      630: 'Australia/Lord_Howe', // UTC+10:30
      660: 'Pacific/Guadalcanal', // UTC+11
      720: 'Pacific/Fiji', // UTC+12
    };

    return timezoneMap[offsetMinutes] ?? 'UTC';
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Auto-detect timezone from device offset
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final detectedTimezone = _getTimezoneFromOffset(offset);

      final location = tz.getLocation(detectedTimezone);
      tz.setLocalLocation(location);

      final tzNow = tz.TZDateTime.now(tz.local);

      print('🌍 Timezone auto-detected: $detectedTimezone');
      print('   Device offset: ${offset.inHours}h ${offset.inMinutes % 60}m');
      print('   Device time: $now');
      print('   TZ time: $tzNow');
    } catch (e) {
      print('⚠️ Failed to auto-detect timezone: $e');
      print('   Falling back to UTC');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hobby_reminders',
      'Hobby Reminders',
      description: 'Notifications for hobby reminders and streaks',
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      return granted ?? false;
    }

    return true; // iOS and other platforms
  }

  /// Request notification permissions (required for Android 13+)
  Future<bool> requestPermissions() async {
    // Android permissions
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Request notification permission
      final granted = await androidImplementation
          .requestNotificationsPermission();

      // Request exact alarm permission (Android 12+)
      try {
        final exactAlarmGranted = await androidImplementation
            .requestExactAlarmsPermission();
        print('Exact alarms permission: $exactAlarmGranted');
      } catch (e) {
        print('Error requesting exact alarms permission: $e');
      }

      return granted ?? false;
    }

    // iOS permissions
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Check if exact alarms are permitted
  Future<bool> canScheduleExactAlarms() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      try {
        final canSchedule = await androidImplementation
            .canScheduleExactNotifications();
        return canSchedule ?? false;
      } catch (e) {
        print('Error checking exact alarm permission: $e');
        return false;
      }
    }

    return true; // iOS and other platforms
  }

  /// Schedule a daily notification for a hobby
  Future<bool> scheduleNotification(Hobby hobby) async {
    try {
      print('📅 Attempting to schedule notification for: ${hobby.name}');

      // Check if push notifications are enabled in app settings
      final settingsEnabled = await _areNotificationsEnabledInSettings();
      if (!settingsEnabled) {
        print(
          '⚠️ Push notifications DISABLED in app settings. Skipping notification for ${hobby.name}',
        );
        return false; // Return false but don't throw error
      }

      print('✅ Push notifications ENABLED in app settings. Proceeding...');

      if (!_initialized) {
        await initialize();
      }

      // Parse reminder time
      if (hobby.reminderTime == null || hobby.reminderTime!.isEmpty) {
        print('ℹ️ No reminder time set for ${hobby.name}');
        return false; // No reminder set
      }

      // One-time tasks store full datetime ('yyyy-MM-dd HH:mm') — handled separately.
      if (hobby.repeatMode == 'one_time') {
        final canSchedule = await canScheduleExactAlarms();
        if (!canSchedule) {
          print('⚠️ Cannot schedule exact alarms. Permission not granted.');
          return true;
        }
        await cancelNotification(hobby.id);
        await _scheduleOneTimeNotification(hobby);
        return true;
      }

      final timeParts = hobby.reminderTime!.split(':');
      if (timeParts.length != 2) return false;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null) return false;

      // Check if we can schedule exact alarms
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        print('⚠️ Cannot schedule exact alarms. Permission not granted.');
        // Still return true to allow task creation, just skip notification
        return true;
      }

      // Cancel existing notification first
      await cancelNotification(hobby.id);

      // Schedule based on repeat mode
      switch (hobby.repeatMode) {
        case 'daily':
          await _scheduleDailyNotification(hobby, hour, minute);
          break;
        case 'weekly':
          await _scheduleWeeklyNotification(hobby, hour, minute);
          break;
        case 'monthly':
          await _scheduleMonthlyNotification(hobby, hour, minute);
          break;
        default:
          await _scheduleDailyNotification(hobby, hour, minute);
      }

      return true;
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      // Return true to allow task creation even if notification fails
      return true;
    }
  }

  /// Schedule daily recurring notification
  Future<void> _scheduleDailyNotification(
    Hobby hobby,
    int hour,
    int minute,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleNotification(hobby, scheduledDate, DateTimeComponents.time);
  }

  /// Schedule weekly recurring notification (on selected day)
  Future<void> _scheduleWeeklyNotification(
    Hobby hobby,
    int hour,
    int minute,
  ) async {
    final now = tz.TZDateTime.now(tz.local);

    // Get selected weekday (0=Monday, 6=Sunday), default to Monday if not set
    final selectedWeekday = hobby.customDay ?? 0;

    // Convert to DateTime weekday (1=Monday, 7=Sunday)
    final targetWeekday = selectedWeekday + 1;

    // Find next occurrence of selected weekday
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Calculate days until target weekday
    int daysUntilTarget = (targetWeekday - scheduledDate.weekday) % 7;
    if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
      daysUntilTarget =
          7; // If today is the day but time passed, schedule for next week
    }

    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));

    print(
      '📅 Weekly notification scheduled for weekday $targetWeekday (${_getWeekdayName(targetWeekday)}) at $scheduledDate',
    );

    await _scheduleNotification(
      hobby,
      scheduledDate,
      DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Schedule monthly recurring notification (on selected day of month)
  Future<void> _scheduleMonthlyNotification(
    Hobby hobby,
    int hour,
    int minute,
  ) async {
    final now = tz.TZDateTime.now(tz.local);

    // Get selected day of month (1-31), default to 1st if not set
    final selectedDay = hobby.customDay ?? 1;

    // Schedule for selected day of current or next month
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      selectedDay,
      hour,
      minute,
    );

    // If the scheduled time is in the past or invalid day for current month, schedule for next month
    if (scheduledDate.isBefore(now) || scheduledDate.day != selectedDay) {
      // Move to next month
      if (now.month == 12) {
        scheduledDate = tz.TZDateTime(
          tz.local,
          now.year + 1,
          1,
          selectedDay,
          hour,
          minute,
        );
      } else {
        scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month + 1,
          selectedDay,
          hour,
          minute,
        );
      }
    }

    print(
      '📅 Monthly notification scheduled for day $selectedDay at $scheduledDate',
    );

    await _scheduleNotification(
      hobby,
      scheduledDate,
      DateTimeComponents.dayOfMonthAndTime,
    );
  }

  /// Schedule a one-shot notification for a one-time task.
  /// reminderTime format: 'yyyy-MM-dd HH:mm'
  Future<void> _scheduleOneTimeNotification(Hobby hobby) async {
    final rt = hobby.reminderTime;
    if (rt == null || rt.isEmpty || !rt.contains(' ')) {
      print('ℹ️ No valid date+time set for one-time task: ${hobby.name}');
      return;
    }

    final parts = rt.split(' ');
    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');
    if (dateParts.length != 3 || timeParts.length != 2) return;

    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (year == null || month == null || day == null ||
        hour == null || minute == null) {
      return;
    }

    final scheduledDate = tz.TZDateTime(tz.local, year, month, day, hour, minute);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print('⚠️ One-time reminder is in the past, skipping: ${hobby.name}');
      return;
    }

    print('📅 One-time notification for "${hobby.name}" at $scheduledDate');

    const androidDetails = AndroidNotificationDetails(
      'hobby_reminders',
      'Hobby Reminders',
      channelDescription: 'Notifications for hobby reminders and streaks',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        'Your one-time task is due now!',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    try {
      await _notifications.zonedSchedule(
        hobby.id.hashCode,
        hobby.name,
        'Your one-time task is due now!',
        scheduledDate,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // No matchDateTimeComponents = fires exactly once
        payload: hobby.id,
      );
      print('✅ One-time notification scheduled at $scheduledDate');
    } catch (e) {
      print('❌ Error scheduling one-time notification: $e');
      rethrow;
    }
  }

  /// Common notification scheduling logic
  Future<void> _scheduleNotification(
    Hobby hobby,
    tz.TZDateTime scheduledDate,
    DateTimeComponents matchComponents,
  ) async {
    // Create notification payload
    final payload = hobby.id;

    // Create notification details
    final androidDetails = AndroidNotificationDetails(
      'hobby_reminders',
      'Hobby Reminders',
      channelDescription: 'Notifications for hobby reminders and streaks',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        'Current streak: ${hobby.currentStreak} 🔥',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    try {
      await _notifications.zonedSchedule(
        hobby.id.hashCode, // Use hobby ID hash as notification ID
        hobby.name,
        'Time to work on your hobby! Current streak: ${hobby.currentStreak} 🔥',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponents,
        payload: payload,
      );
      print(
        '✅ Notification scheduled for ${hobby.name} at $scheduledDate (Local: ${scheduledDate.toLocal()})',
      );
      print('   Current time: ${tz.TZDateTime.now(tz.local)}');
      print('   Notification ID: ${hobby.id.hashCode}');
    } catch (e) {
      print('❌ Error scheduling notification for ${hobby.name}: $e');
      rethrow;
    }
  }

  /// Cancel a scheduled notification for a hobby
  Future<void> cancelNotification(String hobbyId) async {
    await _notifications.cancel(hobbyId.hashCode);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'hobby_reminders',
      'Hobby Reminders',
      channelDescription: 'Notifications for hobby reminders and streaks',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999, // Test notification ID
      '🎉 Test Notification',
      'Notifications are working! You will receive reminders for your hobbies.',
      notificationDetails,
    );
  }

  /// Check if notifications are enabled in app settings
  Future<bool> _areNotificationsEnabledInSettings() async {
    try {
      final db = await _getDatabase();
      final result = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['push_notifications'],
      );

      if (result.isEmpty) {
        print(
          '⚠️ push_notifications setting not found in database, defaulting to enabled',
        );
        return true; // Default to enabled
      }

      final value = result[0]['value'];
      final isEnabled = value != 'false';
      print('🔔 Push notifications setting: $value (enabled: $isEnabled)');
      return isEnabled;
    } catch (e) {
      print('❌ Error checking notification settings: $e');
      return true; // Default to enabled on error
    }
  }

  /// Get database instance
  Future<Database> _getDatabase() async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String dbPath = join(appDocumentsDir.path, 'hobbyist.db');
      return await openDatabase(dbPath);
    } catch (e) {
      print('❌ Error opening database: $e');
      rethrow;
    }
  }

  /// Helper function to get weekday name
  String _getWeekdayName(int weekday) {
    const weekdays = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday];
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Payload contains the hobby ID
    final hobbyId = response.payload;

    // TODO: Navigate to hobby details or daily tasks screen
    // This will be handled by the app's navigation logic
    print('Notification tapped for hobby: $hobbyId');
  }
}

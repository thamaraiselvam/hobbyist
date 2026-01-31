import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/hobby.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Auto-detect timezone from device offset
  String _getTimezoneFromOffset(Duration offset) {
    final offsetMinutes = offset.inMinutes;
    
    // Map offset to timezone (using common timezones)
    final Map<int, String> timezoneMap = {
      -720: 'Pacific/Auckland',      // UTC-12
      -660: 'Pacific/Midway',        // UTC-11
      -600: 'Pacific/Honolulu',      // UTC-10
      -540: 'America/Anchorage',     // UTC-9
      -480: 'America/Los_Angeles',   // UTC-8
      -420: 'America/Denver',        // UTC-7
      -360: 'America/Chicago',       // UTC-6
      -300: 'America/New_York',      // UTC-5
      -240: 'America/Caracas',       // UTC-4
      -180: 'America/Sao_Paulo',     // UTC-3
      -120: 'Atlantic/South_Georgia', // UTC-2
      -60: 'Atlantic/Azores',        // UTC-1
      0: 'UTC',                      // UTC+0
      60: 'Europe/London',           // UTC+1
      120: 'Europe/Paris',           // UTC+2
      180: 'Europe/Moscow',          // UTC+3
      240: 'Asia/Dubai',             // UTC+4
      270: 'Asia/Kabul',             // UTC+4:30
      300: 'Asia/Karachi',           // UTC+5
      330: 'Asia/Kolkata',           // UTC+5:30
      345: 'Asia/Kathmandu',         // UTC+5:45
      360: 'Asia/Dhaka',             // UTC+6
      390: 'Asia/Rangoon',           // UTC+6:30
      420: 'Asia/Bangkok',           // UTC+7
      480: 'Asia/Singapore',         // UTC+8
      540: 'Asia/Tokyo',             // UTC+9
      570: 'Australia/Adelaide',     // UTC+9:30
      600: 'Australia/Sydney',       // UTC+10
      630: 'Australia/Lord_Howe',    // UTC+10:30
      660: 'Pacific/Guadalcanal',    // UTC+11
      720: 'Pacific/Fiji',           // UTC+12
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
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Request notification permissions (required for Android 13+)
  Future<bool> requestPermissions() async {
    // Android permissions
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Request notification permission
      final granted =
          await androidImplementation.requestNotificationsPermission();

      // Request exact alarm permission (Android 12+)
      try {
        final exactAlarmGranted =
            await androidImplementation.requestExactAlarmsPermission();
        print('Exact alarms permission: $exactAlarmGranted');
      } catch (e) {
        print('Error requesting exact alarms permission: $e');
      }

      return granted ?? false;
    }

    // iOS permissions
    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

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
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        final canSchedule =
            await androidImplementation.canScheduleExactNotifications();
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
      if (!_initialized) {
        await initialize();
      }

      // Parse reminder time
      if (hobby.reminderTime == null || hobby.reminderTime!.isEmpty) {
        return false; // No reminder set
      }

      final timeParts = hobby.reminderTime!.split(':');
      if (timeParts.length != 2) return false;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null) return false;

      // Check if we can schedule exact alarms
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        print('Cannot schedule exact alarms. Permission not granted.');
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
      print('Error scheduling notification: $e');
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

  /// Schedule weekly recurring notification (every Monday)
  Future<void> _scheduleWeeklyNotification(
    Hobby hobby,
    int hour,
    int minute,
  ) async {
    final now = tz.TZDateTime.now(tz.local);

    // Find next Monday
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Calculate days until next Monday (1 = Monday, 7 = Sunday)
    int daysUntilMonday = (DateTime.monday - scheduledDate.weekday) % 7;
    if (daysUntilMonday == 0 && scheduledDate.isBefore(now)) {
      daysUntilMonday =
          7; // If today is Monday but time passed, schedule for next Monday
    }

    scheduledDate = scheduledDate.add(Duration(days: daysUntilMonday));

    await _scheduleNotification(
        hobby, scheduledDate, DateTimeComponents.dayOfWeekAndTime);
  }

  /// Schedule monthly recurring notification (first day of month)
  Future<void> _scheduleMonthlyNotification(
    Hobby hobby,
    int hour,
    int minute,
  ) async {
    final now = tz.TZDateTime.now(tz.local);

    // Schedule for first day of next month
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      1, // First day of month
      hour,
      minute,
    );

    // If current date is 1st and time hasn't passed yet, use current month
    // Otherwise, schedule for next month
    if (scheduledDate.isBefore(now) || now.day > 1) {
      // Move to first day of next month
      if (now.month == 12) {
        scheduledDate =
            tz.TZDateTime(tz.local, now.year + 1, 1, 1, hour, minute);
      } else {
        scheduledDate =
            tz.TZDateTime(tz.local, now.year, now.month + 1, 1, hour, minute);
      }
    }

    await _scheduleNotification(
        hobby, scheduledDate, DateTimeComponents.dayOfMonthAndTime);
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
      print('✅ Notification scheduled for ${hobby.name} at $scheduledDate (Local: ${scheduledDate.toLocal()})');
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

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Payload contains the hobby ID
    final hobbyId = response.payload;

    // TODO: Navigate to hobby details or daily tasks screen
    // This will be handled by the app's navigation logic
    print('Notification tapped for hobby: $hobbyId');
  }
}

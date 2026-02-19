// ignore_for_file: avoid_print
import 'package:sqflite/sqflite.dart';
import 'package:meta/meta.dart';
import '../models/hobby.dart';
import '../database/database_helper.dart';
import 'notification_service.dart';
import 'analytics_service.dart';
import 'performance_service.dart';
import 'crashlytics_service.dart';
import 'rating_service.dart';

class HobbyService {
  static HobbyService _instance = HobbyService._internal();
  factory HobbyService() => _instance;

  @visibleForTesting
  static set instance(HobbyService value) => _instance = value;

  HobbyService._internal()
      : _dbHelper = DatabaseHelper.instance,
        _notificationService = NotificationService(),
        _analytics = AnalyticsService(),
        _performance = PerformanceService(),
        _crashlytics = CrashlyticsService(),
        _ratingService = RatingService();

  @visibleForTesting
  HobbyService.forTesting({
    DatabaseHelper? dbHelper,
    NotificationService? notificationService,
    AnalyticsService? analytics,
    PerformanceService? performance,
    CrashlyticsService? crashlytics,
    RatingService? ratingService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _notificationService = notificationService ?? NotificationService(),
        _analytics = analytics ?? AnalyticsService(),
        _performance = performance ?? PerformanceService(),
        _crashlytics = crashlytics ?? CrashlyticsService(),
        _ratingService = ratingService ?? RatingService();

  final DatabaseHelper _dbHelper;
  final NotificationService _notificationService;
  final AnalyticsService _analytics;
  final PerformanceService _performance;
  final CrashlyticsService _crashlytics;
  final RatingService _ratingService;

  Future<List<Hobby>> loadHobbies() async {
    return await _performance.traceDatabaseQuery('load_hobbies', () async {
      try {
        final db = await _dbHelper.database;

        // Get all hobbies
        final List<Map<String, dynamic>> hobbiesData = await db.query(
          'hobbies',
          orderBy: 'created_at DESC',
        );

        // Load completions for each hobby
        List<Hobby> hobbies = [];
        for (var hobbyData in hobbiesData) {
          final List<Map<String, dynamic>> completionsData = await db.query(
            'completions',
            where: 'hobby_id = ?',
            whereArgs: [hobbyData['id']],
          );

          // Build completions map
          Map<String, HobbyCompletion> completions = {};
          for (var comp in completionsData) {
            completions[comp['date']] = HobbyCompletion(
              completed: comp['completed'] == 1,
              completedAt: comp['completed_at'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(comp['completed_at'])
                  : null,
            );
          }

          final hobby = Hobby(
            id: hobbyData['id'],
            name: hobbyData['name'],
            notes: hobbyData['notes'] ?? '',
            repeatMode: hobbyData['repeat_mode'] ?? 'daily',
            color: hobbyData['color'],
            completions: completions,
            createdAt: hobbyData['created_at'] != null
                ? DateTime.fromMillisecondsSinceEpoch(hobbyData['created_at'])
                : null,
            reminderTime: hobbyData['reminder_time'],
            customDay: hobbyData['custom_day'],
            bestStreak: hobbyData['best_streak'] ?? 0,
          );

          // One-time fix: Calculate true historical best streak from completions
          final calculatedBestStreak = hobby.calculateBestStreakFromHistory();

          // Best streak should be the max of stored value, historical best, and current streak
          final trueBestStreak = [
            hobby.bestStreak,
            calculatedBestStreak,
            hobby.currentStreak
          ].reduce((a, b) => a > b ? a : b);

          // Update if the calculated best streak is higher than stored value
          if (trueBestStreak > hobby.bestStreak) {
            await db.update(
              'hobbies',
              {'best_streak': trueBestStreak},
              where: 'id = ?',
              whereArgs: [hobby.id],
            );
            // Create updated hobby with correct bestStreak
            hobbies.add(hobby.copyWith(bestStreak: trueBestStreak));
            print(
                '🔧 Fixed bestStreak for ${hobby.name}: ${hobby.bestStreak} -> $trueBestStreak');
          } else {
            hobbies.add(hobby);
          }
        }

        return hobbies;
      } catch (e, stackTrace) {
        await _crashlytics.logError(e, stackTrace,
            reason: 'Failed to load hobbies');
        rethrow;
      }
    });
  }

  Future<void> addHobby(Hobby hobby) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Insert hobby
      await db.insert(
        'hobbies',
        {
          'id': hobby.id,
          'name': hobby.name,
          'notes': hobby.notes,
          'repeat_mode': hobby.repeatMode,
          'color': hobby.color,
          'reminder_time': hobby.reminderTime,
          'custom_day': hobby.customDay,
          'best_streak': hobby.bestStreak,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert completions
      for (var entry in hobby.completions.entries) {
        await db.insert(
          'completions',
          {
            'hobby_id': hobby.id,
            'date': entry.key,
            'completed': entry.value.completed ? 1 : 0,
            'completed_at': entry.value.completedAt?.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Track hobby creation in analytics
      await _analytics.logHobbyCreated(
        hobbyId: hobby.id,
        repeatMode: hobby.repeatMode,
        color: hobby.color,
      );

      // Check if this is the first hobby
      final hobbies = await loadHobbies();
      if (hobbies.length == 1) {
        await _analytics.logFirstHobbyCreated();
      }

      // Schedule notification if reminder time is set
      if (hobby.reminderTime != null && hobby.reminderTime!.isNotEmpty) {
        try {
          print(
              '📅 Scheduling notification for "${hobby.name}" at ${hobby.reminderTime}');
          final success =
              await _notificationService.scheduleNotification(hobby);
          if (success) {
            final pending =
                await _notificationService.getPendingNotifications();
            print('✅ Notification scheduled. Total pending: ${pending.length}');
          } else {
            print(
                '⚠️ Notification scheduling returned false for "${hobby.name}"');
          }
        } catch (notifError, notifStackTrace) {
          // Log notification error but don't fail the hobby creation
          print(
              '⚠️ Failed to schedule notification for "${hobby.name}": $notifError');
          await _crashlytics.logError(notifError, notifStackTrace,
              reason: 'Failed to schedule notification during hobby creation');
        }
      }
    } catch (e, stackTrace) {
      await _crashlytics.logError(e, stackTrace, reason: 'Failed to add hobby');
      rethrow;
    }
  }

  Future<void> updateHobby(Hobby hobby) async {
    try {
      final db = await _dbHelper.database;

      // Update hobby
      await db.update(
        'hobbies',
        {
          'name': hobby.name,
          'notes': hobby.notes,
          'repeat_mode': hobby.repeatMode,
          'color': hobby.color,
          'reminder_time': hobby.reminderTime,
          'custom_day': hobby.customDay,
          'best_streak': hobby.bestStreak,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [hobby.id],
      );

      // Delete existing completions and re-insert
      await db.delete(
        'completions',
        where: 'hobby_id = ?',
        whereArgs: [hobby.id],
      );

      // Insert updated completions
      for (var entry in hobby.completions.entries) {
        await db.insert(
          'completions',
          {
            'hobby_id': hobby.id,
            'date': entry.key,
            'completed': entry.value.completed ? 1 : 0,
            'completed_at': entry.value.completedAt?.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Track hobby update in analytics
      await _analytics.logHobbyUpdated(
        hobbyId: hobby.id,
        repeatMode: hobby.repeatMode,
      );

      // Reschedule notification
      try {
        await _notificationService.cancelNotification(hobby.id);
        if (hobby.reminderTime != null && hobby.reminderTime!.isNotEmpty) {
          print(
              '📅 Rescheduling notification for "${hobby.name}" at ${hobby.reminderTime}');
          final success =
              await _notificationService.scheduleNotification(hobby);
          if (success) {
            final pending =
                await _notificationService.getPendingNotifications();
            print(
                '✅ Notification rescheduled. Total pending: ${pending.length}');
          } else {
            print(
                '⚠️ Notification rescheduling returned false for "${hobby.name}"');
          }
        }
      } catch (notifError, notifStackTrace) {
        // Log notification error but don't fail the hobby update
        print(
            '⚠️ Failed to reschedule notification for "${hobby.name}": $notifError');
        await _crashlytics.logError(notifError, notifStackTrace,
            reason: 'Failed to reschedule notification during hobby update');
      }
    } catch (e, stackTrace) {
      await _crashlytics.logError(e, stackTrace,
          reason: 'Failed to update hobby');
      rethrow;
    }
  }

  Future<void> deleteHobby(String id) async {
    try {
      final db = await _dbHelper.database;

      // Cancel notification
      try {
        await _notificationService.cancelNotification(id);
      } catch (notifError, notifStackTrace) {
        print('⚠️ Failed to cancel notification for hobby "$id": $notifError');
        await _crashlytics.logError(notifError, notifStackTrace,
            reason: 'Failed to cancel notification during hobby deletion');
      }

      // Track hobby deletion
      await _analytics.logHobbyDeleted(hobbyId: id);

      // Delete hobby (completions will be deleted automatically due to CASCADE)
      await db.delete(
        'hobbies',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      await _crashlytics.logError(e, stackTrace,
          reason: 'Failed to delete hobby');
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
  }

  Future<Hobby?> toggleCompletion(String hobbyId, String date) async {
    final db = await _dbHelper.database;

    // Check if completion exists
    final List<Map<String, dynamic>> existing = await db.query(
      'completions',
      where: 'hobby_id = ? AND date = ?',
      whereArgs: [hobbyId, date],
    );

    bool isCompleted = false;

    if (existing.isEmpty) {
      // Insert new completion
      await db.insert('completions', {
        'hobby_id': hobbyId,
        'date': date,
        'completed': 1,
        'completed_at': DateTime.now().millisecondsSinceEpoch,
      });
      isCompleted = true;
    } else {
      // Toggle existing completion
      isCompleted = existing[0]['completed'] != 1;
      await db.update(
        'completions',
        {
          'completed': isCompleted ? 1 : 0,
          'completed_at':
              isCompleted ? DateTime.now().millisecondsSinceEpoch : null,
        },
        where: 'hobby_id = ? AND date = ?',
        whereArgs: [hobbyId, date],
      );
    }

    // Get updated hobby to check streak
    final hobbies = await loadHobbies();
    final hobby = hobbies.firstWhere((h) => h.id == hobbyId);

    print('🔥 DEBUG: Hobby: ${hobby.name}');
    print('🔥 DEBUG: Current streak: ${hobby.currentStreak}');
    print('🔥 DEBUG: Best streak (before): ${hobby.bestStreak}');

    // Calculate the true best streak from all completion history
    final calculatedBestStreak = hobby.calculateBestStreakFromHistory();
    print('🔥 DEBUG: Calculated historical best: $calculatedBestStreak');

    // Best streak = longest consecutive streak in completion history
    // This recalculates based on actual data, so it can go down if completions are removed
    final newBestStreak = calculatedBestStreak > hobby.currentStreak
        ? calculatedBestStreak
        : hobby.currentStreak;

    print('🔥 DEBUG: New best streak: $newBestStreak');

    // Update best streak in database
    await db.update(
      'hobbies',
      {
        'best_streak': newBestStreak,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [hobbyId],
    );

    print('🔥 DEBUG: Best streak updated in database');

    // Track completion toggle
    await _analytics.logCompletionToggled(
      hobbyId: hobbyId,
      completed: isCompleted,
      currentStreak: hobby.currentStreak,
    );

    // Track streak milestones
    if (isCompleted && hobby.currentStreak > 0) {
      await _analytics.logStreakAchieved(
        hobbyId: hobbyId,
        streakCount: hobby.currentStreak,
      );
    }

    // Track first completion
    if (isCompleted) {
      final allCompletions = hobbies.fold<int>(
        0,
        (sum, h) => sum + h.completions.values.where((c) => c.completed).length,
      );
      if (allCompletions == 1) {
        await _analytics.logFirstCompletion();
      }

      // Increment completion count and check for rating prompt
      await _ratingService.incrementCompletionCount();
      await _ratingService.checkAndShowRatingPrompt();
    }

    // Return the updated hobby
    return hobby.copyWith(bestStreak: newBestStreak);
  }

  // Settings methods
  Future<String?> getSetting(String key) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;
    return result[0]['value'];
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Track settings changes — skip PII keys (never send user data to Firebase)
    const sensitiveSettingKeys = {'userName', 'userEmail', 'userPhoto'};
    if (!sensitiveSettingKeys.contains(key)) {
      await _analytics.logSettingChanged(
        settingName: key,
        settingValue: value,
      );
    }
  }

  // Migration helper - for backward compatibility
  Future<void> saveHobbies(List<Hobby> hobbies) async {
    // This method is kept for backward compatibility
    // but now it uses the new database structure
    for (var hobby in hobbies) {
      await addHobby(hobby);
    }
  }

  // Reset database - for developer settings
  Future<void> resetDatabase() async {
    final db = await _dbHelper.database;

    // Delete all data
    await db.delete('hobbies');
    await db.delete('completions');
    await db.delete('settings');
  }
}

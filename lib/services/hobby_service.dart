import 'package:sqflite/sqflite.dart';
import '../models/hobby.dart';
import '../database/database_helper.dart';
import 'notification_service.dart';

class HobbyService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();

  Future<List<Hobby>> loadHobbies() async {
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

      hobbies.add(Hobby(
        id: hobbyData['id'],
        name: hobbyData['name'],
        notes: hobbyData['notes'] ?? '',
        repeatMode: hobbyData['repeat_mode'] ?? 'daily',
        priority: hobbyData['priority'] ?? 'medium',
        color: hobbyData['color'],
        completions: completions,
        createdAt: hobbyData['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(hobbyData['created_at'])
            : null,
        reminderTime: hobbyData['reminder_time'],
      ));
    }

    return hobbies;
  }

  Future<void> addHobby(Hobby hobby) async {
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
        'priority': hobby.priority,
        'color': hobby.color,
        'reminder_time': hobby.reminderTime,
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

    // Schedule notification if reminder time is set
    if (hobby.reminderTime != null && hobby.reminderTime!.isNotEmpty) {
      print('📅 Scheduling notification for "${hobby.name}" at ${hobby.reminderTime}');
      final success = await _notificationService.scheduleNotification(hobby);
      if (success) {
        final pending = await _notificationService.getPendingNotifications();
        print('✅ Notification scheduled. Total pending: ${pending.length}');
      }
    }
  }

  Future<void> updateHobby(Hobby hobby) async {
    final db = await _dbHelper.database;

    // Update hobby
    await db.update(
      'hobbies',
      {
        'name': hobby.name,
        'notes': hobby.notes,
        'repeat_mode': hobby.repeatMode,
        'priority': hobby.priority,
        'color': hobby.color,
        'reminder_time': hobby.reminderTime,
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

    // Reschedule notification
    await _notificationService.cancelNotification(hobby.id);
    if (hobby.reminderTime != null && hobby.reminderTime!.isNotEmpty) {
      print('📅 Rescheduling notification for "${hobby.name}" at ${hobby.reminderTime}');
      final success = await _notificationService.scheduleNotification(hobby);
      if (success) {
        final pending = await _notificationService.getPendingNotifications();
        print('✅ Notification rescheduled. Total pending: ${pending.length}');
      }
    }
  }

  Future<void> deleteHobby(String id) async {
    final db = await _dbHelper.database;

    // Cancel notification
    await _notificationService.cancelNotification(id);

    // Delete hobby (completions will be deleted automatically due to CASCADE)
    await db.delete(
      'hobbies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
  }

  Future<void> toggleCompletion(String hobbyId, String date) async {
    final db = await _dbHelper.database;

    // Check if completion exists
    final List<Map<String, dynamic>> existing = await db.query(
      'completions',
      where: 'hobby_id = ? AND date = ?',
      whereArgs: [hobbyId, date],
    );

    if (existing.isEmpty) {
      // Insert new completion
      await db.insert('completions', {
        'hobby_id': hobbyId,
        'date': date,
        'completed': 1,
        'completed_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      // Toggle existing completion
      final isCompleted = existing[0]['completed'] == 1;
      await db.update(
        'completions',
        {
          'completed': isCompleted ? 0 : 1,
          'completed_at':
              isCompleted ? null : DateTime.now().millisecondsSinceEpoch,
        },
        where: 'hobby_id = ? AND date = ?',
        whereArgs: [hobbyId, date],
      );
    }
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

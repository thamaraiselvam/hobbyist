import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hobbyist.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocumentsDir.path, filePath);

    return await openDatabase(
      dbPath,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // Enable foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create hobbies table
    await db.execute('''
      CREATE TABLE hobbies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        notes TEXT,
        repeat_mode TEXT NOT NULL DEFAULT 'daily',
        priority TEXT NOT NULL DEFAULT 'medium',
        color INTEGER NOT NULL,
        reminder_time TEXT,
        custom_day INTEGER,
        best_streak INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create completions table
    await db.execute('''
      CREATE TABLE completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hobby_id TEXT NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        completed_at INTEGER,
        FOREIGN KEY (hobby_id) REFERENCES hobbies (id) ON DELETE CASCADE,
        UNIQUE(hobby_id, date)
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_hobbies_created_at ON hobbies(created_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_hobbies_priority ON hobbies(priority)
    ''');

    await db.execute('''
      CREATE INDEX idx_completions_hobby_id ON completions(hobby_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_completions_date ON completions(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_completions_completed ON completions(completed)
    ''');

    await db.execute('''
      CREATE INDEX idx_completions_hobby_date ON completions(hobby_id, date)
    ''');

    // Insert default settings
    await db.insert('settings', {
      'key': 'user_name',
      'value': 'Tham',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    await db.insert('settings', {
      'key': 'push_notifications',
      'value': 'true',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    await db.insert('settings', {
      'key': 'completion_sound',
      'value': 'true',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    await db.insert('settings', {
      'key': 'has_seen_landing',
      'value': 'false',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Privacy-by-default: telemetry OFF by default (FR-022)
    await db.insert('settings', {
      'key': 'telemetry_enabled',
      'value': 'false',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add reminder_time column to hobbies table
      await db.execute('ALTER TABLE hobbies ADD COLUMN reminder_time TEXT');
    }
    if (oldVersion < 3) {
      // Add custom_day column to hobbies table
      await db.execute('ALTER TABLE hobbies ADD COLUMN custom_day INTEGER');
    }
    
    if (oldVersion < 4) {
      // Add best_streak column to hobbies table for tracking max streak (unbounded per FR-014)
      await db.execute('ALTER TABLE hobbies ADD COLUMN best_streak INTEGER NOT NULL DEFAULT 0');
      
      // Calculate and set initial best_streak values for existing hobbies
      print('🔄 Migrating: Calculating best streaks for existing hobbies...');
      final hobbies = await db.query('hobbies');
      for (var hobby in hobbies) {
        final hobbyId = hobby['id'] as String;
        
        // Load completions for this hobby
        final completionsData = await db.query(
          'completions',
          where: 'hobby_id = ? AND completed = 1',
          whereArgs: [hobbyId],
          orderBy: 'date DESC',
        );
        
        // Calculate best streak from completion history
        int maxStreak = 0;
        int currentStreak = 0;
        DateTime? lastDate;
        
        for (var comp in completionsData.reversed) {
          final dateStr = comp['date'] as String;
          final dateParts = dateStr.split('-');
          final date = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          
          if (lastDate == null) {
            currentStreak = 1;
          } else {
            final daysDiff = lastDate.difference(date).inDays;
            if (daysDiff == 1) {
              currentStreak++;
            } else {
              if (currentStreak > maxStreak) maxStreak = currentStreak;
              currentStreak = 1;
            }
          }
          
          lastDate = date;
        }
        
        if (currentStreak > maxStreak) maxStreak = currentStreak;
        
        // Update hobby with calculated best streak
        if (maxStreak > 0) {
          await db.update(
            'hobbies',
            {'best_streak': maxStreak},
            where: 'id = ?',
            whereArgs: [hobbyId],
          );
          print('✅ Set best_streak=$maxStreak for hobby: ${hobby['name']}');
        }
      }
      
      // Add telemetry_enabled setting (default OFF per FR-022 privacy-by-default)
      final telemetryExists = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['telemetry_enabled'],
      );
      if (telemetryExists.isEmpty) {
        await db.insert('settings', {
          'key': 'telemetry_enabled',
          'value': 'false',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('completions');
    await db.delete('hobbies');
    // Reset has_seen_landing to false
    await db.update(
      'settings',
      {
        'value': 'false',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'key = ?',
      whereArgs: ['has_seen_landing'],
    );
  }

  // Get database path for debugging
  Future<String> getDatabasePath() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    return join(appDocumentsDir.path, 'hobbyist.db');
  }
}

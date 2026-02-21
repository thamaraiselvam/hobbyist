// ignore_for_file: avoid_print
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meta/meta.dart';
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

  @visibleForTesting
  static void reset() {
    _database = null;
  }

  Future<Database> _initDB(String filePath) async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocumentsDir.path, filePath);

    return await openDatabase(
      dbPath,
      version: 8,
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
        color INTEGER NOT NULL,
        reminder_time TEXT,
        custom_day INTEGER,
        custom_days TEXT,
        best_streak INTEGER NOT NULL DEFAULT 0,
        is_one_time INTEGER NOT NULL DEFAULT 0,
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

    // Create tasks table (one-time tasks)
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        due_date INTEGER,
        priority TEXT NOT NULL DEFAULT 'medium',
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_hobbies_created_at ON hobbies(created_at)
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

    await db.insert('settings', {
      'key': 'hide_google_signin',
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
      await db.execute(
        'ALTER TABLE hobbies ADD COLUMN best_streak INTEGER NOT NULL DEFAULT 0',
      );

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

    if (oldVersion < 5) {
      // Remove priority column from hobbies table (v5)
      print('🔄 Migrating: Removing priority column...');

      // SQLite doesn't support DROP COLUMN directly, so we need to:
      // 1. Create new table without priority
      // 2. Copy data
      // 3. Drop old table
      // 4. Rename new table

      await db.execute('''
        CREATE TABLE hobbies_new (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          notes TEXT,
          repeat_mode TEXT NOT NULL DEFAULT 'daily',
          color INTEGER NOT NULL,
          reminder_time TEXT,
          custom_day INTEGER,
          best_streak INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        INSERT INTO hobbies_new (id, name, notes, repeat_mode, color, reminder_time, custom_day, best_streak, created_at, updated_at)
        SELECT id, name, notes, repeat_mode, color, reminder_time, custom_day, best_streak, created_at, updated_at
        FROM hobbies
      ''');

      await db.execute('DROP TABLE hobbies');
      await db.execute('ALTER TABLE hobbies_new RENAME TO hobbies');

      // Recreate index without priority
      await db.execute('DROP INDEX IF EXISTS idx_hobbies_priority');
      await db.execute(
        'CREATE INDEX idx_hobbies_created_at ON hobbies(created_at)',
      );

      print('✅ Migration complete: Priority column removed');
    }

    if (oldVersion < 6) {
      // Add tasks table for one-time task management
      print('🔄 Migrating: Adding tasks table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          due_date INTEGER,
          priority TEXT NOT NULL DEFAULT 'medium',
          is_completed INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          completed_at INTEGER
        )
      ''');
      print('✅ Migration complete: tasks table added');
    }

    if (oldVersion < 7) {
      // Add is_one_time column to hobbies table
      print('🔄 Migrating: Adding is_one_time column to hobbies...');
      await db.execute(
        'ALTER TABLE hobbies ADD COLUMN is_one_time INTEGER NOT NULL DEFAULT 0',
      );
      print('✅ Migration complete: is_one_time column added');
    }

    if (oldVersion < 8) {
      // Add custom_days column for weekly multi-select support
      print('🔄 Migrating: Adding custom_days column to hobbies...');
      await db.execute('ALTER TABLE hobbies ADD COLUMN custom_days TEXT');
      // Migrate existing weekly hobbies: wrap single customDay in a JSON array
      await db.execute(
        "UPDATE hobbies SET custom_days = '[' || custom_day || ']' "
        "WHERE repeat_mode = 'weekly' AND custom_day IS NOT NULL",
      );
      print('✅ Migration complete: custom_days column added');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      _database = null;
      await db.close();
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('completions');
    await db.delete('hobbies');
    // Reset has_seen_landing to false
    await db.update(
      'settings',
      {'value': 'false', 'updated_at': DateTime.now().millisecondsSinceEpoch},
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

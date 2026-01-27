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
      version: 1,
      onCreate: _createDB,
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

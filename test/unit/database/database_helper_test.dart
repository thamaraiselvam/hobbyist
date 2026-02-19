import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (MethodCall methodCall) async {
      return '.';
    });
  });

  setUp(() async {
    DatabaseHelper.reset();
    final dbFolder = await databaseFactory.getDatabasesPath();
    final dbFile = File(join(dbFolder, 'hobbyist.db'));
    if (dbFile.existsSync()) dbFile.deleteSync();
    final upgradeFile = File(join(dbFolder, 'hobbyist_upgrade.db'));
    if (upgradeFile.existsSync()) upgradeFile.deleteSync();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('DatabaseHelper Tests', () {
    test('database getter initializes DB', () async {
      final db = await DatabaseHelper.instance.database;
      expect(db, isNotNull);
      expect(db.path, contains('hobbyist.db'));

      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      expect(tableNames, containsAll(['hobbies', 'completions', 'settings']));
    });

    test('clearAllData', () async {
      final db = await DatabaseHelper.instance.database;
      
      // Ensure landing setting exists (it should from _createDB)
      final existingNames = await db.query('settings', where: 'key = ?', whereArgs: ['has_seen_landing']);
      if (existingNames.isEmpty) {
        await db.insert('settings', {'key': 'has_seen_landing', 'value': 'true', 'updated_at': 0});
      }

      // Insert some data
      await db.insert('hobbies', {
        'id': '1',
        'name': 'Hobby 1',
        'color': 0,
        'created_at': 0,
        'updated_at': 0,
      });
      
      await DatabaseHelper.instance.clearAllData();
      
      final hobbies = await db.query('hobbies');
      expect(hobbies, isEmpty);
      
      final setting = await db.query('settings', where: 'key = ?', whereArgs: ['has_seen_landing']);
      expect(setting, isNotEmpty);
      expect(setting.first['value'], 'false');
    });

    test('getDatabasePath', () async {
      final path = await DatabaseHelper.instance.getDatabasePath();
      expect(path, isNotNull);
    });

    test('close', () async {
      await DatabaseHelper.instance.database;
      await DatabaseHelper.instance.close();
      // Should not throw
    });

    test('Database upgrade logic (v1 to v5)', () async {
      final dbFolder = await databaseFactory.getDatabasesPath();
      final dbPath = join(dbFolder, 'hobbyist.db');
      final upgradePath = join(dbFolder, 'hobbyist_upgrade.db');

      // Create version 1 database manually
      final dbV1 = await openDatabase(upgradePath, version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE hobbies (id TEXT PRIMARY KEY, name TEXT NOT NULL, notes TEXT, repeat_mode TEXT NOT NULL DEFAULT "daily", priority INTEGER NOT NULL DEFAULT 0, color INTEGER NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
        await db.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL)');
      });
      await dbV1.close();

      if (File(dbPath).existsSync()) File(dbPath).deleteSync();
      File(upgradePath).copySync(dbPath);

      final db = await DatabaseHelper.instance.database;
      
      // Check if columns from upgrades exist
      final columns = await db.rawQuery('PRAGMA table_info(hobbies)');
      final columnNames = columns.map((c) => c['name'] as String).toList();
      
      expect(columnNames, contains('reminder_time')); // v2
      expect(columnNames, contains('custom_day'));    // v3
      expect(columnNames, contains('best_streak'));   // v4
      
      // Check if telemetry_enabled setting was added
      final telemetry = await db.query('settings', where: 'key = ?', whereArgs: ['telemetry_enabled']);
      expect(telemetry, isNotEmpty);
      
      await DatabaseHelper.instance.close();
      if (File(upgradePath).existsSync()) File(upgradePath).deleteSync();
      if (File(dbPath).existsSync()) File(dbPath).deleteSync();
    });
  });
}

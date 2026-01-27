import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper.instance;
    });

    test('should create database instance', () {
      expect(dbHelper, isNotNull);
    });

    test('should get database', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('should have hobbies table', () async {
      final db = await dbHelper.database;
      final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      final tableNames = tables.map((t) => t['name'] as String).toList();
      expect(tableNames, contains('hobbies'));
    });

    test('should have completions table', () async {
      final db = await dbHelper.database;
      final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      final tableNames = tables.map((t) => t['name'] as String).toList();
      expect(tableNames, contains('completions'));
    });

    test('should have settings table', () async {
      final db = await dbHelper.database;
      final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      final tableNames = tables.map((t) => t['name'] as String).toList();
      expect(tableNames, contains('settings'));
    });

    test('should insert data into hobbies table', () async {
      final db = await dbHelper.database;
      final id = await db.insert('hobbies', {
        'id': 'test-hobby-${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Test Hobby',
        'notes': '',
        'repeat_mode': 'daily',
        'priority': 'medium',
        'color': 0xFF6C3FFF,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      expect(id, greaterThan(0));
    });

    test('should query hobbies table', () async {
      final db = await dbHelper.database;
      final hobbyId = 'test-hobby-${DateTime.now().millisecondsSinceEpoch}';
      
      await db.insert('hobbies', {
        'id': hobbyId,
        'name': 'Test Hobby',
        'notes': '',
        'repeat_mode': 'daily',
        'priority': 'medium',
        'color': 0xFF6C3FFF,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      final hobbies = await db.query('hobbies', where: 'id = ?', whereArgs: [hobbyId]);
      expect(hobbies.length, 1);
      expect(hobbies[0]['name'], 'Test Hobby');
    });

    test('should clear all data', () async {
      final db = await dbHelper.database;
      
      await db.insert('hobbies', {
        'id': 'test-${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Test',
        'notes': '',
        'repeat_mode': 'daily',
        'priority': 'medium',
        'color': 0xFF6C3FFF,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await dbHelper.clearAllData();

      final hobbies = await db.query('hobbies');
      final completions = await db.query('completions');
      final settings = await db.query('settings');

      expect(hobbies, isEmpty);
      expect(completions, isEmpty);
      expect(settings, isEmpty);
    });

    test('should delete database', () async {
      await dbHelper.database;
      await dbHelper.deleteDatabase();
      final newDb = await dbHelper.database;
      expect(newDb, isNotNull);
      expect(newDb.isOpen, true);
    });
  });
}

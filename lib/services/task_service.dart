// ignore_for_file: avoid_print
import 'package:sqflite/sqflite.dart';
import 'package:meta/meta.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskService {
  static TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;

  @visibleForTesting
  static set instance(TaskService value) => _instance = value;

  TaskService._internal() : _dbHelper = DatabaseHelper.instance;

  @visibleForTesting
  TaskService.forTesting({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  /// Load all tasks ordered by creation date descending.
  Future<List<Task>> loadTasks() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query('tasks', orderBy: 'created_at DESC');
      return rows.map(Task.fromMap).toList();
    } catch (e, st) {
      print('❌ TaskService.loadTasks error: $e\n$st');
      rethrow;
    }
  }

  /// Add a new task.
  Future<void> addTask(Task task) async {
    try {
      _validateTask(task);
      final db = await _dbHelper.database;
      await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Task added: ${task.title}');
    } catch (e, st) {
      print('❌ TaskService.addTask error: $e\n$st');
      rethrow;
    }
  }

  /// Update an existing task.
  Future<void> updateTask(Task task) async {
    try {
      _validateTask(task);
      final db = await _dbHelper.database;
      await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      print('✅ Task updated: ${task.title}');
    } catch (e, st) {
      print('❌ TaskService.updateTask error: $e\n$st');
      rethrow;
    }
  }

  /// Delete a task by id.
  Future<void> deleteTask(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
      print('✅ Task deleted: $id');
    } catch (e, st) {
      print('❌ TaskService.deleteTask error: $e\n$st');
      rethrow;
    }
  }

  /// Toggle completion status of a task.
  Future<Task> toggleTask(String id) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) {
        throw Exception('Task not found: $id');
      }
      final current = Task.fromMap(rows.first);
      final updated = current.copyWith(
        isCompleted: !current.isCompleted,
        completedAt: !current.isCompleted ? DateTime.now() : null,
        clearCompletedAt: current.isCompleted,
      );
      await db.update(
        'tasks',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      print(
        '✅ Task toggled: ${updated.title} → ${updated.isCompleted ? "done" : "pending"}',
      );
      return updated;
    } catch (e, st) {
      print('❌ TaskService.toggleTask error: $e\n$st');
      rethrow;
    }
  }

  // ─── Private helpers ────────────────────────────────────────────────────

  /// Validate task fields to prevent bad data from reaching the database.
  void _validateTask(Task task) {
    final sanitizedTitle = task.title.trim();
    if (sanitizedTitle.isEmpty) {
      throw ArgumentError('Task title must not be empty');
    }
    if (sanitizedTitle.length > 200) {
      throw ArgumentError('Task title must be 200 characters or fewer');
    }
    if (task.description.length > 2000) {
      throw ArgumentError('Task description must be 2000 characters or fewer');
    }
  }
}

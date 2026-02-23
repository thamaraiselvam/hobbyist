// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/hobby.dart';
import '../models/task.dart';
import 'hobby_service.dart';
import 'task_service.dart';

/// Data container returned by [pickAndValidateImport] for user confirmation.
class ImportData {
  final int version;
  final String? exportedAt;
  final List<Hobby> hobbies;
  final List<Task> tasks;
  final Map<String, String> settings;
  final String? authMethod;

  int get hobbyCount => hobbies.length;
  int get taskCount => tasks.length;
  int get settingsCount => settings.length;

  ImportData({
    required this.version,
    this.exportedAt,
    required this.hobbies,
    required this.tasks,
    required this.settings,
    this.authMethod,
  });
}

class ImportExportService {
  static final ImportExportService _instance = ImportExportService._internal();
  factory ImportExportService() => _instance;
  ImportExportService._internal();

  static const int _currentVersion = 1;

  final HobbyService _hobbyService = HobbyService();
  final TaskService _taskService = TaskService();

  // ─── EXPORT ──────────────────────────────────────────────────────────────

  /// Collects all app data, writes to a temp JSON file, and opens the
  /// native share sheet.
  Future<void> exportData() async {
    print('📦 Starting data export...');

    // 1. Collect hobbies (includes completions via Hobby.toJson())
    final hobbies = await _hobbyService.loadHobbies();
    final hobbiesJson = hobbies.map((h) => h.toJson()).toList();

    // 2. Collect tasks
    final tasks = await _taskService.loadTasks();
    final tasksJson = tasks.map((t) => t.toJson()).toList();

    // 3. Collect settings from SQLite
    final db = await DatabaseHelper.instance.database;
    final settingsRows = await db.query('settings');
    final Map<String, String> settings = {};
    for (final row in settingsRows) {
      settings[row['key'] as String] = row['value'] as String;
    }

    // 4. Read auth method from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final authMethod = prefs.getString('authMethod');

    // 5. Build export envelope
    final envelope = {
      'version': _currentVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': '1.0.0+30',
      'hobbies': hobbiesJson,
      'tasks': tasksJson,
      'settings': settings,
      'authMethod': authMethod,
    };

    // 6. Write to temp file
    final jsonString = const JsonEncoder.withIndent('  ').convert(envelope);
    final tempDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final filePath = '${tempDir.path}/hobbyist_backup_$dateStr.json';
    final file = File(filePath);
    await file.writeAsString(jsonString);

    print('📦 Export file written: $filePath (${jsonString.length} bytes)');
    print('📦 Hobbies: ${hobbies.length}, Tasks: ${tasks.length}, Settings: ${settings.length}');

    // 7. Open share sheet
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Hobbyist Backup $dateStr',
    );

    print('✅ Export share sheet opened');
  }

  // ─── IMPORT ──────────────────────────────────────────────────────────────

  /// Opens a file picker, reads and validates the selected JSON file.
  /// Returns [ImportData] for user confirmation, or `null` if the user
  /// cancelled the file picker.
  ///
  /// Throws [FormatException] for invalid JSON or missing fields.
  Future<ImportData?> pickAndValidateImport() async {
    print('📥 Opening file picker for import...');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      print('📥 File picker cancelled');
      return null;
    }

    final filePath = result.files.single.path;
    if (filePath == null) {
      throw const FormatException('Could not access the selected file');
    }

    print('📥 File selected: $filePath');

    final file = File(filePath);
    final jsonString = await file.readAsString();

    return validateAndParse(jsonString);
  }

  /// Validates and parses a JSON string into [ImportData].
  /// Separated from file picking for testability.
  ImportData validateAndParse(String jsonString) {
    // 1. Parse JSON
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      throw FormatException('The selected file is not valid JSON: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Not a valid Hobbyist backup file');
    }

    // 2. Check version
    final version = decoded['version'];
    if (version == null || version is! int) {
      throw const FormatException('Not a valid Hobbyist backup file (missing version)');
    }
    if (version > _currentVersion) {
      throw const FormatException(
        'This backup was created by a newer version of Hobbyist. '
        'Please update the app before importing.',
      );
    }

    // 3. Validate hobbies
    final hobbiesList = decoded['hobbies'];
    if (hobbiesList is! List) {
      throw const FormatException('Invalid backup: missing hobbies data');
    }

    // 4. Validate tasks
    final tasksList = decoded['tasks'];
    if (tasksList is! List) {
      throw const FormatException('Invalid backup: missing tasks data');
    }

    // 5. Validate settings
    final settingsMap = decoded['settings'];
    if (settingsMap is! Map) {
      throw const FormatException('Invalid backup: missing settings data');
    }

    // 6. Parse hobbies
    final List<Hobby> hobbies = [];
    for (int i = 0; i < hobbiesList.length; i++) {
      try {
        hobbies.add(Hobby.fromJson(hobbiesList[i] as Map<String, dynamic>));
      } catch (e) {
        throw FormatException('Invalid hobby at index $i: $e');
      }
    }

    // 7. Parse tasks
    final List<Task> tasks = [];
    for (int i = 0; i < tasksList.length; i++) {
      try {
        tasks.add(Task.fromJson(tasksList[i] as Map<String, dynamic>));
      } catch (e) {
        throw FormatException('Invalid task at index $i: $e');
      }
    }

    // 8. Parse settings
    final Map<String, String> settings = {};
    for (final entry in settingsMap.entries) {
      settings[entry.key as String] = entry.value.toString();
    }

    return ImportData(
      version: version,
      exportedAt: decoded['exportedAt'] as String?,
      hobbies: hobbies,
      tasks: tasks,
      settings: settings,
      authMethod: decoded['authMethod'] as String?,
    );
  }

  /// Restores all data from [ImportData], replacing existing data.
  ///
  /// **This is destructive** — all current hobbies, tasks, and settings
  /// will be deleted before importing.
  Future<void> executeImport(ImportData data) async {
    print('📥 Starting data import...');
    print('📥 Hobbies: ${data.hobbyCount}, Tasks: ${data.taskCount}, Settings: ${data.settingsCount}');

    final db = await DatabaseHelper.instance.database;

    // 1. Clear existing data in a transaction (FK order matters)
    await db.transaction((txn) async {
      await txn.delete('completions');
      await txn.delete('tasks');
      await txn.delete('hobbies');
      // Clear settings except device-specific ones
      await txn.delete(
        'settings',
        where: 'key NOT IN (?, ?)',
        whereArgs: ['has_seen_landing', 'telemetry_enabled'],
      );
    });

    print('📥 Existing data cleared');

    // 2. Restore hobbies (addHobby also inserts completions + schedules notifications)
    for (final hobby in data.hobbies) {
      await _hobbyService.addHobby(hobby);
    }
    print('✅ ${data.hobbyCount} hobbies imported');

    // 3. Restore tasks
    for (final task in data.tasks) {
      await _taskService.addTask(task);
    }
    print('✅ ${data.taskCount} tasks imported');

    // 4. Restore settings
    for (final entry in data.settings.entries) {
      // Skip device-specific settings
      if (entry.key == 'has_seen_landing' || entry.key == 'telemetry_enabled') {
        continue;
      }
      await _hobbyService.setSetting(entry.key, entry.value);
    }
    print('✅ Settings imported');

    // 5. Restore auth method in SharedPreferences
    if (data.authMethod != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authMethod', data.authMethod!);
    }

    print('✅ Data import complete');
  }
}

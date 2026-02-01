import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

/// CrashlyticsService - Manages crash reporting and error tracking
/// 
/// This service integrates Firebase Crashlytics to automatically capture
/// crashes, non-fatal errors, and custom logs for debugging production issues.
/// Crash reporting is enabled by default as no PII is collected.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  static FirebaseCrashlytics? _crashlytics;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  factory CrashlyticsService() => _instance;

  CrashlyticsService._internal();

  /// Check if telemetry is enabled (default ON, can be disabled by user)
  Future<bool> _isTelemetryEnabled() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['telemetry_enabled'],
      );
      if (result.isEmpty) return true; // Default ON
      return result.first['value'] != 'false'; // Only false if explicitly disabled
    } catch (e) {
      print('⚠️ Failed to check telemetry setting: $e');
      return true; // Default ON
    }
  }

  /// Initialize Crashlytics
  static Future<void> initialize() async {
    _crashlytics = FirebaseCrashlytics.instance;

    // Pass all uncaught errors from Flutter framework to Crashlytics
    FlutterError.onError = _crashlytics!.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics!.recordError(error, stack, fatal: true);
      return true;
    };

    // Default ON - analytics and crash reports enabled by default
    // User can disable in settings
    await _crashlytics!.setCrashlyticsCollectionEnabled(true);

    print('🔥 Crashlytics initialized (enabled by default)');
  }
  
  /// Update Crashlytics collection based on telemetry setting
  Future<void> updateCollectionEnabled() async {
    final enabled = await _isTelemetryEnabled();
    await _crashlytics?.setCrashlyticsCollectionEnabled(enabled);
    print('🔥 Crashlytics collection: ${enabled ? "ENABLED" : "DISABLED"}');
  }

  /// Log a non-fatal error
  Future<void> logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!await _isTelemetryEnabled()) return;
    await _crashlytics?.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Log a message to Crashlytics
  Future<void> log(String message) async {
    if (!await _isTelemetryEnabled()) return;
    _crashlytics?.log(message);
  }

  /// Set custom key-value pairs for crash context
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!await _isTelemetryEnabled()) return;
    _crashlytics?.setCustomKey(key, value);
  }

  /// Set user identifier (use anonymous ID, not PII)
  Future<void> setUserIdentifier(String identifier) async {
    if (!await _isTelemetryEnabled()) return;
    _crashlytics?.setUserIdentifier(identifier);
  }

  /// Force a test crash (for testing only)
  void forceCrash() {
    _crashlytics?.crash();
  }

  /// Check if Crashlytics is enabled
  bool isCrashlyticsCollectionEnabled() {
    return _crashlytics?.isCrashlyticsCollectionEnabled ?? false;
  }
}

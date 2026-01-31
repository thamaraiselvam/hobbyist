import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// CrashlyticsService - Manages crash reporting and error tracking
/// 
/// This service integrates Firebase Crashlytics to automatically capture
/// crashes, non-fatal errors, and custom logs for debugging production issues.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  static FirebaseCrashlytics? _crashlytics;

  factory CrashlyticsService() => _instance;

  CrashlyticsService._internal();

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

    // In debug mode, don't send crash reports
    if (kDebugMode) {
      await _crashlytics!.setCrashlyticsCollectionEnabled(false);
    } else {
      await _crashlytics!.setCrashlyticsCollectionEnabled(true);
    }

    print('🔥 Crashlytics initialized');
  }

  /// Log a non-fatal error
  Future<void> logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics?.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Log a message to Crashlytics
  void log(String message) {
    _crashlytics?.log(message);
  }

  /// Set custom key-value pairs for crash context
  void setCustomKey(String key, dynamic value) {
    _crashlytics?.setCustomKey(key, value);
  }

  /// Set user identifier (use anonymous ID, not PII)
  void setUserIdentifier(String identifier) {
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

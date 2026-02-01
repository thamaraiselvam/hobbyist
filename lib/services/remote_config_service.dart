// ignore_for_file: avoid_print
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// RemoteConfigService - Manages feature flags and remote configuration
///
/// This service integrates Firebase Remote Config to enable/disable features
/// remotely without app updates, and perform A/B testing.
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  static FirebaseRemoteConfig? _remoteConfig;

  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  static FirebaseRemoteConfig? mockRemoteConfig;

  /// Initialize Remote Config with default values
  static Future<void> initialize() async {
    if (mockRemoteConfig != null) {
      _remoteConfig = mockRemoteConfig;
      return;
    }
    _remoteConfig = FirebaseRemoteConfig.instance;

    // Set default values
    await _remoteConfig!.setDefaults({
      // Feature flags
      'enable_analytics_screen': true,
      'enable_notifications': true,
      'enable_sound_feedback': true,
      'enable_streak_milestones': true,

      // UI Configuration
      'show_motivational_quotes': true,
      'max_hobbies_limit': 50,
      'default_theme_mode': 'dark',

      // Performance settings
      'cache_duration_hours': 12,
      'fetch_timeout_seconds': 60,

      // Feature limits (removed max_streak_days - streaks are unbounded per spec FR-014)
      'enable_premium_features': false,

      // A/B Testing
      'onboarding_flow_version': 'v1',
      'completion_animation_style': 'default',

      // Developer settings - email-based feature flags (using different name)
      'allow_developer_settings': '{"feature_access_by_email":{}}',
    });

    // Configure fetch and cache settings
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 60),
      minimumFetchInterval:
          Duration.zero, // Fetch on every app launch (development mode)
    ));

    // Fetch and activate new values
    try {
      final activated = await _remoteConfig!.fetchAndActivate();
      print('🔧 Remote Config fetch status: ${_remoteConfig!.lastFetchStatus}');
      print('🔧 Remote Config activated: $activated');

      // Debug: Print actual value of allow_developer_settings
      final devSettings = _remoteConfig!.getString('allow_developer_settings');
      print(
          '🔧 allow_developer_settings value: ${devSettings.isEmpty ? "(empty)" : devSettings.substring(0, devSettings.length > 100 ? 100 : devSettings.length)}...');

      print('🔧 Remote Config initialized and activated');
    } catch (e) {
      print('⚠️ Remote Config fetch failed: $e (using defaults)');
    }
  }

  /// Fetch latest config from server
  Future<bool> fetchConfig() async {
    try {
      final activated = await _remoteConfig!.fetchAndActivate();
      return activated;
    } catch (e) {
      print('Error fetching remote config: $e');
      return false;
    }
  }

  // =====================================
  // Feature Flags
  // =====================================

  /// Check if analytics screen is enabled
  bool get isAnalyticsScreenEnabled {
    return _remoteConfig?.getBool('enable_analytics_screen') ?? true;
  }

  /// Check if notifications are enabled
  bool get areNotificationsEnabled {
    return _remoteConfig?.getBool('enable_notifications') ?? true;
  }

  /// Check if sound feedback is enabled
  bool get isSoundFeedbackEnabled {
    return _remoteConfig?.getBool('enable_sound_feedback') ?? true;
  }

  /// Check if streak milestones are enabled
  bool get areStreakMilestonesEnabled {
    return _remoteConfig?.getBool('enable_streak_milestones') ?? true;
  }

  /// Check if motivational quotes are enabled
  bool get showMotivationalQuotes {
    return _remoteConfig?.getBool('show_motivational_quotes') ?? true;
  }

  /// Check if premium features are enabled
  bool get arePremiumFeaturesEnabled {
    return _remoteConfig?.getBool('enable_premium_features') ?? false;
  }

  // =====================================
  // Configuration Values
  // =====================================

  /// Get maximum number of hobbies allowed
  int get maxHobbiesLimit {
    return _remoteConfig?.getInt('max_hobbies_limit') ?? 50;
  }

  /// Get default theme mode
  String get defaultThemeMode {
    return _remoteConfig?.getString('default_theme_mode') ?? 'dark';
  }

  /// Get cache duration in hours
  int get cacheDurationHours {
    return _remoteConfig?.getInt('cache_duration_hours') ?? 12;
  }

  /// Get maximum streak days
  int get maxStreakDays {
    return _remoteConfig?.getInt('max_streak_days') ?? 365;
  }

  /// Get onboarding flow version for A/B testing
  String get onboardingFlowVersion {
    return _remoteConfig?.getString('onboarding_flow_version') ?? 'v1';
  }

  /// Get completion animation style
  String get completionAnimationStyle {
    return _remoteConfig?.getString('completion_animation_style') ?? 'default';
  }

  // =====================================
  // Utility Methods
  // =====================================

  /// Get all config keys
  Set<String> getAllKeys() {
    return _remoteConfig?.getAll().keys.toSet() ?? {};
  }

  /// Get a custom string value
  String getString(String key, {String defaultValue = ''}) {
    return _remoteConfig?.getString(key) ?? defaultValue;
  }

  /// Get a custom int value
  int getInt(String key, {int defaultValue = 0}) {
    return _remoteConfig?.getInt(key) ?? defaultValue;
  }

  /// Get a custom bool value
  bool getBool(String key, {bool defaultValue = false}) {
    return _remoteConfig?.getBool(key) ?? defaultValue;
  }

  /// Get a custom double value
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _remoteConfig?.getDouble(key) ?? defaultValue;
  }

  /// Get config fetch status
  RemoteConfigFetchStatus get fetchStatus {
    return _remoteConfig?.lastFetchStatus ?? RemoteConfigFetchStatus.noFetchYet;
  }

  /// Get last fetch time
  DateTime? get lastFetchTime {
    return _remoteConfig?.lastFetchTime;
  }
}

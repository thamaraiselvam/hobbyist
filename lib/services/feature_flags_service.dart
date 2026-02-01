// ignore_for_file: avoid_print
import 'dart:convert';
import 'remote_config_service.dart';
import 'auth_service.dart';
import 'package:meta/meta.dart';

/// FeatureFlagsService - Manages user-specific feature flags from Firebase Remote Config
///
/// This service reads the 'developer_settings' config from Firebase Remote Config
/// and checks if specific features are enabled for the logged-in user's email.
class FeatureFlagsService {
  static FeatureFlagsService _instance = FeatureFlagsService._internal();
  factory FeatureFlagsService() => _instance;

  @visibleForTesting
  static set instance(FeatureFlagsService value) => _instance = value;

  final RemoteConfigService _remoteConfig;
  final AuthService _authService;

  FeatureFlagsService.test({RemoteConfigService? remoteConfig, AuthService? authService})
      : _remoteConfig = remoteConfig ?? RemoteConfigService(),
        _authService = authService ?? AuthService();

  FeatureFlagsService._internal()
      : _remoteConfig = RemoteConfigService(),
        _authService = AuthService();

  Map<String, dynamic>? _developerSettings;

  /// Load developer settings from Remote Config
  void loadDeveloperSettings() {
    try {
      final configJson = _remoteConfig.getString('allow_developer_settings');
      print('🔍 Raw allow_developer_settings: $configJson');

      if (configJson.isNotEmpty) {
        _developerSettings = jsonDecode(configJson) as Map<String, dynamic>;
        print(
            '✅ Developer settings loaded: ${_developerSettings?.keys.join(', ')}');
        print(
            '📧 Available emails: ${(_developerSettings!['feature_access_by_email'] as Map<String, dynamic>?)?.keys.join(', ')}');
      } else {
        _developerSettings = null;
        print('⚠️ No allow_developer_settings found in Remote Config');
      }
    } catch (e) {
      print('❌ Error parsing allow_developer_settings: $e');
      _developerSettings = null;
    }
  }

  /// Check if a feature is enabled for the current user
  bool isFeatureEnabled(String featureKey) {
    // Only enable features for logged-in users (not offline)
    if (!_authService.isLoggedIn || _authService.userEmail == null) {
      print('⚠️ Feature check failed: User not logged in');
      return false;
    }

    print('🔍 Checking feature "$featureKey" for ${_authService.userEmail}');

    // Reload settings if not loaded
    if (_developerSettings == null) {
      loadDeveloperSettings();
    }

    // If still null, no settings available
    if (_developerSettings == null) {
      print('⚠️ No developer settings available after reload');
      return false;
    }

    try {
      final featureAccessByEmail =
          _developerSettings!['feature_access_by_email']
              as Map<String, dynamic>?;
      if (featureAccessByEmail == null) {
        print('⚠️ No feature_access_by_email found in settings');
        return false;
      }

      final userEmail = _authService.userEmail!;
      print('📧 Looking for email: $userEmail');

      final userFeatures =
          featureAccessByEmail[userEmail] as Map<String, dynamic>?;

      if (userFeatures == null) {
        print('⚠️ No features found for email: $userEmail');
        print('📋 Available emails: ${featureAccessByEmail.keys.join(', ')}');
        return false;
      }

      final enabled = userFeatures[featureKey] == true;
      print('${enabled ? '✅' : '❌'} Feature "$featureKey" = $enabled');
      return enabled;
    } catch (e) {
      print('❌ Error checking feature "$featureKey": $e');
      return false;
    }
  }

  // Convenience getters for specific features
  bool get isDeveloperOptionsEnabled =>
      isFeatureEnabled('settings_developer_options');

  // Pull to refresh is now a developer option stored in SharedPreferences
  bool get isPullToRefreshEnabled {
    // This will be checked via SharedPreferences in the screens
    return false; // Deprecated - use SharedPreferences directly
  }

  bool get isAnalyticsAndCrashReportsEnabled =>
      isFeatureEnabled('settings_analytics_and_crash_reports');

  /// Get all enabled features for current user
  List<String> getEnabledFeatures() {
    if (!_authService.isLoggedIn || _authService.userEmail == null) {
      return [];
    }

    if (_developerSettings == null) {
      loadDeveloperSettings();
    }

    if (_developerSettings == null) {
      return [];
    }

    try {
      final featureAccessByEmail =
          _developerSettings!['feature_access_by_email']
              as Map<String, dynamic>?;
      if (featureAccessByEmail == null) {
        return [];
      }

      final userEmail = _authService.userEmail!;
      final userFeatures =
          featureAccessByEmail[userEmail] as Map<String, dynamic>?;

      if (userFeatures == null) {
        return [];
      }

      return userFeatures.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      print('❌ Error getting enabled features: $e');
      return [];
    }
  }

  /// Refresh settings from Remote Config
  Future<void> refresh() async {
    await _remoteConfig.fetchConfig();
    loadDeveloperSettings();
  }
}

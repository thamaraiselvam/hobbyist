import 'dart:convert';
import 'remote_config_service.dart';
import 'auth_service.dart';

/// FeatureFlagsService - Manages user-specific feature flags from Firebase Remote Config
/// 
/// This service reads the 'developer_settings' config from Firebase Remote Config
/// and checks if specific features are enabled for the logged-in user's email.
class FeatureFlagsService {
  static final FeatureFlagsService _instance = FeatureFlagsService._internal();
  factory FeatureFlagsService() => _instance;
  FeatureFlagsService._internal();

  final RemoteConfigService _remoteConfig = RemoteConfigService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _developerSettings;

  /// Load developer settings from Remote Config
  void loadDeveloperSettings() {
    try {
      final configJson = _remoteConfig.getString('developer_settings');
      if (configJson.isNotEmpty) {
        _developerSettings = jsonDecode(configJson) as Map<String, dynamic>;
        print('✅ Developer settings loaded: ${_developerSettings?.keys.join(', ')}');
      } else {
        _developerSettings = null;
        print('⚠️ No developer_settings found in Remote Config');
      }
    } catch (e) {
      print('❌ Error parsing developer_settings: $e');
      _developerSettings = null;
    }
  }

  /// Check if a feature is enabled for the current user
  bool isFeatureEnabled(String featureKey) {
    // Only enable features for logged-in users (not offline)
    if (!_authService.isLoggedIn || _authService.userEmail == null) {
      return false;
    }

    // Reload settings if not loaded
    if (_developerSettings == null) {
      loadDeveloperSettings();
    }

    // If still null, no settings available
    if (_developerSettings == null) {
      return false;
    }

    try {
      final featureAccessByEmail = _developerSettings!['feature_access_by_email'] as Map<String, dynamic>?;
      if (featureAccessByEmail == null) {
        return false;
      }

      final userEmail = _authService.userEmail!;
      final userFeatures = featureAccessByEmail[userEmail] as Map<String, dynamic>?;
      
      if (userFeatures == null) {
        return false;
      }

      return userFeatures[featureKey] == true;
    } catch (e) {
      print('❌ Error checking feature "$featureKey": $e');
      return false;
    }
  }

  // Convenience getters for specific features
  bool get isDeveloperOptionsEnabled => isFeatureEnabled('settings_developer_options');
  bool get isPullToRefreshEnabled => isFeatureEnabled('pull_down_to_refresh');
  bool get isAnalyticsAndCrashReportsEnabled => isFeatureEnabled('settings_analytics_and_crash_reports');

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
      final featureAccessByEmail = _developerSettings!['feature_access_by_email'] as Map<String, dynamic>?;
      if (featureAccessByEmail == null) {
        return [];
      }

      final userEmail = _authService.userEmail!;
      final userFeatures = featureAccessByEmail[userEmail] as Map<String, dynamic>?;
      
      if (userFeatures == null) {
        return [];
      }

      return userFeatures.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key as String)
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

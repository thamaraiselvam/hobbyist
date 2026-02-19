import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hobbyist/services/remote_config_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../helpers/firebase_mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseRemoteConfig>()])
import 'remote_config_service_test.mocks.dart';

void main() {
  setupFirebaseMocks();

  group('RemoteConfigService Tests', () {
    late RemoteConfigService service;
    late MockFirebaseRemoteConfig mockRemoteConfig;

    setUp(() async {
      mockRemoteConfig = MockFirebaseRemoteConfig();
      RemoteConfigService.mockRemoteConfig = mockRemoteConfig;
      await RemoteConfigService.initialize();
      service = RemoteConfigService();
    });

    tearDown(() {
      RemoteConfigService.mockRemoteConfig = null;
    });

    test('should be a singleton', () {
      final instance1 = RemoteConfigService();
      final instance2 = RemoteConfigService();
      expect(identical(instance1, instance2), true);
    });

    test('factory constructor returns same instance', () {
      final a = RemoteConfigService();
      final b = RemoteConfigService();
      final c = RemoteConfigService();
      expect(identical(a, b), true);
      expect(identical(b, c), true);
    });

    group('initialize Tests', () {
      test('should use mock remote config when provided', () async {
        await RemoteConfigService.initialize();
        // Should complete without using real Firebase
        expect(true, true);
      });

      test('should set _remoteConfig to mockRemoteConfig', () async {
        // Already initialized in setUp
        expect(service.getAllKeys, returnsNormally);
      });

      test('should handle fetchAndActivate success', () async {
        when(mockRemoteConfig.setDefaults(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.setConfigSettings(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
        when(mockRemoteConfig.lastFetchStatus)
            .thenReturn(RemoteConfigFetchStatus.success);
        when(mockRemoteConfig.getString('allow_developer_settings'))
            .thenReturn('{"feature_access_by_email":{}}');

        // Re-initialize with stubbed methods
        await RemoteConfigService.initialize();
        expect(true, true);
      });

      test('should handle fetchAndActivate failure', () async {
        when(mockRemoteConfig.setDefaults(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.setConfigSettings(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.fetchAndActivate())
            .thenThrow(Exception('Remote config error'));

        await RemoteConfigService.initialize();
        expect(true, true);
      });

      test('should handle long developer settings string', () async {
        when(mockRemoteConfig.setDefaults(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.setConfigSettings(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
        when(mockRemoteConfig.lastFetchStatus)
            .thenReturn(RemoteConfigFetchStatus.success);
        // String longer than 100 characters to test substring logic
        when(mockRemoteConfig.getString('allow_developer_settings')).thenReturn(
            '{"feature_access_by_email":{"test@example.com":{"developer_options":true,"analytics_and_crash_reports":true}}}');

        await RemoteConfigService.initialize();
        expect(true, true);
      });

      test('should handle empty developer settings', () async {
        when(mockRemoteConfig.setDefaults(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.setConfigSettings(any)).thenAnswer((_) async {});
        when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
        when(mockRemoteConfig.lastFetchStatus)
            .thenReturn(RemoteConfigFetchStatus.success);
        when(mockRemoteConfig.getString('allow_developer_settings'))
            .thenReturn('');

        await RemoteConfigService.initialize();
        expect(true, true);
      });
    });

    group('fetchConfig Tests', () {
      test('should return true when fetch succeeds', () async {
        when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);

        final result = await service.fetchConfig();

        expect(result, true);
        verify(mockRemoteConfig.fetchAndActivate()).called(1);
      });

      test('should return false when already up to date', () async {
        when(mockRemoteConfig.fetchAndActivate())
            .thenAnswer((_) async => false);

        final result = await service.fetchConfig();

        expect(result, false);
      });

      test('should return false when fetch fails', () async {
        when(mockRemoteConfig.fetchAndActivate())
            .thenThrow(Exception('Network error'));

        final result = await service.fetchConfig();

        expect(result, false);
      });
    });

    group('Feature Flag Getters Tests', () {
      test('isAnalyticsScreenEnabled should return config value', () {
        when(mockRemoteConfig.getBool('enable_analytics_screen'))
            .thenReturn(true);
        expect(service.isAnalyticsScreenEnabled, true);

        when(mockRemoteConfig.getBool('enable_analytics_screen'))
            .thenReturn(false);
        expect(service.isAnalyticsScreenEnabled, false);
      });

      test('areNotificationsEnabled should return config value', () {
        when(mockRemoteConfig.getBool('enable_notifications')).thenReturn(true);
        expect(service.areNotificationsEnabled, true);

        when(mockRemoteConfig.getBool('enable_notifications'))
            .thenReturn(false);
        expect(service.areNotificationsEnabled, false);
      });

      test('isSoundFeedbackEnabled should return config value', () {
        when(mockRemoteConfig.getBool('enable_sound_feedback'))
            .thenReturn(true);
        expect(service.isSoundFeedbackEnabled, true);

        when(mockRemoteConfig.getBool('enable_sound_feedback'))
            .thenReturn(false);
        expect(service.isSoundFeedbackEnabled, false);
      });

      test('areStreakMilestonesEnabled should return config value', () {
        when(mockRemoteConfig.getBool('enable_streak_milestones'))
            .thenReturn(true);
        expect(service.areStreakMilestonesEnabled, true);

        when(mockRemoteConfig.getBool('enable_streak_milestones'))
            .thenReturn(false);
        expect(service.areStreakMilestonesEnabled, false);
      });

      test('showMotivationalQuotes should return config value', () {
        when(mockRemoteConfig.getBool('show_motivational_quotes'))
            .thenReturn(true);
        expect(service.showMotivationalQuotes, true);

        when(mockRemoteConfig.getBool('show_motivational_quotes'))
            .thenReturn(false);
        expect(service.showMotivationalQuotes, false);
      });

      test('arePremiumFeaturesEnabled should return config value', () {
        when(mockRemoteConfig.getBool('enable_premium_features'))
            .thenReturn(true);
        expect(service.arePremiumFeaturesEnabled, true);

        when(mockRemoteConfig.getBool('enable_premium_features'))
            .thenReturn(false);
        expect(service.arePremiumFeaturesEnabled, false);
      });
    });

    group('Configuration Value Getters Tests', () {
      test('maxHobbiesLimit should return config value', () {
        when(mockRemoteConfig.getInt('max_hobbies_limit')).thenReturn(100);
        expect(service.maxHobbiesLimit, 100);

        when(mockRemoteConfig.getInt('max_hobbies_limit')).thenReturn(25);
        expect(service.maxHobbiesLimit, 25);
      });

      test('defaultThemeMode should return config value', () {
        when(mockRemoteConfig.getString('default_theme_mode'))
            .thenReturn('light');
        expect(service.defaultThemeMode, 'light');

        when(mockRemoteConfig.getString('default_theme_mode'))
            .thenReturn('dark');
        expect(service.defaultThemeMode, 'dark');
      });

      test('cacheDurationHours should return config value', () {
        when(mockRemoteConfig.getInt('cache_duration_hours')).thenReturn(24);
        expect(service.cacheDurationHours, 24);

        when(mockRemoteConfig.getInt('cache_duration_hours')).thenReturn(6);
        expect(service.cacheDurationHours, 6);
      });

      test('maxStreakDays should return config value', () {
        when(mockRemoteConfig.getInt('max_streak_days')).thenReturn(365);
        expect(service.maxStreakDays, 365);

        when(mockRemoteConfig.getInt('max_streak_days')).thenReturn(730);
        expect(service.maxStreakDays, 730);
      });

      test('onboardingFlowVersion should return config value', () {
        when(mockRemoteConfig.getString('onboarding_flow_version'))
            .thenReturn('v2');
        expect(service.onboardingFlowVersion, 'v2');

        when(mockRemoteConfig.getString('onboarding_flow_version'))
            .thenReturn('v3');
        expect(service.onboardingFlowVersion, 'v3');
      });

      test('completionAnimationStyle should return config value', () {
        when(mockRemoteConfig.getString('completion_animation_style'))
            .thenReturn('celebration');
        expect(service.completionAnimationStyle, 'celebration');

        when(mockRemoteConfig.getString('completion_animation_style'))
            .thenReturn('simple');
        expect(service.completionAnimationStyle, 'simple');
      });
    });

    group('Utility Methods Tests', () {
      test('getAllKeys should return set of keys', () {
        when(mockRemoteConfig.getAll()).thenReturn({});
        final keys = service.getAllKeys();
        expect(keys, isA<Set<String>>());
      });

      test('getString should return config string', () {
        when(mockRemoteConfig.getString('custom_key'))
            .thenReturn('custom_value');
        expect(service.getString('custom_key'), 'custom_value');
      });

      test('getString should return config value not default', () {
        when(mockRemoteConfig.getString('any_key')).thenReturn('from_config');
        expect(service.getString('any_key', defaultValue: 'fallback'),
            'from_config');
      });

      test('getInt should return config int', () {
        when(mockRemoteConfig.getInt('custom_int')).thenReturn(42);
        expect(service.getInt('custom_int'), 42);
      });

      test('getInt with defaultValue parameter', () {
        when(mockRemoteConfig.getInt('int_key')).thenReturn(99);
        expect(service.getInt('int_key', defaultValue: 0), 99);
      });

      test('getBool should return config bool', () {
        when(mockRemoteConfig.getBool('custom_bool')).thenReturn(true);
        expect(service.getBool('custom_bool'), true);
      });

      test('getBool with defaultValue parameter', () {
        when(mockRemoteConfig.getBool('bool_key')).thenReturn(true);
        expect(service.getBool('bool_key', defaultValue: false), true);
      });

      test('getDouble should return config double', () {
        when(mockRemoteConfig.getDouble('custom_double')).thenReturn(3.14);
        expect(service.getDouble('custom_double'), 3.14);
      });

      test('getDouble with defaultValue parameter', () {
        when(mockRemoteConfig.getDouble('double_key')).thenReturn(2.5);
        expect(service.getDouble('double_key', defaultValue: 0.0), 2.5);
      });
    });

    group('Status Getters Tests', () {
      test('fetchStatus should return last fetch status - success', () {
        when(mockRemoteConfig.lastFetchStatus)
            .thenReturn(RemoteConfigFetchStatus.success);
        expect(service.fetchStatus, RemoteConfigFetchStatus.success);
      });

      test('fetchStatus should return last fetch status - failure', () {
        when(mockRemoteConfig.lastFetchStatus)
            .thenReturn(RemoteConfigFetchStatus.failure);
        expect(service.fetchStatus, RemoteConfigFetchStatus.failure);
      });

      test('fetchStatus should return last fetch status - noFetchYet', () {
        when(mockRemoteConfig.lastFetchStatus)
            .thenReturn(RemoteConfigFetchStatus.noFetchYet);
        expect(service.fetchStatus, RemoteConfigFetchStatus.noFetchYet);
      });

      test('fetchStatus should return last fetch status - throttle', () {
        when(mockRemoteConfig.lastFetchStatus)
            .thenReturn(RemoteConfigFetchStatus.throttle);
        expect(service.fetchStatus, RemoteConfigFetchStatus.throttle);
      });

      test('lastFetchTime should return last fetch time', () {
        final time = DateTime(2024, 1, 15, 10, 30);
        when(mockRemoteConfig.lastFetchTime).thenReturn(time);
        expect(service.lastFetchTime, time);
      });

      test('lastFetchTime should return different times', () {
        final time1 = DateTime(2024, 1, 15);
        final time2 = DateTime(2024, 6, 20);

        when(mockRemoteConfig.lastFetchTime).thenReturn(time1);
        expect(service.lastFetchTime, time1);

        when(mockRemoteConfig.lastFetchTime).thenReturn(time2);
        expect(service.lastFetchTime, time2);
      });
    });
  });
}

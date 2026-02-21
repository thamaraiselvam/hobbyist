import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/feature_flags_service.dart';
import 'package:hobbyist/services/remote_config_service.dart';
import 'package:hobbyist/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';

@GenerateNiceMocks([MockSpec<RemoteConfigService>(), MockSpec<AuthService>()])
import 'feature_flags_service_test.mocks.dart';

void main() {
  late FeatureFlagsService service;
  late MockRemoteConfigService mockRemoteConfig;
  late MockAuthService mockAuth;

  setUp(() {
    mockRemoteConfig = MockRemoteConfigService();
    mockAuth = MockAuthService();
    service = FeatureFlagsService.test(
      remoteConfig: mockRemoteConfig,
      authService: mockAuth,
    );
    FeatureFlagsService.instance = service;
  });

  group('FeatureFlagsService Tests', () {
    test('Singleton check', () {
      expect(FeatureFlagsService(), same(FeatureFlagsService()));
    });

    test('isFeatureEnabled when not logged in', () {
      when(mockAuth.isLoggedIn).thenReturn(false);
      expect(service.isFeatureEnabled('any'), false);
    });

    test('isFeatureEnabled when logged in but no config', () {
      when(mockAuth.isLoggedIn).thenReturn(true);
      when(mockAuth.userEmail).thenReturn('test@example.com');
      when(
        mockRemoteConfig.getString('allow_developer_settings'),
      ).thenReturn('');

      expect(service.isFeatureEnabled('any'), false);
    });

    test('isFeatureEnabled with valid config', () {
      final config = {
        'feature_access_by_email': {
          'test@example.com': {'feat_1': true, 'feat_2': false},
        },
      };

      when(mockAuth.isLoggedIn).thenReturn(true);
      when(mockAuth.userEmail).thenReturn('test@example.com');
      when(
        mockRemoteConfig.getString('allow_developer_settings'),
      ).thenReturn(jsonEncode(config));

      expect(service.isFeatureEnabled('feat_1'), true);
      expect(service.isFeatureEnabled('feat_2'), false);
      expect(service.isFeatureEnabled('feat_3'), false); // not in list
    });

    test('getEnabledFeatures', () {
      final config = {
        'feature_access_by_email': {
          'test@example.com': {'feat_1': true, 'feat_2': false, 'feat_3': true},
        },
      };

      when(mockAuth.isLoggedIn).thenReturn(true);
      when(mockAuth.userEmail).thenReturn('test@example.com');
      when(
        mockRemoteConfig.getString('allow_developer_settings'),
      ).thenReturn(jsonEncode(config));

      final enabled = service.getEnabledFeatures();
      expect(enabled, containsAll(['feat_1', 'feat_3']));
      expect(enabled, isNot(contains('feat_2')));
    });

    test('Convenience getters', () {
      final config = {
        'feature_access_by_email': {
          'test@example.com': {
            'settings_developer_options': true,
            'settings_analytics_and_crash_reports': false,
          },
        },
      };

      when(mockAuth.isLoggedIn).thenReturn(true);
      when(mockAuth.userEmail).thenReturn('test@example.com');
      when(
        mockRemoteConfig.getString('allow_developer_settings'),
      ).thenReturn(jsonEncode(config));

      expect(service.isDeveloperOptionsEnabled, true);
      expect(service.isAnalyticsAndCrashReportsEnabled, false);
      expect(service.isPullToRefreshEnabled, false); // Deprecated
    });

    test('refresh calls remoteConfig', () async {
      when(mockRemoteConfig.fetchConfig()).thenAnswer((_) async => true);
      await service.refresh();
      verify(mockRemoteConfig.fetchConfig()).called(1);
    });

    test('Error handling in loadDeveloperSettings', () {
      when(
        mockRemoteConfig.getString('allow_developer_settings'),
      ).thenReturn('invalid json');

      // Should not throw, just set settings to null
      service.loadDeveloperSettings();
      when(mockAuth.isLoggedIn).thenReturn(true);
      when(mockAuth.userEmail).thenReturn('test@example.com');
      expect(service.isFeatureEnabled('any'), false);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/sound_service.dart';
import 'package:hobbyist/services/hobby_service.dart';
import 'package:hobbyist/services/analytics_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/services.dart';

@GenerateNiceMocks([
  MockSpec<HobbyService>(),
  MockSpec<AnalyticsService>(),
])
import 'sound_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SoundService soundService;
  late MockHobbyService mockHobbyService;
  late MockAnalyticsService mockAnalyticsService;
  final List<MethodCall> hapticCalls = <MethodCall>[];

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform,
            (MethodCall methodCall) async {
      if (methodCall.method == 'HapticFeedback.vibrate') {
        hapticCalls.add(methodCall);
      }
      return null;
    });
  });

  setUp(() {
    mockHobbyService = MockHobbyService();
    mockAnalyticsService = MockAnalyticsService();
    hapticCalls.clear();
    soundService = SoundService.test(
      hobbyService: mockHobbyService,
      analytics: mockAnalyticsService,
    );
  });

  group('SoundService Tests', () {
    test('Singleton check', () {
      expect(SoundService(), same(SoundService()));
    });

    test('Instance setter check', () {
      final oldInstance = SoundService();
      final newInstance = SoundService.test();
      SoundService.instance = newInstance;
      expect(SoundService(), same(newInstance));
      // Restore
      SoundService.instance = oldInstance;
    });

    test('Constructor with default parameters', () {
      final service = SoundService.test();
      expect(service, isNotNull);
    });

    test('playCompletionSound when enabled', () async {
      when(mockHobbyService.getSetting('completion_sound'))
          .thenAnswer((_) async => 'true');

      await soundService.playCompletionSound();

      // HapticFeedback.mediumImpact() and HapticFeedback.lightImpact()
      expect(hapticCalls.length, 2);
      expect(hapticCalls[0].method, 'HapticFeedback.vibrate');
      expect(hapticCalls[0].arguments, 'HapticFeedbackType.mediumImpact');
      expect(hapticCalls[1].method, 'HapticFeedback.vibrate');
      expect(hapticCalls[1].arguments, 'HapticFeedbackType.lightImpact');

      verify(mockAnalyticsService.logCompletionSound()).called(1);
    });

    test('playCompletionSound when disabled', () async {
      when(mockHobbyService.getSetting('completion_sound'))
          .thenAnswer((_) async => 'false');

      await soundService.playCompletionSound();

      expect(hapticCalls.isEmpty, true);
      verifyNever(mockAnalyticsService.logCompletionSound());
    });

    test('playCompletionSound when setting is null (default enabled)',
        () async {
      when(mockHobbyService.getSetting('completion_sound'))
          .thenAnswer((_) async => null);

      await soundService.playCompletionSound();

      expect(hapticCalls.length, 2);
    });

    test('Error handling in playCompletionSound', () async {
      when(mockHobbyService.getSetting('completion_sound'))
          .thenThrow(Exception('DB Error'));

      // Should not throw because of try-catch in SoundService
      await expectLater(soundService.playCompletionSound(), completes);
      expect(hapticCalls.isEmpty, true);
    });

    test('Error handling in _playHapticFeedback', () async {
      when(mockHobbyService.getSetting('completion_sound'))
          .thenAnswer((_) async => 'true');

      // Force error in haptics by setting a failing handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/platform'),
              (MethodCall methodCall) async {
        if (methodCall.method.startsWith('HapticFeedback.')) {
          throw Exception('Haptic Error');
        }
        return null;
      });

      await expectLater(soundService.playCompletionSound(), completes);

      // Restore handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/platform'),
              (MethodCall methodCall) async {
        if (methodCall.method.startsWith('HapticFeedback.')) {
          hapticCalls.add(methodCall);
        }
        return null;
      });
    });

    test('dispose does nothing', () {
      soundService.dispose();
      // Should not throw
    });
  });
}

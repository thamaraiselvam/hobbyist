// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'hobby_service.dart';
import 'analytics_service.dart';

class SoundService {
  static SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  @visibleForTesting
  static set instance(SoundService value) => _instance = value;

  SoundService._internal()
    : _hobbyService = HobbyService(),
      _analytics = AnalyticsService();

  // For testing
  SoundService.test({HobbyService? hobbyService, AnalyticsService? analytics})
    : _hobbyService = hobbyService ?? HobbyService(),
      _analytics = analytics ?? AnalyticsService();

  final HobbyService _hobbyService;
  final AnalyticsService _analytics;

  Future<void> playCompletionSound() async {
    try {
      // Check if completion vibration is enabled in settings
      final vibrationEnabled = await _hobbyService.getSetting(
        'completion_sound',
      );
      if (vibrationEnabled == 'false') {
        return;
      }

      // Play only haptic feedback (vibration)
      await _playHapticFeedback();

      // Track completion sound
      await _analytics.logCompletionSound();
    } catch (e) {
      print('Error playing vibration: $e');
    }
  }

  Future<void> _playHapticFeedback() async {
    try {
      // Play a medium impact haptic feedback
      await HapticFeedback.mediumImpact();
      // Add a light impact after a short delay for a pleasant two-tap feel
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
    } catch (e) {
      print('Error playing haptic feedback: $e');
    }
  }

  void dispose() {
    // No resources to dispose
  }
}

import 'package:flutter/services.dart';
import 'hobby_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final HobbyService _hobbyService = HobbyService();

  Future<void> playCompletionSound() async {
    try {
      // Check if completion vibration is enabled in settings
      final vibrationEnabled = await _hobbyService.getSetting('completionSound');
      if (vibrationEnabled == 'false') {
        return;
      }

      // Play only haptic feedback (vibration)
      await _playHapticFeedback();
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

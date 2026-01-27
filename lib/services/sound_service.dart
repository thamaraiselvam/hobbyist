import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'hobby_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final HobbyService _hobbyService = HobbyService();

  Future<void> playCompletionSound() async {
    try {
      // Check if completion sound is enabled in settings
      final soundEnabled = await _hobbyService.getSetting('completionSound');
      if (soundEnabled == 'false') {
        return;
      }

      // Play sound and haptic feedback together
      await Future.wait([
        _playSound(),
        _playHapticFeedback(),
      ]);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/completion.wav'));
    } catch (e) {
      print('Error playing audio: $e');
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
    _audioPlayer.dispose();
  }
}

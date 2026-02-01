import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class RatingService {
  static const String _keyCompletionCount = 'total_completion_count';
  static const String _keyHasRated = 'has_rated_app';
  static const String _keyFirstPromptShown = 'first_rating_prompt_shown';

  final InAppReview _inAppReview;

  RatingService({InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  /// Check if we should show rating prompt and show it if conditions are met
  Future<void> checkAndShowRatingPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    // Don't show if user has already rated
    final hasRated = prefs.getBool(_keyHasRated) ?? false;
    final completionCount = prefs.getInt(_keyCompletionCount) ?? 0;
    final firstPromptShown = prefs.getBool(_keyFirstPromptShown) ?? false;

    debugPrint('🌟 RatingService: Checking rating prompt...');
    debugPrint('   Completion count: $completionCount');
    debugPrint('   Has rated: $hasRated');
    debugPrint('   First prompt shown: $firstPromptShown');

    if (hasRated) {
      debugPrint('   ❌ User already rated, skipping');
      return;
    }

    // Show on 1st completion
    if (completionCount == 1 && !firstPromptShown) {
      debugPrint('   ✅ Triggering 1st completion prompt');
      await _showRatingPrompt(isFirstTime: true);
      await prefs.setBool(_keyFirstPromptShown, true);
      return;
    }

    // Show on 10th completion if first prompt was shown (meaning user skipped)
    if (completionCount == 10 && firstPromptShown) {
      debugPrint('   ✅ Triggering 10th completion prompt');
      await _showRatingPrompt(isFirstTime: false);
      return;
    }

    debugPrint('   ⏸️ No prompt triggered (count: $completionCount)');
  }

  /// Show the native in-app rating prompt
  Future<void> _showRatingPrompt({required bool isFirstTime}) async {
    debugPrint(
        '🌟 RatingService: Attempting to show rating prompt (first time: $isFirstTime)');

    // Check if in-app review is available
    final isAvailable = await _inAppReview.isAvailable();
    debugPrint('   In-App Review available: $isAvailable');

    if (isAvailable) {
      debugPrint('   📱 Requesting review...');
      await _inAppReview.requestReview();
      debugPrint('   ✅ Review requested');

      // Mark as rated (assumes user interacted with prompt)
      await _markAsRated();
    } else {
      debugPrint('   ⚠️ In-App Review NOT available');
      debugPrint('   Reasons: emulator, debug mode, or quota exceeded');
      // Fallback: Open store listing
      debugPrint('   💡 Fallback: Opening store listing...');
      try {
        await _inAppReview.openStoreListing();
      } catch (e) {
        debugPrint('   ❌ Failed to open store listing: $e');
      }
    }
  }

  /// Increment the total completion count
  Future<void> incrementCompletionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyCompletionCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_keyCompletionCount, newCount);
    debugPrint(
        '🌟 RatingService: Completion count incremented: $currentCount → $newCount');
  }

  /// Mark that user has rated the app
  Future<void> _markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasRated, true);
  }

  /// Get current completion count (for debugging/testing)
  Future<int> getCompletionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCompletionCount) ?? 0;
  }

  /// Reset rating state (for testing purposes)
  Future<void> resetRatingState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompletionCount);
    await prefs.remove(_keyHasRated);
    await prefs.remove(_keyFirstPromptShown);
  }

  /// Open the app store page (fallback for when in-app review is not available)
  Future<void> openStoreListing() async {
    await _inAppReview.openStoreListing(
      appStoreId: 'your_app_store_id', // Replace with actual app store ID
    );
  }
}

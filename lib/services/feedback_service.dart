import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FeedbackService {
  final FirebaseFirestore? _firestore;

  static FirebaseFirestore? _createFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FeedbackService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? _createFirestore();

  /// Submit user feedback to Firestore
  /// Returns true if successful, false otherwise
  Future<bool> submitFeedback({
    required String feedbackText,
    String? email,
  }) async {
    try {
      debugPrint('📝 FeedbackService: Submitting feedback...');

      // Validate feedback text
      if (feedbackText.trim().isEmpty) {
        debugPrint('   ❌ Feedback text is empty');
        return false;
      }

      if (feedbackText.length > 500) {
        debugPrint('   ❌ Feedback exceeds 500 characters');
        return false;
      }

      // Prepare feedback data
      final feedbackData = {
        'feedback': feedbackText.trim(),
        'email': email?.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'app_version': '1.0.0', // Could be dynamic
        'platform': defaultTargetPlatform.toString(),
      };

      debugPrint('   Feedback length: ${feedbackText.length} chars');
      debugPrint('   Email provided: ${email != null && email.isNotEmpty}');

      // Write to Firestore
      if (_firestore == null) {
        debugPrint('   ❌ Firestore unavailable (Firebase not initialized)');
        return false;
      }
      await _firestore!.collection('feedback').add(feedbackData);

      debugPrint('   ✅ Feedback submitted successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('   ❌ Failed to submit feedback: $e');
      debugPrint('   Stack trace: $stackTrace');
      return false;
    }
  }
}

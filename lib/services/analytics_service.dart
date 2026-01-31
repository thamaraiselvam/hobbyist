import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/hobby.dart';

/// AnalyticsService - Centralized analytics tracking service
/// 
/// This service manages all Firebase Analytics events throughout the app.
/// It follows the singleton pattern to ensure consistent tracking across the app.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  /// Initialize Firebase Analytics
  static void initialize() {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
  }

  /// Get the analytics observer for route tracking
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Track app open event
  Future<void> logAppOpen() async {
    await _analytics?.logAppOpen();
  }

  /// Track screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  // ========================
  // Onboarding Events
  // ========================

  /// Track when user completes onboarding
  Future<void> logOnboardingComplete() async {
    await _analytics?.logEvent(
      name: 'user_onboarding_complete',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track landing page view
  Future<void> logLandingView() async {
    await _analytics?.logEvent(
      name: 'landing_page_viewed',
    );
  }

  // ========================
  // Hobby Management Events
  // ========================

  /// Track hobby creation
  Future<void> logHobbyCreated({
    required String hobbyId,
    required String priority,
    required String repeatMode,
    int? color,
  }) async {
    await _analytics?.logEvent(
      name: 'hobby_created',
      parameters: {
        'hobby_id': hobbyId,
        'priority': priority,
        'repeat_mode': repeatMode,
        'color': color ?? 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track hobby update
  Future<void> logHobbyUpdated({
    required String hobbyId,
    String? priority,
    String? repeatMode,
  }) async {
    final Map<String, Object> params = {
      'hobby_id': hobbyId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (priority != null) params['priority'] = priority;
    if (repeatMode != null) params['repeat_mode'] = repeatMode;

    await _analytics?.logEvent(
      name: 'hobby_updated',
      parameters: params,
    );
  }

  /// Track hobby deletion
  Future<void> logHobbyDeleted({
    required String hobbyId,
    String? reason,
  }) async {
    await _analytics?.logEvent(
      name: 'hobby_deleted',
      parameters: {
        'hobby_id': hobbyId,
        'reason': reason ?? 'user_action',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========================
  // Completion Events
  // ========================

  /// Track completion toggle
  Future<void> logCompletionToggled({
    required String hobbyId,
    required bool completed,
    int? currentStreak,
  }) async {
    await _analytics?.logEvent(
      name: 'completion_toggled',
      parameters: {
        'hobby_id': hobbyId,
        'completed': completed,
        'current_streak': currentStreak ?? 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track streak milestone achievement
  Future<void> logStreakAchieved({
    required String hobbyId,
    required int streakCount,
  }) async {
    // Only log milestones: 7, 14, 30, 50, 100, 365 days
    final milestones = [7, 14, 30, 50, 100, 365];
    if (!milestones.contains(streakCount)) return;

    await _analytics?.logEvent(
      name: 'streak_milestone',
      parameters: {
        'hobby_id': hobbyId,
        'streak_count': streakCount,
        'milestone': streakCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track completion sound played
  Future<void> logCompletionSound() async {
    await _analytics?.logEvent(
      name: 'completion_sound_played',
    );
  }

  // ========================
  // Engagement Events
  // ========================

  /// Track analytics screen view
  Future<void> logAnalyticsViewed() async {
    await _analytics?.logEvent(
      name: 'analytics_viewed',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track settings change
  Future<void> logSettingChanged({
    required String settingName,
    required String settingValue,
  }) async {
    await _analytics?.logEvent(
      name: 'setting_changed',
      parameters: {
        'setting_name': settingName,
        'setting_value': settingValue,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track quote displayed
  Future<void> logQuoteDisplayed() async {
    await _analytics?.logEvent(
      name: 'quote_displayed',
    );
  }

  // ========================
  // Performance Events
  // ========================

  /// Track database query performance
  Future<void> logDatabaseQueryTime({
    required String queryType,
    required int durationMs,
  }) async {
    await _analytics?.logEvent(
      name: 'db_query_performance',
      parameters: {
        'query_type': queryType,
        'duration_ms': durationMs,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========================
  // User Engagement Metrics
  // ========================

  /// Track daily summary statistics
  Future<void> logDailyStats({
    required int totalHobbies,
    required int completedToday,
    required double averageCompletionRate,
  }) async {
    await _analytics?.logEvent(
      name: 'daily_stats',
      parameters: {
        'total_hobbies': totalHobbies,
        'completed_today': completedToday,
        'avg_completion_rate': averageCompletionRate,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Set user properties (not PII)
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics?.setUserProperty(name: name, value: value);
  }

  /// Track app session duration
  Future<void> logSessionEnd({required int durationSeconds}) async {
    await _analytics?.logEvent(
      name: 'session_end',
      parameters: {
        'duration_seconds': durationSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ========================
  // Custom Conversion Events
  // ========================

  /// Track when user creates their first hobby
  Future<void> logFirstHobbyCreated() async {
    await _analytics?.logEvent(
      name: 'first_hobby_created',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track when user completes their first hobby
  Future<void> logFirstCompletion() async {
    await _analytics?.logEvent(
      name: 'first_completion',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}

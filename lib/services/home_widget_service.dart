import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Pushes streak data to the Android home screen widget.
///
/// Call [push] after any data load or completion toggle so the widget stays
/// in sync.  Errors are silently swallowed — a missing or un-pinned widget
/// must never break the in-app UI.
///
/// SharedPreferences keys written (read by StreakWidget.kt):
///   streak_current      – int,    global consecutive-day streak count
///   streak_days         – String, 7-char bitmask "1101100"
///                         index 0 = 6 days ago … index 6 = today
///   streak_has_hobbies  – int,    1 if user has at least one hobby else 0
///   streak_user_name    – String, user's display name (empty = not set)
class HomeWidgetService {
  static const _androidWidgetNames = <String>[
    'StreakWidget',
    'StreakWidgetDesign02',
    'StreakWidgetDesign03',
    'StreakWidgetDesign04',
    'StreakWidgetDesign07',
  ];

  /// Saves all streak state and requests a native widget redraw.
  ///
  /// [completedDaysInWeek] — 7 booleans for the rolling window:
  ///   index 0 = 6 days ago, index 6 = today.
  static Future<void> push({
    required int streak,
    required List<bool> completedDaysInWeek,
    required bool hasHobbies,
    required String userName,
  }) async {
    assert(completedDaysInWeek.length == 7);
    try {
      await HomeWidget.saveWidgetData<int>('streak_current', streak);
      await HomeWidget.saveWidgetData<String>(
        'streak_days',
        completedDaysInWeek.map((b) => b ? '1' : '0').join(),
      );
      await HomeWidget.saveWidgetData<int>(
        'streak_has_hobbies',
        hasHobbies ? 1 : 0,
      );
      await HomeWidget.saveWidgetData<String>('streak_user_name', userName);
      for (final widgetName in _androidWidgetNames) {
        await HomeWidget.updateWidget(androidName: widgetName);
      }
    } catch (e) {
      // Widget may not be pinned or plugin not initialised.
      // Log in debug so sync failures are visible during development.
      debugPrint('HomeWidgetService.push failed: $e');
    }
  }
}

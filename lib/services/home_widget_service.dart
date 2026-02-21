import 'package:home_widget/home_widget.dart';

/// Pushes streak data to the Android home screen widget.
///
/// Call [push] after any data load or completion toggle so the widget stays
/// in sync.  Errors are silently swallowed — a missing or un-pinned widget
/// must never break the in-app UI.
class HomeWidgetService {
  static const _androidWidgetName = 'StreakWidget';

  /// Serialises streak state into the shared-preferences store that the native
  /// [StreakWidget] reads on each update cycle, then requests a redraw.
  ///
  /// [completedDaysInWeek] — exactly 7 booleans, Mon (index 0) → Sun (index 6).
  /// [currentDayIndex]     — today's position in that list (0–6).
  static Future<void> push({
    required int streak,
    required List<bool> completedDaysInWeek,
    required int currentDayIndex,
  }) async {
    assert(completedDaysInWeek.length == 7);
    try {
      await HomeWidget.saveWidgetData<int>('streak_current', streak);
      await HomeWidget.saveWidgetData<String>(
        'streak_days',
        completedDaysInWeek.map((b) => b ? '1' : '0').join(),
      );
      await HomeWidget.saveWidgetData<int>(
        'streak_today_index',
        currentDayIndex,
      );
      await HomeWidget.updateWidget(androidName: _androidWidgetName);
    } catch (_) {
      // Widget may not be pinned or plugin not initialised — ignore.
    }
  }
}

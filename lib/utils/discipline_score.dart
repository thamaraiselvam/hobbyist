import 'package:intl/intl.dart';
import '../models/hobby.dart';

/// Calculates discipline score across a rolling date window.
///
/// Score = (total completions / total planned) × 100
/// One-time tasks are excluded (they don't have a regular schedule).
class DisciplineScore {
  DisciplineScore._();

  /// Returns an integer 0–100. Returns 0 when no tasks were planned.
  static int calculate(List<Hobby> hobbies, {int days = 10}) {
    if (hobbies.isEmpty) return 0;

    final now = DateTime.now();
    int totalPlanned = 0;
    int totalCompleted = 0;

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      for (final hobby in hobbies) {
        if (hobby.isOneTime) continue;
        if (_isAvailableForDate(hobby, date)) {
          totalPlanned++;
          if (hobby.completions[dateKey]?.completed == true) {
            totalCompleted++;
          }
        }
      }
    }

    if (totalPlanned == 0) return 0;
    return (totalCompleted / totalPlanned * 100).round().clamp(0, 100);
  }

  static bool _isAvailableForDate(Hobby hobby, DateTime date) {
    switch (hobby.repeatMode.toLowerCase()) {
      case 'daily':
        return true;
      case 'weekly':
        if (hobby.customDay == null) return true;
        final weekday = date.weekday; // 1=Mon … 7=Sun
        final dayIndex = weekday == 7 ? 6 : weekday - 1; // 0=Mon … 6=Sun
        return hobby.customDay == dayIndex;
      case 'monthly':
        if (hobby.customDay == null) return true;
        return date.day == hobby.customDay;
      default:
        return false;
    }
  }
}

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
    final p = plannedCount(hobbies, days: days);
    if (p == 0) return 0;
    return (completedCount(hobbies, days: days) / p * 100)
        .round()
        .clamp(0, 100);
  }

  /// Total task-day combinations planned in the window.
  static int plannedCount(List<Hobby> hobbies, {int days = 10}) {
    if (hobbies.isEmpty) return 0;
    final now = DateTime.now();
    int total = 0;
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      for (final hobby in hobbies) {
        if (hobby.isOneTime) continue;
        if (_isAvailableForDate(hobby, date)) total++;
      }
    }
    return total;
  }

  /// Total completed task-day combinations in the window.
  static int completedCount(List<Hobby> hobbies, {int days = 10}) {
    if (hobbies.isEmpty) return 0;
    final now = DateTime.now();
    int total = 0;
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (final hobby in hobbies) {
        if (hobby.isOneTime) continue;
        if (_isAvailableForDate(hobby, date) &&
            hobby.completions[dateKey]?.completed == true) {
          total++;
        }
      }
    }
    return total;
  }

  static bool _isAvailableForDate(Hobby hobby, DateTime date) {
    switch (hobby.repeatMode.toLowerCase()) {
      case 'daily':
        return true;
      case 'weekly':
        final days = hobby.effectiveWeekDays;
        if (days.isEmpty) return true;
        final weekday = date.weekday; // 1=Mon … 7=Sun
        final dayIndex = weekday == 7 ? 6 : weekday - 1; // 0=Mon … 6=Sun
        return days.contains(dayIndex);
      case 'monthly':
        if (hobby.customDay == null) return true;
        return date.day == hobby.customDay;
      default:
        return false;
    }
  }
}

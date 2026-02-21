import 'package:intl/intl.dart';
import '../models/hobby.dart';

/// Calculates discipline score based on all-time history up to today.
///
/// Score = (total completions / total planned) × 100
/// One-time tasks are excluded (they don't have a regular schedule).
class DisciplineScore {
  DisciplineScore._();

  /// Returns an integer 0–100. Returns 0 when no tasks were planned.
  static int calculate(List<Hobby> hobbies) {
    final p = plannedCount(hobbies);
    if (p == 0) return 0;
    return (completedCount(hobbies) / p * 100).round().clamp(0, 100);
  }

  /// Total task-day combinations planned from each hobby's creation date
  /// through today.
  static int plannedCount(List<Hobby> hobbies) {
    if (hobbies.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int total = 0;

    for (final hobby in hobbies) {
      if (hobby.isOneTime) continue;
      final raw = hobby.createdAt ?? today;
      final start = DateTime(raw.year, raw.month, raw.day);
      final days = today.difference(start).inDays + 1;
      for (int i = 0; i < days; i++) {
        final date = start.add(Duration(days: i));
        if (date.isAfter(today)) break;
        if (_isAvailableForDate(hobby, date)) total++;
      }
    }
    return total;
  }

  /// Total completed task-day combinations from each hobby's creation date
  /// through today.
  static int completedCount(List<Hobby> hobbies) {
    if (hobbies.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int total = 0;

    for (final hobby in hobbies) {
      if (hobby.isOneTime) continue;
      final raw = hobby.createdAt ?? today;
      final start = DateTime(raw.year, raw.month, raw.day);
      final days = today.difference(start).inDays + 1;
      for (int i = 0; i < days; i++) {
        final date = start.add(Duration(days: i));
        if (date.isAfter(today)) break;
        if (!_isAvailableForDate(hobby, date)) continue;
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        if (hobby.completions[dateKey]?.completed == true) total++;
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

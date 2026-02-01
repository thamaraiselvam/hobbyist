import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hobby.dart';

class ContributionChart extends StatelessWidget {
  final List<Hobby> hobbies;
  final int weeks;

  const ContributionChart({
    super.key,
    required this.hobbies,
    this.weeks = 12,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: weeks * 7));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthLabels(startDate, now),
            const SizedBox(height: 4),
            _buildChart(startDate, now),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthLabels(DateTime start, DateTime end) {
    final months = <Widget>[];
    DateTime current = DateTime(start.year, start.month, 1);

    while (current.isBefore(end) || current.month == end.month) {
      months.add(
        SizedBox(
          width: 52,
          child: Text(
            DateFormat('MMM').format(current),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      );
      current = DateTime(current.year, current.month + 1, 1);
    }

    return Row(children: months);
  }

  Widget _buildChart(DateTime start, DateTime end) {
    final weeks = <Widget>[];
    DateTime currentWeekStart =
        start.subtract(Duration(days: start.weekday % 7));

    while (currentWeekStart.isBefore(end)) {
      weeks.add(_buildWeekColumn(currentWeekStart));
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayLabels(),
        const SizedBox(width: 4),
        ...weeks,
      ],
    );
  }

  Widget _buildDayLabels() {
    const days = ['M', 'W', 'F'];
    const indices = [0, 2, 4];

    return Column(
      children: List.generate(7, (index) {
        final dayIndex = indices.indexOf(index);
        return Container(
          width: 16,
          height: 12,
          margin: const EdgeInsets.all(1),
          child: dayIndex != -1
              ? Text(
                  days[dayIndex],
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                )
              : null,
        );
      }),
    );
  }

  Widget _buildWeekColumn(DateTime weekStart) {
    final days = <Widget>[];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final completionCount = _getCompletionCount(dateStr);

      days.add(
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: _getColorForCount(completionCount),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }

    return Column(children: days);
  }

  int _getCompletionCount(String date) {
    int count = 0;
    for (final hobby in hobbies) {
      if (hobby.completions[date]?.completed == true) count++;
    }
    return count;
  }

  Color _getColorForCount(int count) {
    if (count == 0) return Colors.grey.shade200;
    if (count == 1) return Colors.green.shade200;
    if (count == 2) return Colors.green.shade400;
    if (count == 3) return Colors.green.shade600;
    return Colors.green.shade800;
  }

  Widget _buildLegend() {
    return Row(
      children: [
        const Text('Less', style: TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _getColorForCount(index),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 4),
        const Text('More', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

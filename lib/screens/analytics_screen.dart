// ignore_for_file: avoid_print, unused_field, unused_element, unused_local_variable
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hobby.dart';
import '../services/analytics_service.dart';
import '../services/hobby_service.dart';
import '../utils/discipline_score.dart';
import '../utils/page_transitions.dart';
import 'add_hobby_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/test_keys.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Hobby> hobbies;
  final VoidCallback onBack;
  final Function(int) onNavigate;
  final Future<void> Function() onRefresh;

  const AnalyticsScreen({
    super.key,
    required this.hobbies,
    required this.onBack,
    required this.onNavigate,
    required this.onRefresh,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Weekly';
  final HobbyService _hobbyService = HobbyService();
  bool _pullToRefreshEnabled = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService().logAnalyticsViewed();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _pullToRefreshEnabled =
            prefs.getBool('pull_to_refresh_enabled') ?? false;
      });
    }
  }

  @override
  void didUpdateWidget(AnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force a rebuild when hobbies list changes
    if (oldWidget.hobbies != widget.hobbies) {
      setState(() {});
    }
  }

  int get currentStreak {
    if (widget.hobbies.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      bool anyTaskCompleted = false;
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          anyTaskCompleted = true;
          break;
        }
      }

      if (anyTaskCompleted) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  int get bestStreak {
    if (widget.hobbies.isEmpty) return 0;

    // Calculate the longest overall streak (any task completed per day)
    // This matches the logic of currentStreak but looks at ALL history
    int maxOverallStreak = 0;
    int currentOverallStreak = 0;
    final today = DateTime.now();

    // Go back 365 days and find longest consecutive streak
    for (int startDay = 0; startDay < 365; startDay++) {
      currentOverallStreak = 0;

      for (int i = startDay; i < 365; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        bool anyTaskCompleted = false;
        for (var hobby in widget.hobbies) {
          if (hobby.completions[dateKey]?.completed == true) {
            anyTaskCompleted = true;
            break;
          }
        }

        if (anyTaskCompleted) {
          currentOverallStreak++;
          if (currentOverallStreak > maxOverallStreak) {
            maxOverallStreak = currentOverallStreak;
          }
        } else {
          break; // Streak broken
        }
      }
    }

    print(
      '📊 Analytics bestStreak: $maxOverallStreak (calculated from overall completion history)',
    );
    return maxOverallStreak;
  }

  int get totalCompleted {
    int total = 0;
    for (var hobby in widget.hobbies) {
      total += hobby.completions.values.where((c) => c.completed).length;
    }
    return total;
  }

  int get totalCompletedThisWeek {
    int total = 0;
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          total++;
        }
      }
    }
    return total;
  }

  int get totalCompletedLastWeek {
    int total = 0;
    for (int i = 7; i < 14; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          total++;
        }
      }
    }
    return total;
  }

  int get totalCompletedThisMonth {
    int total = 0;
    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          total++;
        }
      }
    }
    return total;
  }

  int get totalCompletedLastMonth {
    int total = 0;
    for (int i = 30; i < 60; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          total++;
        }
      }
    }
    return total;
  }

  int get totalCompletedThisYear {
    int total = 0;
    for (int i = 0; i < 365; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          total++;
        }
      }
    }
    return total;
  }

  int get totalCompletedLastYear {
    int total = 0;
    for (int i = 365; i < 730; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          total++;
        }
      }
    }
    return total;
  }

  double get currentGrowth {
    int currentPeriod;
    int previousPeriod;

    switch (_selectedPeriod) {
      case 'Weekly':
        currentPeriod = totalCompletedThisWeek;
        previousPeriod = totalCompletedLastWeek;
        break;
      case 'Monthly':
        currentPeriod = totalCompletedThisMonth;
        previousPeriod = totalCompletedLastMonth;
        break;
      case 'Yearly':
        currentPeriod = totalCompletedThisYear;
        previousPeriod = totalCompletedLastYear;
        break;
      default:
        currentPeriod = totalCompletedThisWeek;
        previousPeriod = totalCompletedLastWeek;
    }

    if (previousPeriod == 0) {
      return currentPeriod > 0 ? 100 : 0;
    }
    return ((currentPeriod - previousPeriod) / previousPeriod * 100);
  }

  double get weeklyGrowth {
    if (totalCompletedLastWeek == 0) {
      return totalCompletedThisWeek > 0 ? 100 : 0;
    }
    return ((totalCompletedThisWeek - totalCompletedLastWeek) /
        totalCompletedLastWeek *
        100);
  }

  // Find the earliest date with any completion data
  List<double> get performanceData {
    List<double> data = [];
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Weekly':
        // Always show 7 days
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          int count = 0;
          for (var hobby in widget.hobbies) {
            if (hobby.completions[dateKey]?.completed == true) {
              count++;
            }
          }
          data.add(count.toDouble());
        }
        break;

      case 'Monthly':
        // Always show 30 days
        for (int i = 29; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          int count = 0;
          for (var hobby in widget.hobbies) {
            if (hobby.completions[dateKey]?.completed == true) {
              count++;
            }
          }
          data.add(count.toDouble());
        }
        break;

      case 'Yearly':
        // Show 52 weeks (grouped by week)
        for (int i = 51; i >= 0; i--) {
          final startOfWeek = now.subtract(
            Duration(days: now.weekday - 1 + (i * 7)),
          );
          int weekCount = 0;

          // Count all completions in this week (7 days)
          for (int d = 0; d < 7; d++) {
            final date = startOfWeek.add(Duration(days: d));
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            for (var hobby in widget.hobbies) {
              if (hobby.completions[dateKey]?.completed == true) {
                weekCount++;
              }
            }
          }
          data.add(weekCount.toDouble());
        }
        break;

      default:
        // Default to weekly
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          int count = 0;
          for (var hobby in widget.hobbies) {
            if (hobby.completions[dateKey]?.completed == true) {
              count++;
            }
          }
          data.add(count.toDouble());
        }
    }

    return data;
  }

  String get performanceTitle {
    switch (_selectedPeriod) {
      case 'Weekly':
        return '7-Day Performance';
      case 'Monthly':
        return '30-Day Performance';
      case 'Yearly':
        return '52-Week Performance';
      default:
        return '7-Day Performance';
    }
  }

  List<String> get performanceLabels {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Weekly':
        // Return day names (MON, TUE, WED, etc.)
        return List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          return DateFormat('EEE').format(date).toUpperCase(); // MON, TUE, WED
        });
      case 'Monthly':
        // Return day counter with D prefix (D1, D2, D3, etc.)
        return List.generate(30, (i) => 'D${i + 1}');
      case 'Yearly':
        // Return week counter with W prefix (W1, W2, W3, etc.)
        return List.generate(52, (i) => 'W${i + 1}');
      default:
        return List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          return DateFormat('EEE').format(date).toUpperCase();
        });
    }
  }

  List<Map<String, dynamic>> get activityMapData {
    List<Map<String, dynamic>> data = [];
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Weekly':
        // Show current week (7 days)
        final monday = now.subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final date = monday.add(Duration(days: i));
          final dateKey = DateFormat('yyyy-MM-dd').format(date);

          int count = 0;
          for (var hobby in widget.hobbies) {
            if (hobby.completions[dateKey]?.completed == true) {
              count++;
            }
          }

          data.add({
            'date': date,
            'count': count,
            'opacity': count == 0 ? 0.1 : (count / 4).clamp(0.2, 1.0),
          });
        }
        break;

      case 'Monthly':
        // Show last 28 days (4 weeks)
        for (int i = 27; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateKey = DateFormat('yyyy-MM-dd').format(date);

          int count = 0;
          for (var hobby in widget.hobbies) {
            if (hobby.completions[dateKey]?.completed == true) {
              count++;
            }
          }

          data.add({
            'date': date,
            'count': count,
            'opacity': count == 0 ? 0.1 : (count / 4).clamp(0.2, 1.0),
          });
        }
        break;

      case 'Yearly':
        // Show last 52 weeks
        for (int week = 51; week >= 0; week--) {
          int weekCount = 0;
          final weekStart = now.subtract(Duration(days: week * 7));

          for (int day = 0; day < 7; day++) {
            final date = weekStart.add(Duration(days: day));
            final dateKey = DateFormat('yyyy-MM-dd').format(date);

            for (var hobby in widget.hobbies) {
              if (hobby.completions[dateKey]?.completed == true) {
                weekCount++;
              }
            }
          }

          data.add({
            'date': weekStart,
            'count': weekCount,
            'opacity': weekCount == 0 ? 0.1 : (weekCount / 20).clamp(0.2, 1.0),
          });
        }
        break;

      default:
        // Default to weekly
        final monday = now.subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final date = monday.add(Duration(days: i));
          final dateKey = DateFormat('yyyy-MM-dd').format(date);

          int count = 0;
          for (var hobby in widget.hobbies) {
            if (hobby.completions[dateKey]?.completed == true) {
              count++;
            }
          }

          data.add({
            'date': date,
            'count': count,
            'opacity': count == 0 ? 0.1 : (count / 4).clamp(0.2, 1.0),
          });
        }
    }

    return data;
  }

  String get activityMapTitle {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Weekly':
        return 'This Week';
      case 'Monthly':
        return DateFormat('MMMM').format(now);
      case 'Yearly':
        return now.year.toString();
      default:
        return DateFormat('MMMM').format(now);
    }
  }

  Future<void> _refreshData() async {
    await widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _pullToRefreshEnabled
                  ? RefreshIndicator(
                      onRefresh: widget.onRefresh,
                      color: const Color(0xFF590df2),
                      backgroundColor: const Color(0xFF161616),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildStatsCards(),
                            const SizedBox(height: 24),
                            _buildDisciplineSection(),
                            const SizedBox(height: 24),
                            _buildBarChart(),
                            const SizedBox(height: 32),
                            _buildActivityMap(),
                            const SizedBox(height: 32),
                            _buildAllTasks(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildStatsCards(),
                          const SizedBox(height: 24),
                          _buildBarChart(),
                          const SizedBox(height: 32),
                          _buildActivityMap(),
                          const SizedBox(height: 32),
                          _buildAllTasks(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: const Text(
        'Analytics',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDisciplineSection() {
    final score = DisciplineScore.calculate(widget.hobbies);
    final planned = DisciplineScore.plannedCount(widget.hobbies);
    final completed = DisciplineScore.completedCount(widget.hobbies);
    final pct = planned == 0
        ? 0
        : (completed / planned * 100).round().clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0DFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.track_changes_outlined,
                  color: Color(0xFF6C3FFF),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'OVERALL DISCIPLINE SCORE',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '10-day window',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Color(0xFF6C3FFF),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '%',
                    style: TextStyle(
                      color: Color(0xFF6C3FFF),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _disciplineStat('Planned', '$planned'),
                    const SizedBox(height: 4),
                    _disciplineStat('Completed', '$completed'),
                    const SizedBox(height: 4),
                    _disciplineStat('Rate', '$pct%'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor: const Color(0xFF2A2238),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6C3FFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disciplineStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - 32) / 3; // 3 cards with spacing
          final numberFontSize = cardWidth * 0.32;
          final labelFontSize = cardWidth * 0.11;

          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x0DFFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Current Streak',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.0,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.local_fire_department,
                            color: Color(0xFFFF6B35),
                            size: 22,
                          ),
                        ],
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$currentStreak',
                                style: TextStyle(
                                  fontSize: numberFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Days',
                                style: TextStyle(
                                  fontSize: labelFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Text(
                        'Keep it up!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x0DFFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Best Streak',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.0,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.star, color: Color(0xFFFFD700), size: 22),
                        ],
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$bestStreak',
                                style: TextStyle(
                                  fontSize: numberFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Days',
                                style: TextStyle(
                                  fontSize: labelFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Text(
                        'Personal Best',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFD700),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x0DFFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Total Done',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.0,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.emoji_events,
                            color: Color(0xFF590df2),
                            size: 18,
                          ),
                        ],
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$totalCompleted',
                                style: TextStyle(
                                  fontSize: numberFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tasks',
                                style: TextStyle(
                                  fontSize: labelFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '${completionRate.toInt()}% Today',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double get completionRate {
    if (widget.hobbies.isEmpty) return 0;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int completedToday = 0;

    for (var hobby in widget.hobbies) {
      if (hobby.completions[today]?.completed == true) {
        completedToday++;
      }
    }

    return widget.hobbies.isNotEmpty
        ? (completedToday / widget.hobbies.length * 100)
        : 0;
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF221834),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildPeriodButton('WEEKLY', _selectedPeriod == 'Weekly'),
            _buildPeriodButton('MONTHLY', _selectedPeriod == 'Monthly'),
            _buildPeriodButton('YEARLY', _selectedPeriod == 'Yearly'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool isSelected) {
    final period = label == 'WEEKLY'
        ? 'weekly'
        : label == 'MONTHLY'
        ? 'monthly'
        : 'yearly';
    return Expanded(
      child: Semantics(
        identifier: TestKeys.analyticsPeriodButton(period),
        child: GestureDetector(
          key: Key(TestKeys.analyticsPeriodButton(period)),
          onTap: () {
            setState(
              () => _selectedPeriod =
                  period[0].toUpperCase() + period.substring(1),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6C3FFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFFa490cb),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPeriodButton(
    String label,
    bool isSelected,
    String period,
  ) {
    return Semantics(
      identifier: TestKeys.analyticsPeriodButton(period.toLowerCase()),
      child: GestureDetector(
        key: Key(TestKeys.analyticsPeriodButton(period.toLowerCase())),
        onTap: () {
          setState(() => _selectedPeriod = period);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C3FFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFFa490cb),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final chartData = performanceData;
    final labels = performanceLabels;

    // Safety check - ensure we have data
    if (chartData.isEmpty || labels.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ensure chartData and labels have same length
    final dataLength = chartData.length < labels.length
        ? chartData.length
        : labels.length;
    final safeChartData = chartData.take(dataLength).toList();
    final safeLabels = labels.take(dataLength).toList();

    // Find max value for scaling
    final maxValue = safeChartData.isEmpty
        ? 1.0
        : safeChartData.reduce((a, b) => a > b ? a : b);
    final scaledMax = maxValue == 0 ? 10.0 : maxValue * 1.2; // Add 20% padding

    // Calculate Y-axis scale markers
    const yAxisSteps = 5;
    final yAxisStep = (scaledMax / yAxisSteps).ceil();

    // Dynamic title based on period
    String chartTitle;
    switch (_selectedPeriod) {
      case 'Weekly':
        chartTitle = '7-Day Performance';
        break;
      case 'Monthly':
        chartTitle = '30-Day Performance';
        break;
      case 'Yearly':
        chartTitle = '52-Week Performance';
        break;
      default:
        chartTitle = 'Daily Performance';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                chartTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              // Compact period selector
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF221834),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactPeriodButton(
                      'W',
                      _selectedPeriod == 'Weekly',
                      'Weekly',
                    ),
                    _buildCompactPeriodButton(
                      'M',
                      _selectedPeriod == 'Monthly',
                      'Monthly',
                    ),
                    _buildCompactPeriodButton(
                      'Y',
                      _selectedPeriod == 'Yearly',
                      'Yearly',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x0DFFFFFF)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Y-axis labels
                    SizedBox(
                      width: 30,
                      height: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(yAxisSteps + 1, (index) {
                          final value = (yAxisSteps - index) * yAxisStep;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '$value',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF71717A),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Bar chart - all fit on screen
                    Expanded(
                      child: SizedBox(
                        height: 160,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(safeChartData.length, (
                            index,
                          ) {
                            final value = safeChartData[index];
                            final barHeight = scaledMax > 0
                                ? (value / scaledMax) * 160
                                : 0;

                            // Dark, muted colors for better visibility
                            final colors = [
                              const Color(0xFF6366F1), // Dark indigo
                              const Color(0xFF7C3AED), // Dark purple
                              const Color(0xFF2563EB), // Dark blue
                              const Color(0xFF059669), // Dark emerald
                              const Color(0xFFD97706), // Dark amber
                              const Color(0xFFDC2626), // Dark red
                              const Color(0xFF4338CA), // Deep indigo
                            ];

                            final colorIndex = index % colors.length;
                            final barColor = colors[colorIndex];

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _selectedPeriod == 'Yearly'
                                      ? 0.3
                                      : (_selectedPeriod == 'Monthly'
                                            ? 0.5
                                            : 1),
                                ),
                                child: TweenAnimationBuilder<double>(
                                  duration: Duration(
                                    milliseconds: 600 + (index * 80),
                                  ),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween(
                                    begin: 0.0,
                                    end: barHeight.clamp(2.0, 160.0).toDouble(),
                                  ),
                                  builder: (context, animatedHeight, child) {
                                    return Container(
                                      width: double.infinity,
                                      height: animatedHeight,
                                      decoration: BoxDecoration(
                                        color: barColor,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(3),
                                            ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: barColor.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // X-axis labels - independent from bars
                Row(
                  children: [
                    const SizedBox(
                      width: 38,
                    ), // Align with bars (y-axis width + padding)
                    Expanded(child: _buildXAxisLabels(safeLabels)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXAxisLabels(List<String> allLabels) {
    List<String> labelsToShow = [];

    if (_selectedPeriod == 'Weekly') {
      // Show all 7 labels: MON, TUE, WED, THU, FRI, SAT, SUN
      labelsToShow = allLabels;
    } else if (_selectedPeriod == 'Monthly') {
      // Show D1, D6, D12, D18, D24, D30
      labelsToShow = [
        allLabels[0], // D1
        allLabels[5], // D6
        allLabels[11], // D12
        allLabels[17], // D18
        allLabels[23], // D24
        allLabels[29], // D30
      ];
    } else if (_selectedPeriod == 'Yearly') {
      // Show W1, W10, W20, W30, W40, W52
      labelsToShow = [
        allLabels[0], // W1
        allLabels[9], // W10
        allLabels[19], // W20
        allLabels[29], // W30
        allLabels[39], // W40
        allLabels[51], // W52
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labelsToShow
          .map(
            (label) => Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF71717A),
                height: 1.0,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActivityMap() {
    final now = DateTime.now();
    const int daysToShow = 365;

    // Build 365 days of completion data
    List<Map<String, dynamic>> yearData = [];
    int contributionCount = 0;

    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Check if ANY task was completed on this day and track highest priority
      bool anyCompleted = false;
      String? highestPriority;
      int dayTaskCount = 0; // Count tasks completed on this day

      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          anyCompleted = true;
          dayTaskCount++; // Count each task completion
          contributionCount++; // Add to total count
        }
      }

      yearData.add({
        'date': date,
        'dateKey': dateKey,
        'completed': anyCompleted,
        'count': dayTaskCount, // Track count for intensity
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$contributionCount contribution${contributionCount != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Last 365 days',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x0DFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact calendar grid - like GitHub contributions
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: yearData
                      .map((data) => _buildActivityCell(data))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Legend - GitHub-style intensity
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Less',
                      style: TextStyle(fontSize: 10, color: Color(0xFF71717A)),
                    ),
                    const SizedBox(width: 6),
                    // None
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 3),
                    // Level 1
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E4429),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 3),
                    // Level 2
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006D32),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 3),
                    // Level 3
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A641),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 3),
                    // Level 4
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39D353),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'More',
                      style: TextStyle(fontSize: 10, color: Color(0xFF71717A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCell(Map<String, dynamic> data) {
    final bool isCompleted = data['completed'];
    final int count = data['count'] ?? 0;
    final date = data['date'] as DateTime;
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    // GitHub-style green colors based on activity intensity
    Color cellColor;
    if (!isCompleted || count == 0) {
      cellColor = const Color(0xFF161B22); // Dark gray for no activity
    } else if (count == 1) {
      cellColor = const Color(0xFF0E4429); // Light green
    } else if (count == 2) {
      cellColor = const Color(0xFF006D32); // Medium green
    } else if (count == 3) {
      cellColor = const Color(0xFF26A641); // Bright green
    } else {
      cellColor = const Color(0xFF39D353); // Brightest green (4+)
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
        border: isToday
            ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1)
            : null,
      ),
    );
  }

  Widget _buildAllTasks() {
    if (widget.hobbies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completion Calendar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Last 90 days',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          // Show calendar for each hobby
          ...widget.hobbies.map(
            (hobby) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildHobbyCompletionRow(hobby),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHobbyCompletionRow(Hobby hobby) {
    // Show last 90 days (more granular than 12 weeks)
    const int daysToShow = 90;
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: daysToShow - 1));

    // Build completion data for this hobby
    List<Map<String, dynamic>> dayData = [];
    for (int i = 0; i < daysToShow; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // For daily tasks, always show completion status
      // For weekly/monthly, check if scheduled
      bool isScheduled = _isHobbyAvailableForDate(hobby, date);
      bool isCompleted = hobby.completions[dateKey]?.completed == true;

      dayData.add({
        'date': date,
        'dateKey': dateKey,
        'isScheduled': isScheduled,
        'isCompleted': isCompleted,
      });
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hobby name with streak info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hobby.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFrequencyText(hobby.repeatMode),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
              ),
              // Streaks - Current and Best
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Streak
                  if (hobby.currentStreak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${hobby.currentStreak}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.local_fire_department,
                            color: Color(0xFFFF6B35),
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  // Best Streak
                  if (hobby.bestStreak > 0) ...[
                    if (hobby.currentStreak > 0) const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFFFD700),
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${hobby.bestStreak}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Show period
          const Text(
            'Last 90 days',
            style: TextStyle(fontSize: 10, color: Color(0xFF71717A)),
          ),
          const SizedBox(height: 8),
          // Compact calendar grid
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: dayData
                .map((data) => _buildCompactDayCell(data, hobby))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDayCell(Map<String, dynamic> data, Hobby hobby) {
    final bool isScheduled = data['isScheduled'];
    final bool isCompleted = data['isCompleted'];

    // Always show all 90 days with different visual states
    Color cellColor;
    if (!isScheduled) {
      // Not scheduled - show subtle skeleton
      cellColor = const Color(0xFF1A1625); // Very dark purple, subtle outline
    } else if (isCompleted) {
      // Scheduled and completed - use hobby color
      cellColor = Color(hobby.color);
    } else {
      // Scheduled but not completed - medium gray
      cellColor = const Color(0xFF2A2738);
    }

    final today = DateTime.now();
    final cellDate = data['date'] as DateTime;
    final isToday =
        cellDate.year == today.year &&
        cellDate.month == today.month &&
        cellDate.day == today.day;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
        border: isToday
            ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1)
            : null,
      ),
    );
  }

  bool _isHobbyAvailableForDate(Hobby hobby, DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday

    switch (hobby.repeatMode.toLowerCase()) {
      case 'daily':
        return true;
      case 'weekly':
        if (hobby.customDay != null) {
          // customDay: 0 = Monday, 6 = Sunday (convert to match weekday)
          return (hobby.customDay! + 1) == weekday;
        }
        return false;
      case 'monthly':
        if (hobby.customDay != null) {
          return date.day == hobby.customDay;
        }
        return false;
      default:
        return true;
    }
  }

  String _getFrequencyText(String repeatMode) {
    switch (repeatMode.toLowerCase()) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        return '1 time a week';
      case 'monthly':
        return 'Monthly goal';
      default:
        return 'Daily goal';
    }
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1733),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3D3560), width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          clipBehavior: Clip.none,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItemIcon(Icons.check_circle, 0),
              _buildNavItemIcon(Icons.list_alt, 1),
              _buildCreateButton(),
              _buildNavItemIcon(Icons.local_fire_department, 2),
              _buildNavItemIcon(Icons.settings, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      key: const Key(TestKeys.addHobbyFab),
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.push(
          context,
          SlidePageRoute(
            page: const AddHobbyScreen(),
            direction: AxisDirection.up,
          ),
        );
        await widget.onRefresh();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C3FFF), Color(0xFF8B5FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C3FFF).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildNavItemIcon(IconData icon, int index) {
    final isSelected = index == 2; // Analytics is now index 2
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          identifier: TestKeys.navItem(index),
          child: InkWell(
            key: Key(TestKeys.navItem(index)),
            onTap: () => widget.onNavigate(index),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    )
                  : null,
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF1E1733) : Colors.white38,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

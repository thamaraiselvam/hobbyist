import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hobby.dart';
import '../services/analytics_service.dart';
import '../services/hobby_service.dart';
import 'add_hobby_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Hobby> hobbies;
  final VoidCallback onBack;
  final Function(int) onNavigate;
  final Future<void> Function() onRefresh;

  const AnalyticsScreen({
    Key? key,
    required this.hobbies,
    required this.onBack,
    required this.onNavigate,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Weekly';
  int? _selectedDataPointIndex;
  final HobbyService _hobbyService = HobbyService();

  @override
  void initState() {
    super.initState();
    AnalyticsService().logAnalyticsViewed();
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

  List<double> get performanceData {
    List<double> data = [];
    
    switch (_selectedPeriod) {
      case 'Weekly':
        // Last 7 days
        for (int i = 6; i >= 0; i--) {
          final date = DateTime.now().subtract(Duration(days: i));
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
        // Last 30 days
        for (int i = 29; i >= 0; i--) {
          final date = DateTime.now().subtract(Duration(days: i));
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
        // Last 52 weeks, grouped by week
        final now = DateTime.now();
        for (int week = 51; week >= 0; week--) {
          int weekTotal = 0;
          final weekStart = now.subtract(Duration(days: week * 7));
          
          // Sum all completions for this week (7 days)
          for (int day = 0; day < 7; day++) {
            final date = weekStart.add(Duration(days: day));
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            for (var hobby in widget.hobbies) {
              if (hobby.completions[dateKey]?.completed == true) {
                weekTotal++;
              }
            }
          }
          data.add(weekTotal.toDouble());
        }
        break;
        
      default:
        // Default to weekly
        for (int i = 6; i >= 0; i--) {
          final date = DateTime.now().subtract(Duration(days: i));
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
        return 'Yearly Performance';
      default:
        return '7-Day Performance';
    }
  }

  List<String> get performanceLabels {
    switch (_selectedPeriod) {
      case 'Weekly':
        return ['Day 1', 'Day 4', 'Day 7'];
      case 'Monthly':
        return ['Day 1', 'Day 15', 'Day 30'];
      case 'Yearly':
        return ['Week 1', 'Week 26', 'Week 52'];
      default:
        return ['Day 1', 'Day 4', 'Day 7'];
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

  void _handleChartTouch(Offset localPosition, List<double> chartData) {
    if (chartData.isEmpty) return;
    
    final index = (localPosition.dx / MediaQuery.of(context).size.width * chartData.length).floor().clamp(0, chartData.length - 1);
    
    if (index >= 0 && index < chartData.length && index != _selectedDataPointIndex) {
      setState(() => _selectedDataPointIndex = index);
    }
  }

  double _calculateTooltipPosition(int index, int dataLength, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = screenWidth - 64; // accounting for padding
    final position = (index / (dataLength - 1).clamp(1, double.infinity)) * chartWidth;
    
    // Keep tooltip within bounds (32px padding on each side, 80px tooltip width)
    if (position < 40) return 16.0;
    if (position > chartWidth - 40) return chartWidth - 64;
    return position - 16;
  }

  String _getTooltipText(int index, List<double> chartData) {
    final value = chartData[index].toInt();
    
    switch (_selectedPeriod) {
      case 'Weekly':
        final daysAgo = 6 - index;
        if (daysAgo == 0) return '$value tasks today';
        return '$value tasks ($daysAgo days ago)';
      case 'Monthly':
        final daysAgo = 29 - index;
        if (daysAgo == 0) return '$value tasks today';
        return '$value tasks ($daysAgo days ago)';
      case 'Yearly':
        final weeksAgo = 51 - index;
        if (weeksAgo == 0) return '$value tasks this week';
        return '$value tasks ($weeksAgo weeks ago)';
      default:
        return '$value tasks';
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
              child: RefreshIndicator(
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
                      _buildPeriodSelector(),
                      const SizedBox(height: 24),
                      _buildPerformanceChart(),
                      const SizedBox(height: 32),
                      _buildActivityMap(),
                      const SizedBox(height: 32),
                      _buildAllTasks(),
                      const SizedBox(height: 100),
                    ],
                  ),
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

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 16) / 2;
          final numberFontSize = cardWidth * 0.32; // Increased font size
          final labelFontSize = cardWidth * 0.13; // Increased label size
          
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x0DFFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Current Streak',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 1.2,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
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
                          fontSize: 13,
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
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x0DFFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Total Done',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 1.2,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFF590df2),
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
                          fontSize: 13,
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

    return widget.hobbies.length > 0
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final period = label == 'WEEKLY' ? 'Weekly' : (label == 'MONTHLY' ? 'Monthly' : 'Yearly');
          setState(() => _selectedPeriod = period);
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
    );
  }

  Widget _buildPerformanceChart() {
    final growth = currentGrowth;
    final showBadge = growth != 0;
    final growthSign = growth >= 0 ? '+' : '';
    final chartData = performanceData;
    final labels = performanceLabels;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                performanceTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: growth >= 0 
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$growthSign${growth.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: growth >= 0 
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFF6B35),
                    ),
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
                GestureDetector(
                  onTapDown: (details) {
                    _handleChartTouch(details.localPosition, chartData);
                  },
                  onHorizontalDragStart: (details) {
                    _handleChartTouch(details.localPosition, chartData);
                  },
                  onHorizontalDragUpdate: (details) {
                    _handleChartTouch(details.localPosition, chartData);
                  },
                  onHorizontalDragEnd: (details) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() => _selectedDataPointIndex = null);
                      }
                    });
                  },
                  child: SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: PerformanceChartPainter(
                            chartData,
                            selectedIndex: _selectedDataPointIndex,
                          ),
                        ),
                        if (_selectedDataPointIndex != null && _selectedDataPointIndex! < chartData.length)
                          Positioned(
                            top: 0,
                            left: _calculateTooltipPosition(_selectedDataPointIndex!, chartData.length, context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                _getTooltipText(_selectedDataPointIndex!, chartData),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels
                      .map((label) => Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF71717A),
                              letterSpacing: 2.0,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMap() {
    final mapData = activityMapData;
    final isYearly = _selectedPeriod == 'Yearly';
    final crossAxisCount = isYearly ? 13 : 7; // 13 columns for 52 weeks, 7 for days

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activity Map',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                activityMapTitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
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
                // Day labels (only for non-yearly)
                if (!isYearly)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .map((day) => SizedBox(
                              width: 40,
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF71717A),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                if (!isYearly) const SizedBox(height: 8),
                // Heatmap grid with circles
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isYearly ? 4 : 8,
                    mainAxisSpacing: isYearly ? 4 : 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: mapData.length,
                  itemBuilder: (context, index) {
                    final data = mapData[index];
                    return Tooltip(
                      message: '${data['count']} tasks',
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF590df2)
                              .withOpacity(data['opacity']),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'ACTIVITY INTENSITY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF71717A),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [0.2, 0.6, 1.0]
                          .map((opacity) => Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF590df2)
                                      .withOpacity(opacity),
                                  shape: BoxShape.circle,
                                ),
                              ))
                          .toList(),
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
            'All Tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.hobbies.map((hobby) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x0DFFFFFF)),
                  ),
                  child: Row(
                    children: [
                      // Checkbox with priority color (left side)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _isCompletedToday(hobby)
                              ? _getPriorityColor(hobby.priority)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isCompletedToday(hobby)
                                ? _getPriorityColor(hobby.priority)
                                : const Color(0xFF4A4458),
                            width: 2,
                          ),
                        ),
                        child: _isCompletedToday(hobby)
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Name and frequency
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hobby.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getFrequencyText(hobby.repeatMode),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF71717A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Streak badge
                      if (hobby.currentStreak > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${hobby.currentStreak}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.local_fire_department,
                                color: Color(0xFFFF6B35),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      // Edit button
                      PopupMenuButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, color: Colors.white38, size: 22),
                        color: const Color(0xFF2A2738),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                                SizedBox(width: 10),
                                Text('Edit', style: TextStyle(color: Colors.white, fontSize: 14)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                SizedBox(width: 10),
                                Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Navigate to edit screen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddHobbyScreen(hobby: hobby),
                              ),
                            );
                            if (result == true) {
                              await widget.onRefresh();
                            }
                          } else if (value == 'delete') {
                            // Delete hobby
                            await _hobbyService.deleteHobby(hobby.id);
                            await widget.onRefresh();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  String _getFrequencyText(String repeatMode) {
    switch (repeatMode) {
      case 'Daily':
        return 'Every day';
      case 'Weekly':
        return '1 time a week';
      case 'Monthly':
        return 'Monthly goal';
      default:
        return 'Daily goal';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.green;
      case 'none':
      default:
        return const Color(0xFF6C3FFF); // Default purple
    }
  }

  bool _isCompletedToday(Hobby hobby) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return hobby.completions[today]?.completed ?? false;
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1733),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF3D3560),
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItemIcon(Icons.check_circle, 0),
              _buildNavItem(Icons.local_fire_department, 'Analytics', 1),
              _buildNavItemIcon(Icons.settings, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == 1; // Analytics is index 1
    return Expanded(
      flex: 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onNavigate(index),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6C3FFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white54,
                  size: 24,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemIcon(IconData icon, int index) {
    final isSelected = index == 1; // Analytics is index 1
    return Expanded(
      flex: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onNavigate(index),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF6C3FFF) : Colors.white38,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class PerformanceChartPainter extends CustomPainter {
  final List<double> data;
  final int? selectedIndex;

  PerformanceChartPainter(this.data, {this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF590df2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF590df2).withOpacity(0.3),
          const Color(0xFF590df2).withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxValue = data.isEmpty ? 1.0 : data.reduce(math.max);
    final minValue = data.isEmpty ? 0.0 : data.reduce(math.min);
    final range = maxValue - minValue;

    final path = Path();
    final fillPath = Path();
    
    List<Offset> points = [];

    // Calculate all points first
    for (int i = 0; i < data.length; i++) {
      final x = (i / math.max(data.length - 1, 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8) - (size.height * 0.1);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Start paths
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);
    path.moveTo(points[0].dx, points[0].dy);

    // Draw smooth curves using cubic bezier
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];

      // Calculate control points for smooth curve
      final tension = 0.4;
      final cp1x = p1.dx + (p2.dx - p0.dx) * tension;
      final cp1y = p1.dy + (p2.dy - p0.dy) * tension;
      final cp2x = p2.dx - (p3.dx - p1.dx) * tension;
      final cp2y = p2.dy - (p3.dy - p1.dy) * tension;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Close fill path
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw gradient fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw selected point indicator
    if (selectedIndex != null && selectedIndex! >= 0 && selectedIndex! < points.length) {
      final point = points[selectedIndex!];
      
      // Draw vertical line
      final linePaint = Paint()
        ..color = const Color(0xFF590df2).withOpacity(0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(point.dx, 0),
        Offset(point.dx, size.height),
        linePaint,
      );

      // Draw outer glow circle
      final glowPaint = Paint()
        ..color = const Color(0xFF590df2).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 10, glowPaint);

      // Draw main circle
      final circlePaint = Paint()
        ..color = const Color(0xFF590df2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 6, circlePaint);

      // Draw white outline
      final circleOutlinePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(point, 6, circleOutlinePaint);
    }
  }

  @override
  bool shouldRepaint(PerformanceChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.data != data;
  }
}

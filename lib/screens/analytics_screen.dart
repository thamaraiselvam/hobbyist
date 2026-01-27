import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hobby.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Hobby> hobbies;
  final VoidCallback onBack;
  final Function(int) onNavigate;

  const AnalyticsScreen({
    Key? key,
    required this.hobbies,
    required this.onBack,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Weekly';

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
      } else {
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

  double get completionRate {
    if (widget.hobbies.isEmpty) return 0;
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int completedToday = 0;
    
    for (var hobby in widget.hobbies) {
      if (hobby.completions[today]?.completed == true) {
        completedToday++;
      }
    }
    
    return widget.hobbies.length > 0 ? (completedToday / widget.hobbies.length * 100) : 0;
  }

  Map<String, int> get weeklyActivity {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final activity = <String, int>{};
    final now = DateTime.now();
    
    // Get Monday of current week
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
      activity[days[i]] = count;
    }
    
    return activity;
  }

  Map<String, int> get monthlyActivity {
    final weeks = <String, int>{};
    final now = DateTime.now();
    
    // Start from 4 weeks ago
    for (int i = 3; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: i * 7 + (now.weekday - 1)));
      final weekLabel = 'W${4 - i}';
      int count = 0;
      
      for (int j = 0; j < 7; j++) {
        final date = weekStart.add(Duration(days: j));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        for (var hobby in widget.hobbies) {
          if (hobby.completions[dateKey]?.completed == true) {
            count++;
          }
        }
      }
      weeks[weekLabel] = count;
    }
    
    return weeks;
  }

  Map<String, int> get yearlyActivity {
    final months = <String, int>{};
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    
    // Initialize all months with 0
    for (int i = 0; i < 12; i++) {
      months[monthNames[i]] = 0;
    }
    
    // Count completions for each hobby
    for (var hobby in widget.hobbies) {
      for (var entry in hobby.completions.entries) {
        if (entry.value.completed) {
          final date = entry.value.completedAt ?? DateTime.parse(entry.key);
          if (date.year == now.year && !date.isAfter(now)) {
            months[monthNames[date.month - 1]] = (months[monthNames[date.month - 1]] ?? 0) + 1;
          }
        }
      }
    }
    
    return months;
  }

  Map<String, int> get currentActivity {
    switch (_selectedPeriod) {
      case 'Monthly':
        return monthlyActivity;
      case 'Yearly':
        return yearlyActivity;
      default:
        return weeklyActivity;
    }
  }

  String get bestDay {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final today = DateFormat('yyyy-MM-dd').format(now);
    final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));
    
    Map<String, Map<String, dynamic>> dayData = {};
    
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      int count = 0;
      
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          count++;
        }
      }
      
      String displayDate;
      if (dateKey == today) {
        displayDate = 'Today';
      } else if (dateKey == yesterday) {
        displayDate = 'Yesterday';
      } else {
        displayDate = DateFormat('dd-MMM').format(date);
      }
      
      dayData[displayDate] = {
        'count': count,
        'dateKey': dateKey,
      };
    }
    
    if (dayData.isEmpty || dayData.values.every((v) => v['count'] == 0)) return 'N/A';
    
    final maxEntry = dayData.entries.reduce((a, b) => 
      (a.value['count'] as int) > (b.value['count'] as int) ? a : b
    );
    
    return maxEntry.key;
  }
  
  String get bestDaySubtitle {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    Map<String, int> dayData = {};
    
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      int count = 0;
      
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          count++;
        }
      }
      
      dayData[dateKey] = count;
    }
    
    if (dayData.isEmpty || dayData.values.every((v) => v == 0)) return 'No data yet';
    
    final maxEntry = dayData.entries.reduce((a, b) => 
      a.value > b.value ? a : b
    );
    
    return '${maxEntry.value} tasks';
  }

  double get dailyAverage {
    if (widget.hobbies.isEmpty) return 0;
    
    int totalTasks = 0;
    int daysWithData = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      int dayCount = 0;
      
      for (var hobby in widget.hobbies) {
        if (hobby.completions[dateKey]?.completed == true) {
          dayCount++;
        }
      }
      
      if (dayCount > 0) {
        totalTasks += dayCount;
        daysWithData++;
      }
    }
    
    return daysWithData > 0 ? totalTasks / daysWithData : 0;
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

  double get weeklyGrowth {
    if (totalCompletedLastWeek == 0) return totalCompletedThisWeek > 0 ? 100 : 0;
    return ((totalCompletedThisWeek - totalCompletedLastWeek) / totalCompletedLastWeek * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department, color: Color(0xFF6C3FFF), size: 32),
                  SizedBox(width: 12),
                  Text(
                    'Hobby Streaks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    'CURRENT STREAK',
                    '$currentStreak',
                    'Days',
                    'Keep it up!',
                    Icons.local_fire_department,
                    const Color(0xFFFF6B35),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    'TOTAL DONE',
                    '$totalCompleted',
                    'Tasks',
                    '${completionRate.toInt()}% Today',
                    Icons.check_circle,
                    const Color(0xFF6C3FFF),
                  )),
                ],
              ),
              const SizedBox(height: 24),
              _buildConsistencySection(),
              const SizedBox(height: 24),
              const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMiniStatCard(
                    'HIGHEST COMPLETION\nDAY',
                    bestDay,
                    bestDay != 'N/A' ? bestDaySubtitle : 'No data yet',
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMiniStatCard(
                    'DAILY AVERAGE',
                    '${dailyAverage.toStringAsFixed(1)} Tasks',
                    totalCompleted > 0 ? 'Last 7 days' : 'No completions',
                  )),
                ],
              ),
              const SizedBox(height: 12),
              if (totalCompleted > 0) _buildRoutineCards() else _buildNoDataCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2238),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.check_circle_outline, 'Tasks', 0),
            _buildNavItem(Icons.local_fire_department_outlined, 'Streaks', 1),
            _buildNavItem(Icons.settings_outlined, 'Settings', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == 1; // Analytics is index 1
    return GestureDetector(
      onTap: () => widget.onNavigate(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF6C3FFF) : Colors.white54,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6C3FFF) : Colors.white54,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF00D9A0),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consistency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPeriodTab('Weekly', _selectedPeriod == 'Weekly'),
                const SizedBox(width: 8),
                _buildPeriodTab('Monthly', _selectedPeriod == 'Monthly'),
                const SizedBox(width: 8),
                _buildPeriodTab('Yearly', _selectedPeriod == 'Yearly'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6C3FFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final activity = currentActivity;
    final maxActivity = activity.values.isEmpty || activity.values.every((v) => v == 0) 
        ? 1 
        : activity.values.reduce((a, b) => a > b ? a : b);
    
    return _selectedPeriod == 'Yearly' 
        ? _buildYearlyGitHubStyle()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: activity.entries.map((entry) {
              final intensity = maxActivity > 0 ? entry.value / maxActivity : 0;
              final todayLabel = DateFormat('E').format(DateTime.now()).toUpperCase().substring(0, 3);
              final isToday = _selectedPeriod == 'Weekly' && entry.key == todayLabel;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: entry.value > 0
                              ? (intensity > 0.6 
                                  ? const Color(0xFF6C3FFF)
                                  : const Color(0xFF8B5CF6))
                              : const Color(0xFF3D3449),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isToday ? const Color(0xFF6C3FFF) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            entry.value > 0 ? '${entry.value}' : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getChartLabel(entry.key),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
  }

  Widget _buildYearlyGitHubStyle() {
    final activity = yearlyActivity;
    final maxActivity = activity.values.isEmpty || activity.values.every((v) => v == 0) 
        ? 1 
        : activity.values.reduce((a, b) => a > b ? a : b);
    
    return Row(
      children: activity.entries.map((entry) {
        final intensity = maxActivity > 0 ? entry.value / maxActivity : 0;
        Color boxColor;
        
        if (entry.value == 0) {
          boxColor = const Color(0xFF3D3449);
        } else if (intensity <= 0.33) {
          boxColor = const Color(0xFF5C3FBF);
        } else if (intensity <= 0.66) {
          boxColor = const Color(0xFF7B5CE6);
        } else {
          boxColor = const Color(0xFF6C3FFF);
        }
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: entry.value > 0
                        ? Text(
                            '${entry.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getChartLabel(String key) {
    if (_selectedPeriod == 'Weekly') {
      return key.substring(0, 1);
    } else if (_selectedPeriod == 'Monthly') {
      return key;
    } else {
      // Yearly - show single character
      return key;
    }
  }

  Widget _buildInsightCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C3FFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String value, String subtitle) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF6C3FFF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCards() {
    final dailyHobbies = widget.hobbies.where((h) => h.repeatMode == 'daily').toList();
    final weeklyHobbies = widget.hobbies.where((h) => h.repeatMode == 'weekly').toList();
    final monthlyHobbies = widget.hobbies.where((h) => h.repeatMode == 'monthly').toList();
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    List<Widget> cards = [];
    
    if (dailyHobbies.isNotEmpty) {
      int completed = dailyHobbies.where((h) => h.completions[today]?.completed == true).length;
      int percentage = ((completed / dailyHobbies.length) * 100).toInt();
      cards.add(_buildRoutineMiniCard('DAILY ROUTINE', '$percentage%', '$completed of ${dailyHobbies.length} tasks'));
    }
    
    if (weeklyHobbies.isNotEmpty) {
      int completed = 0;
      for (int i = 0; i < 7; i++) {
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: i)));
        completed += weeklyHobbies.where((h) => h.completions[date]?.completed == true).length;
      }
      int total = weeklyHobbies.length;
      int percentage = total > 0 ? ((completed / total) * 100).toInt() : 0;
      cards.add(_buildRoutineMiniCard('WEEKLY ROUTINE', '$percentage%', '$completed of $total tasks'));
    }
    
    if (monthlyHobbies.isNotEmpty) {
      int completed = 0;
      for (int i = 0; i < 30; i++) {
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: i)));
        completed += monthlyHobbies.where((h) => h.completions[date]?.completed == true).length;
      }
      int total = monthlyHobbies.length;
      int percentage = total > 0 ? ((completed / total) * 100).toInt() : 0;
      cards.add(_buildRoutineMiniCard('MONTHLY ROUTINE', '$percentage%', '$completed of $total tasks'));
    }
    
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Create rows of 2 cards each
    List<Widget> rows = [];
    for (int i = 0; i < cards.length; i += 2) {
      if (i + 1 < cards.length) {
        rows.add(Row(
          children: [
            Expanded(child: cards[i]),
            const SizedBox(width: 12),
            Expanded(child: cards[i + 1]),
          ],
        ));
      } else {
        rows.add(Row(
          children: [
            Expanded(child: cards[i]),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ));
      }
    }
    
    return Column(
      children: rows.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: row,
      )).toList(),
    );
  }

  Widget _buildRoutineMiniCard(String label, String value, String subtitle) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF6C3FFF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C3FFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: Color(0xFF8B5CF6), size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Tracking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete tasks to see your progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

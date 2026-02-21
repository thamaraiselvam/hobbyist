// ignore_for_file: avoid_print, use_build_context_synchronously, body_might_complete_normally_catch_error
import 'package:flutter/material.dart';
import '../constants/test_keys.dart';
import 'package:intl/intl.dart';
import '../models/hobby.dart';
import '../services/hobby_service.dart';
import '../services/sound_service.dart';
import '../services/quote_service.dart';
import '../widgets/animated_checkbox.dart';
import '../utils/page_transitions.dart';
import 'add_hobby_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'tasks_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/home_widget_service.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen>
    with AutomaticKeepAliveClientMixin {
  final HobbyService _service = HobbyService();
  final SoundService _soundService = SoundService();
  final QuoteService _quoteService = QuoteService();

  List<Hobby> _allHobbies = [];
  bool _loading = true;
  int _selectedIndex = 0;
  String _currentQuote = '';
  bool _pullToRefreshEnabled = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _loadHobbies();
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

  Future<void> _loadQuote() async {
    setState(() => _currentQuote = _quoteService.getRandomQuote());
  }

  Future<void> _loadHobbies() async {
    setState(() => _loading = true);
    final allHobbies = await _service.loadHobbies();
    setState(() {
      _allHobbies = allHobbies;
      _loading = false;
    });
    _pushHomeWidget();
  }

  /// Pushes current streak state to the Android home-screen widget.
  void _pushHomeWidget() {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0 = Mon, 6 = Sun
    final weekStart = now.subtract(Duration(days: todayIndex));
    final fmt = DateFormat('yyyy-MM-dd');
    final completedDays = List.generate(7, (i) {
      final key = fmt.format(weekStart.add(Duration(days: i)));
      return _allHobbies.any((h) => h.completions[key]?.completed == true);
    });
    HomeWidgetService.push(
      streak: _globalStreakData['streak'] as int,
      completedDaysInWeek: completedDays,
      currentDayIndex: todayIndex,
    );
  }

  Future<void> _refreshFromOtherScreen() async {
    await _loadHobbies();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool _isHobbyAvailableForDate(Hobby hobby, DateTime date) {
    switch (hobby.repeatMode.toLowerCase()) {
      case 'daily':
        return true;
      case 'weekly':
        final days = hobby.effectiveWeekDays;
        if (days.isEmpty) return true;
        final weekday = date.weekday; // 1=Mon … 7=Sun
        final dayIndex = weekday == 7 ? 6 : weekday - 1;
        return days.contains(dayIndex);
      case 'monthly':
        if (hobby.customDay == null) return true;
        return date.day == hobby.customDay;
      case 'one_time':
        return true;
      default:
        return true;
    }
  }

  /// True if the hobby has any occurrence within the next 1–7 days.
  bool _hasOccurrenceInNext7Days(Hobby hobby) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (int i = 1; i <= 7; i++) {
      if (_isHobbyAvailableForDate(hobby, today.add(Duration(days: i)))) {
        return true;
      }
    }
    return false;
  }

  // ── Derived sections ─────────────────────────────────────────────────

  /// Tasks scheduled for today that are not yet completed.
  List<Hobby> get _pendingTasks {
    final today = DateTime.now();
    final tasks = _allHobbies.where((h) {
      if (!_isHobbyAvailableForDate(h, today)) return false;
      if (h.isOneTime) return !h.completions.values.any((c) => c.completed);
      return h.completions[_todayKey]?.completed != true;
    }).toList()
      ..sort(_sortByReminderTime);
    return tasks;
  }

  /// Non-daily tasks with an occurrence in the next 1–7 days that have not
  /// been completed early today.
  List<Hobby> get _upcomingTasks {
    final today = DateTime.now();
    final tasks = _allHobbies.where((h) {
      if (h.isOneTime) return false;
      if (h.repeatMode.toLowerCase() == 'daily') return false;
      if (_isHobbyAvailableForDate(h, today)) return false; // in Today section
      if (h.completions[_todayKey]?.completed == true) return false; // completed early
      return _hasOccurrenceInNext7Days(h);
    }).toList()
      ..sort(_sortByNextOccurrence);
    return tasks;
  }

  /// Hobbies with at least one completion in the last 7 days, sorted by
  /// most-recent completion descending.
  List<Hobby> get _completedTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 6));

    bool inWindow(String dateKey) {
      final parts = dateKey.split('-');
      if (parts.length != 3) return false;
      final d = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return !d.isBefore(sevenDaysAgo) && !d.isAfter(today);
    }

    final tasks = _allHobbies.where((h) {
      return h.completions.entries.any(
        (e) => e.value.completed && inWindow(e.key),
      );
    }).toList()
      ..sort(_sortByRecentCompletion);
    return tasks;
  }

  // ── Sort helpers ─────────────────────────────────────────────────────

  int _sortByReminderTime(Hobby a, Hobby b) {
    if (a.reminderTime == null && b.reminderTime == null) return 0;
    if (a.reminderTime == null) return 1;
    if (b.reminderTime == null) return -1;
    return a.reminderTime!.compareTo(b.reminderTime!);
  }

  int _sortByNextOccurrence(Hobby a, Hobby b) {
    final aDate = _getNextOccurrence(a);
    final bDate = _getNextOccurrence(b);
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  }

  int _sortByRecentCompletion(Hobby a, Hobby b) {
    final aTime = _mostRecentCompletionInWindow(a);
    final bTime = _mostRecentCompletionInWindow(b);
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime); // Latest first
  }

  /// Most-recent completedAt timestamp within the last-7-days window.
  DateTime? _mostRecentCompletionInWindow(Hobby hobby) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    DateTime? best;
    for (final entry in hobby.completions.entries) {
      if (!entry.value.completed) continue;
      final parts = entry.key.split('-');
      if (parts.length != 3) continue;
      final d = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (d.isBefore(sevenDaysAgo) || d.isAfter(today)) continue;
      final ts = entry.value.completedAt ?? d;
      if (best == null || ts.isAfter(best)) best = ts;
    }
    return best;
  }

  /// Human-readable label for the most-recent completion within last 7 days.
  String? _completionDateLabel(Hobby hobby) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    String? bestKey;
    for (final entry in hobby.completions.entries) {
      if (!entry.value.completed) continue;
      final parts = entry.key.split('-');
      if (parts.length != 3) continue;
      final d = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (d.isBefore(sevenDaysAgo) || d.isAfter(today)) continue;
      if (bestKey == null || entry.key.compareTo(bestKey) > 0) {
        bestKey = entry.key;
      }
    }
    if (bestKey == null) return null;
    final parts = bestKey.split('-');
    final d = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d').format(d);
  }

  /// Next occurrence of a hobby within the next 7 days (tomorrow onward).
  DateTime? _getNextOccurrence(Hobby hobby) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (int i = 1; i <= 7; i++) {
      final d = today.add(Duration(days: i));
      if (_isHobbyAvailableForDate(hobby, d)) return d;
    }
    return null;
  }

  // ── Metrics ──────────────────────────────────────────────────────────

  int get _scheduledTodayCount {
    final today = DateTime.now();
    return _allHobbies.where((h) {
      if (h.isOneTime) return false;
      return _isHobbyAvailableForDate(h, today);
    }).length;
  }

  int get _completedTodayCount {
    final today = DateTime.now();
    return _allHobbies.where((h) {
      if (h.isOneTime) return false;
      if (!_isHobbyAvailableForDate(h, today)) return false;
      return h.completions[_todayKey]?.completed == true;
    }).length;
  }

  int get _todayCompletionPercent {
    if (_scheduledTodayCount == 0) return 0;
    return (_completedTodayCount / _scheduledTodayCount * 100)
        .round()
        .clamp(0, 100);
  }

  Map<String, dynamic> get _globalStreakData {
    if (_allHobbies.isEmpty) return {'streak': 0, 'todayCompleted': false};
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final bool todayCompleted = _allHobbies.any(
      (h) => h.completions[todayKey]?.completed == true,
    );
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final bool any =
          _allHobbies.any((h) => h.completions[dateKey]?.completed == true);
      if (any) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return {'streak': streak, 'todayCompleted': todayCompleted};
  }

  // ── Toggle ───────────────────────────────────────────────────────────

  Future<void> _toggleToday(Hobby hobby) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool isCurrentlyCompleted;
    String toggleDate;

    if (hobby.isOneTime) {
      isCurrentlyCompleted =
          hobby.completions.values.any((c) => c.completed);
      if (isCurrentlyCompleted) {
        // Find the date it was originally completed to toggle it off.
        final entry = hobby.completions.entries.firstWhere(
          (e) => e.value.completed,
          orElse: () =>
              MapEntry(today, HobbyCompletion(completed: false)),
        );
        toggleDate = entry.key;
      } else {
        toggleDate = today;
      }
    } else {
      isCurrentlyCompleted =
          hobby.completions[today]?.completed ?? false;
      toggleDate = today;
    }

    final updatedCompletions =
        Map<String, HobbyCompletion>.from(hobby.completions);
    updatedCompletions[toggleDate] = HobbyCompletion(
      completed: !isCurrentlyCompleted,
      completedAt: !isCurrentlyCompleted ? DateTime.now() : null,
    );

    final updatedHobby = hobby.copyWith(completions: updatedCompletions);
    final calculatedBest = updatedHobby.calculateBestStreakFromHistory();
    final newBest = calculatedBest > updatedHobby.currentStreak
        ? calculatedBest
        : updatedHobby.currentStreak;
    final finalHobby = updatedHobby.copyWith(bestStreak: newBest);

    setState(() {
      final idx = _allHobbies.indexWhere((h) => h.id == hobby.id);
      if (idx != -1) _allHobbies[idx] = finalHobby;
    });
    _pushHomeWidget();

    if (!isCurrentlyCompleted) _soundService.playCompletionSound();

    _service.toggleCompletion(hobby.id, toggleDate).catchError((error) {
      print('⚠️ Error syncing completion: $error');
      if (mounted && error.toString().contains('Database')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to sync completion',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFFD84A4A),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildTasksScreen(),
        TasksListScreen(
          hobbies: _allHobbies,
          onBack: () => setState(() => _selectedIndex = 0),
          onNavigate: (index) => setState(() => _selectedIndex = index),
          onRefresh: _refreshFromOtherScreen,
        ),
        AnalyticsScreen(
          hobbies: _allHobbies,
          onBack: () => setState(() => _selectedIndex = 0),
          onNavigate: (index) => setState(() => _selectedIndex = index),
          onRefresh: _refreshFromOtherScreen,
        ),
        SettingsScreen(
          onBack: () => setState(() => _selectedIndex = 0),
          onNavigate: (index) => setState(() => _selectedIndex = index),
        ),
      ],
    );
  }

  Widget _buildTasksScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _pullToRefreshEnabled
                        ? RefreshIndicator(
                            onRefresh: _loadHobbies,
                            color: const Color(0xFF6C3FFF),
                            backgroundColor: const Color(0xFF2A2139),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _buildScrollContent(),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildScrollContent(),
                          ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final streakData = _globalStreakData;
    final globalStreak = streakData['streak'] as int;
    final todayCompleted = streakData['todayCompleted'] as bool;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String?>(
            future: _service.getSetting('userName'),
            builder: (context, snapshot) {
              final userName = snapshot.data ?? 'Tham';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    DateFormat('EEEE, MMM dd').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
          if (_allHobbies.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildMetricsTiles(globalStreak, todayCompleted),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsTiles(int globalStreak, bool todayCompleted) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.today_outlined,
            iconColor: const Color(0xFF10B981),
            label: 'Today',
            value: '$_todayCompletionPercent%',
            valueColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            identifier: TestKeys.streakBadge,
            child: GestureDetector(
              key: const Key(TestKeys.streakBadge),
              onTap: () => setState(() => _selectedIndex = 2),
              child: _buildMetricTile(
                icon: Icons.local_fire_department,
                iconColor: todayCompleted
                    ? const Color(0xFFFF6B35)
                    : Colors.grey.withValues(alpha: 0.5),
                label: 'Streak',
                value: '$globalStreak',
                valueColor: todayCompleted
                    ? const Color(0xFFFF6B35)
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Scroll content ────────────────────────────────────────────────────

  Widget _buildScrollContent() {
    if (_allHobbies.isEmpty) return _buildWelcomeState();

    final pending = _pendingTasks;
    final upcoming = _upcomingTasks;
    final completed = _completedTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildTimelineSection(
          title: "Today's Tasks",
          count: pending.length,
          dotColor: const Color(0xFF6C3FFF),
          isLast: false,
          emptyChild: _buildSectionEmpty(
            icon: Icons.celebration,
            color: const Color(0xFF10B981),
            message: 'All done for today!',
          ),
          children: pending.map((h) => _buildTaskCard(h)).toList(),
        ),
        _buildTimelineSection(
          title: 'Upcoming (Next 7 Days)',
          count: upcoming.length,
          dotColor: const Color(0xFF0EA5E9),
          isLast: false,
          emptyChild: _buildSectionEmpty(
            icon: Icons.calendar_today_outlined,
            color: const Color(0xFF0EA5E9),
            message: 'No upcoming tasks',
          ),
          children: upcoming
              .map((h) => _buildTaskCard(h, isUpcoming: true))
              .toList(),
        ),
        _buildTimelineSection(
          title: 'Completed (Last 7 Days)',
          count: completed.length,
          dotColor: const Color(0xFF10B981),
          isLast: true,
          emptyChild: _buildSectionEmpty(
            icon: Icons.history,
            color: const Color(0xFF94A3B8),
            message: 'Your progress will appear here',
          ),
          children: completed
              .map(
                (h) => TweenAnimationBuilder<double>(
                  key: ValueKey('${h.id}_completed'),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, opacity, child) =>
                      Opacity(opacity: opacity, child: child),
                  child: _buildTaskCard(
                    h,
                    isCompleted: true,
                    completionDateLabel: _completionDateLabel(h),
                  ),
                ),
              )
              .toList(),
        ),
        _buildQuoteSection(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimelineSection({
    required String title,
    required int count,
    required Color dotColor,
    required bool isLast,
    required List<Widget> children,
    Widget? emptyChild,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              dotColor.withValues(alpha: 0.5),
                              dotColor.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: dotColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: dotColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (children.isEmpty && emptyChild != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: emptyChild,
                    )
                  else
                    ...children,
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionEmpty({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          message,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Welcome to Hobbyist! 👋',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'No hobbies yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button below to create your first hobby\nand start building your habit streak!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      child: Text(
        _currentQuote,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
        maxLines: null,
        softWrap: true,
      ),
    );
  }

  // ── Task card ─────────────────────────────────────────────────────────

  Widget _buildTaskCard(
    Hobby hobby, {
    bool isCompleted = false,
    bool isUpcoming = false,
    String? completionDateLabel,
  }) {
    final nextDate = isUpcoming ? _getNextOccurrence(hobby) : null;

    return AnimatedContainer(
      key: Key(TestKeys.taskCard(hobby.id)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Opacity(
        opacity: isCompleted ? 0.55 : 1.0,
        child: Row(
          children: [
            // Checkbox
            Semantics(
              identifier: TestKeys.taskCheckbox(hobby.id),
              child: AnimatedCheckbox(
                key: Key(TestKeys.taskCheckbox(hobby.id)),
                isChecked: isCompleted,
                onTap: () => _toggleToday(hobby),
                size: 24,
                color: Color(hobby.color),
              ),
            ),
            const SizedBox(width: 10),
            // Name, notes, badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hobby.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.white38,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                      // Next-occurrence chip for upcoming tasks
                      if (isUpcoming && nextDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat('MMM d').format(nextDate),
                            style: const TextStyle(
                              color: Color(0xFF0EA5E9),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      // Completion date chip for completed tasks
                      if (isCompleted && completionDateLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            completionDateLabel,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hobby.notes.isNotEmpty
                              ? hobby.notes
                              : _getFrequencyText(hobby.repeatMode),
                          style: TextStyle(
                            color: const Color(0xFF71717A),
                            fontSize: 12,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.white38,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Streak badges — only on pending recurring tasks
                      if (!hobby.isOneTime &&
                          !isCompleted &&
                          !isUpcoming &&
                          (hobby.currentStreak > 0 ||
                              hobby.bestStreak > 0)) ...[
                        const SizedBox(width: 8),
                        if (hobby.currentStreak > 0)
                          _buildStreakBadge(
                            '${hobby.currentStreak}',
                            Icons.local_fire_department,
                            const Color(0xFFFF6B35),
                          ),
                        if (hobby.bestStreak > 0) ...[
                          const SizedBox(width: 6),
                          _buildStreakBadge(
                            '${hobby.bestStreak}',
                            Icons.emoji_events,
                            const Color(0xFFFFD700),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Context menu
            PopupMenuButton<String>(
              key: Key(TestKeys.hobbyMenu(hobby.id)),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white38,
                size: 22,
              ),
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
                      Text(
                        'Edit',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  await Navigator.push(
                    context,
                    SlidePageRoute(
                      page: AddHobbyScreen(hobby: hobby),
                      direction: AxisDirection.left,
                    ),
                  );
                  await _loadHobbies();
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF2A2738),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Delete Hobby?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete "${hobby.name}"? '
                        'This action cannot be undone and will remove all '
                        'completion history.',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      final hobbyName = hobby.name;
                      await _service.deleteHobby(hobby.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🗑️ Hobby "$hobbyName" deleted successfully',
                            ),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      await _loadHobbies();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '❌ Error deleting hobby: ${e.toString()}',
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBadge(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: color, size: 18),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────

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
    return Semantics(
      identifier: TestKeys.addHobbyFab,
      child: GestureDetector(
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
          await _loadHobbies();
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
      ),
    );
  }

  Widget _buildNavItemIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          identifier: TestKeys.navItem(index),
          child: InkWell(
            key: Key(TestKeys.navItem(index)),
            onTap: () => setState(() => _selectedIndex = index),
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
                color: isSelected
                    ? const Color(0xFF1E1733)
                    : Colors.white38,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Utilities ──────────────────────────────────────────────────────────

  String _getFrequencyText(String repeatMode) {
    switch (repeatMode.toLowerCase()) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        return '1 time a week';
      case 'monthly':
        return 'Monthly goal';
      case 'one_time':
        return 'One-time task';
      default:
        return 'Daily goal';
    }
  }
}


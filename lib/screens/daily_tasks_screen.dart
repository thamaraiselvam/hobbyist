// ignore_for_file: avoid_print, use_build_context_synchronously, unused_element, body_might_complete_normally_catch_error
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
  final ScrollController _dayScrollController = ScrollController();
  List<Hobby> _hobbies = [];
  List<Hobby> _allHobbies = [];
  bool _loading = true;
  int _selectedIndex = 0;
  String _currentQuote = '';
  DateTime _selectedDate = DateTime.now();
  bool _hasAnimatedToToday = false; // Track if we've done initial animation
  bool _pullToRefreshEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _loadHobbies();
    _loadSettings();
    // Animate from start to today after build (only once on first load)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasAnimatedToToday) {
          _hasAnimatedToToday = true;
          _animateToToday();
        }
      });
    });
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
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 1=Monday, 7=Sunday. We want Monday to be start.
    return today.subtract(Duration(days: today.weekday - 1));
  }

  void _animateToToday() async {
    if (!mounted || !_dayScrollController.hasClients) return;

    try {
      // Calculate centered position for today
      final screenWidth = MediaQuery.of(context).size.width;
      const itemWidth = 56.0; // 48px pill + 8px margin
      const pillWidth = 48.0; // Actual pill width
      final todayIndex =
          DateTime.now().weekday - 1; // Index based on current weekday (0-6)
      const listPadding = 16.0; // ListView horizontal padding

      // Position of today's item (from start of list)
      final todayPosition = todayIndex * itemWidth;

      // Center calculation:
      // We want the pill center at screen center
      // Scroll position to get left edge of pill to center: todayPosition - (screenWidth / 2)
      // Then move back by half the pill width: + (pillWidth / 2)
      // Account for the list padding: + listPadding
      final centeredPosition =
          todayPosition - (screenWidth / 2) + (pillWidth / 2) + listPadding;

      final maxScroll = _dayScrollController.position.maxScrollExtent;
      final targetPosition = centeredPosition.clamp(0.0, maxScroll);

      // Animate to today
      await _dayScrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    } catch (e) {
      print('Animation error: $e');
    }
  }

  void _animateToSelectedDate() async {
    if (!mounted || !_dayScrollController.hasClients) return;

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      // Calculate how many days from the start of the week
      final startOfWeek = _getStartOfWeek();
      final daysDifference = _selectedDate.difference(startOfWeek).inDays;

      // Calculate centered position
      final screenWidth = MediaQuery.of(context).size.width;
      const itemWidth = 56.0; // 48px pill + 8px margin
      const pillWidth = 48.0; // Actual pill width
      const listPadding = 16.0; // ListView horizontal padding

      final datePosition = daysDifference * itemWidth;
      final centeredPosition =
          datePosition - (screenWidth / 2) + (pillWidth / 2) + listPadding;

      final maxScroll = _dayScrollController.position.maxScrollExtent;
      final targetPosition = centeredPosition.clamp(0.0, maxScroll);

      // Animate to selected date
      await _dayScrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } catch (e) {
      print('Animation error: $e');
    }
  }

  Future<void> _loadQuote() async {
    setState(() {
      _currentQuote = _quoteService.getRandomQuote();
    });
  }

  Future<void> _loadHobbies({bool preserveScrollPosition = true}) async {
    // Only preserve scroll position if we're on home screen (index 0) and requested
    final shouldPreserveScroll =
        preserveScrollPosition &&
        _selectedIndex == 0 &&
        _dayScrollController.hasClients;
    final currentScrollOffset = shouldPreserveScroll
        ? _dayScrollController.offset
        : null;

    setState(() => _loading = true);
    final allHobbies = await _service.loadHobbies();
    // Filter out one-time tasks that have been completed at any point
    final hobbies = allHobbies.where((h) {
      if (!h.isOneTime) return true;
      return !h.completions.values.any((c) => c.completed);
    }).toList();
    setState(() {
      _allHobbies = allHobbies;
      _hobbies = hobbies;
      _loading = false;
    });

    // Restore scroll position after rebuild if it was saved
    if (currentScrollOffset != null && _dayScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _dayScrollController.hasClients) {
          _dayScrollController.jumpTo(currentScrollOffset);
        }
      });
    } else if (_selectedIndex == 0 && !shouldPreserveScroll) {
      // If we're on home screen but didn't preserve scroll, animate to today
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateToSelectedDate();
      });
    }
  }

  Future<void> _refreshFromOtherScreen() async {
    // Reset to today when refreshing from other screens
    setState(() {
      _selectedDate = DateTime.now();
    });
    await _loadHobbies(preserveScrollPosition: false);
  }

  Future<void> _refreshToToday() async {
    // Reset to today
    setState(() {
      _selectedDate = DateTime.now();
    });

    // Load hobbies without preserving scroll position
    await _loadHobbies(preserveScrollPosition: false);

    // Animate to today after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _dayScrollController.hasClients) {
        // Use the same logic as _animateToSelectedDate for consistency
        final screenWidth = MediaQuery.of(context).size.width;
        const itemWidth = 56.0; // 48px pill + 8px margin
        const pillWidth = 48.0; // Actual pill width
        const listPadding = 16.0; // ListView horizontal padding
        final todayIndex = DateTime.now().weekday - 1; // Index is 0-6

        final datePosition = todayIndex * itemWidth;
        final centeredPosition =
            datePosition - (screenWidth / 2) + (pillWidth / 2) + listPadding;

        final maxScroll = _dayScrollController.position.maxScrollExtent;
        final targetPosition = centeredPosition.clamp(0.0, maxScroll);

        _dayScrollController.animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _toggleToday(Hobby hobby) async {
    // Prevent completing tasks in the future
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (selectedDateOnly.isAfter(todayDate)) {
      // Show message that future tasks cannot be completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot complete tasks for future dates',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFD84A4A), // Readable red
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final selectedDay = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final isCompleted = hobby.completions[selectedDay]?.completed ?? false;

    // Update UI immediately for responsive feel
    final updatedCompletions = Map<String, HobbyCompletion>.from(
      hobby.completions,
    );
    updatedCompletions[selectedDay] = HobbyCompletion(
      completed: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );

    // Create updated hobby with new completions
    final updatedHobby = hobby.copyWith(completions: updatedCompletions);

    // Recalculate best streak immediately with new data
    final calculatedBestStreak = updatedHobby.calculateBestStreakFromHistory();
    final newBestStreak = calculatedBestStreak > updatedHobby.currentStreak
        ? calculatedBestStreak
        : updatedHobby.currentStreak;

    // Update hobby with new best streak
    final finalHobby = updatedHobby.copyWith(bestStreak: newBestStreak);

    // Update UI immediately with recalculated best streak
    setState(() {
      final index = _hobbies.indexWhere((h) => h.id == hobby.id);
      if (index != -1) {
        _hobbies[index] = finalHobby;
      }
    });

    // Play completion sound when marking as complete
    if (!isCompleted) {
      _soundService.playCompletionSound();
    }

    // Sync to backend asynchronously (fire and forget - no UI updates)
    _service.toggleCompletion(hobby.id, selectedDay).catchError((error) {
      print('⚠️ Error syncing completion: $error');
      // Only show error if it's a real database error, not a Future error
      if (mounted && error.toString().contains('Database')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to sync completion',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFFD84A4A), // Readable red
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  // Check if a hobby should be shown on the selected date
  bool _isHobbyAvailableForDate(Hobby hobby, DateTime date) {
    switch (hobby.repeatMode.toLowerCase()) {
      case 'daily':
        return true; // Daily tasks are always available

      case 'weekly':
        // For weekly tasks, check if customDay matches the weekday
        // customDay: 0=Monday, 1=Tuesday, ..., 6=Sunday
        if (hobby.customDay == null) return true; // Show if no specific day set
        final weekday = date.weekday; // 1=Monday, 2=Tuesday, ..., 7=Sunday
        // Convert weekday to 0-indexed (0=Monday)
        final dayIndex = weekday == 7 ? 6 : weekday - 1;
        return hobby.customDay == dayIndex;

      case 'monthly':
        // For monthly tasks, check if customDay matches the day of month
        if (hobby.customDay == null) return true; // Show if no specific day set
        return date.day == hobby.customDay;

      case 'one_time':
        return true; // Always available until completed (filtered out from _hobbies once done)

      default:
        return true; // Show by default for unknown repeat modes
    }
  }

  int get completedToday {
    final today = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _hobbies
        .where(
          (h) =>
              _isHobbyAvailableForDate(h, _selectedDate) &&
              h.completions[today]?.completed == true,
        )
        .length;
  }

  int get totalTasksForSelectedDate {
    return _hobbies
        .where((h) => _isHobbyAvailableForDate(h, _selectedDate))
        .length;
  }

  double get progressPercentage {
    final totalTasks = totalTasksForSelectedDate;
    if (totalTasks == 0) return 0.0;
    final completed = completedToday;
    return (completed / totalTasks * 100).toDouble();
  }

  List<Hobby> get inProgressTasks {
    final today = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _hobbies
        .where(
          (h) =>
              _isHobbyAvailableForDate(h, _selectedDate) &&
              h.completions[today]?.completed != true,
        )
        .toList();
  }

  List<Hobby> get completedTasks {
    final today = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _hobbies
        .where(
          (h) =>
              _isHobbyAvailableForDate(h, _selectedDate) &&
              h.completions[today]?.completed == true,
        )
        .toList();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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
          hobbies: _hobbies,
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
                  _buildDaySelector(),
                  Expanded(
                    child: _pullToRefreshEnabled
                        ? RefreshIndicator(
                            onRefresh: _refreshToToday,
                            color: const Color(0xFF6C3FFF),
                            backgroundColor: const Color(0xFF2A2139),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  // Empty state: No hobbies at all
                                  if (_hobbies.isEmpty) ...[
                                    const SizedBox(height: 80),
                                    const Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.task_alt,
                                            size: 80,
                                            color: Colors.white24,
                                          ),
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
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 120),
                                  ]
                                  // Check if there are tasks for this day
                                  else if (totalTasksForSelectedDate == 0) ...[
                                    // No tasks for this day - show centered message
                                    const SizedBox(height: 120),
                                    Center(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.event_available,
                                            size: 80,
                                            color: Colors.white24,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _isToday()
                                                ? 'No tasks for today'
                                                : 'No tasks for this day',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _isToday()
                                                ? 'Enjoy your free day!'
                                                : 'No hobbies scheduled for this day',
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 120),
                                  ] else ...[
                                    // Has tasks - show normal layout
                                    if (inProgressTasks.isNotEmpty) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _isFutureDate()
                                                ? 'Upcoming Tasks'
                                                : (_isToday()
                                                      ? 'In Progress'
                                                      : 'Not Completed'),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '${inProgressTasks.length} Pending',
                                            style: const TextStyle(
                                              color: Color(0xFF8B5CF6),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ...inProgressTasks.map(
                                        (hobby) => _buildTaskCard(hobby, false),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    if (completedTasks.isNotEmpty) ...[
                                      Text(
                                        _isToday()
                                            ? 'Completed Today'
                                            : 'Completed',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...completedTasks.map(
                                        (hobby) => _buildTaskCard(hobby, true),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                  // Quote at the bottom (always)
                                  _buildQuoteSection(),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                // Empty state: No hobbies at all
                                if (_hobbies.isEmpty) ...[
                                  const SizedBox(height: 80),
                                  const Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.task_alt,
                                          size: 80,
                                          color: Colors.white24,
                                        ),
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
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 120),
                                ]
                                // Check if there are tasks for this day
                                else if (totalTasksForSelectedDate == 0) ...[
                                  // No tasks for this day - show centered message
                                  const SizedBox(height: 120),
                                  Center(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.event_available,
                                          size: 80,
                                          color: Colors.white24,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _isToday()
                                              ? 'No tasks for today'
                                              : 'No tasks for this day',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _isToday()
                                              ? 'Enjoy your free day!'
                                              : 'No hobbies scheduled for this day',
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 120),
                                ] else ...[
                                  // Has tasks - show normal layout
                                  if (inProgressTasks.isNotEmpty) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _isFutureDate()
                                              ? 'Upcoming Tasks'
                                              : (_isToday()
                                                    ? 'In Progress'
                                                    : 'Not Completed'),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '${inProgressTasks.length} Pending',
                                          style: const TextStyle(
                                            color: Color(0xFF8B5CF6),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...inProgressTasks.map(
                                      (hobby) => _buildTaskCard(hobby, false),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (completedTasks.isNotEmpty &&
                                      !_isFutureDate()) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Completed',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF10B981,
                                            ).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF10B981),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${completedTasks.length}',
                                                style: const TextStyle(
                                                  color: Color(0xFF10B981),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...completedTasks.map(
                                      (hobby) => _buildTaskCard(hobby, true),
                                    ),
                                  ],
                                ],
                                // Quote at the bottom (always)
                                _buildQuoteSection(),
                                const SizedBox(height: 16),
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
    // Calculate global streak (any task completed counts)
    Map<String, dynamic> calculateGlobalStreak() {
      int streak = 0;
      bool todayCompleted = false;
      final today = DateTime.now();
      final todayKey = DateFormat('yyyy-MM-dd').format(today);

      // Check if today has any completions
      for (var hobby in _hobbies) {
        if (hobby.completions[todayKey]?.completed == true) {
          todayCompleted = true;
          break;
        }
      }

      // Count consecutive days starting from today
      for (int i = 0; i < 365; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        bool anyTaskCompleted = false;
        for (var hobby in _hobbies) {
          if (hobby.completions[dateKey]?.completed == true) {
            anyTaskCompleted = true;
            break;
          }
        }

        if (anyTaskCompleted) {
          streak++;
        } else if (i > 0) {
          // Don't break on today if it's not completed yet
          break;
        }
      }

      return {'streak': streak, 'todayCompleted': todayCompleted};
    }

    final streakData = _hobbies.isEmpty
        ? {'streak': 0, 'todayCompleted': false}
        : calculateGlobalStreak();
    final globalStreak = streakData['streak'] as int;
    final todayCompleted = streakData['todayCompleted'] as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String?>(
                      future: _service.getSetting('userName'),
                      builder: (context, snapshot) {
                        final userName = snapshot.data ?? 'Tham';
                        return Text(
                          'Hello, $userName!',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 1),
                    Text(
                      DateFormat('EEEE, MMM dd').format(_selectedDate),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Show streak when there are hobbies (even if 0)
              if (_hobbies.isNotEmpty)
                GestureDetector(
                  key: const Key(TestKeys.streakBadge),
                  onTap: () {
                    setState(() => _selectedIndex = 2); // Navigate to analytics
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2238),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: todayCompleted
                              ? const Color(0xFFFF6B35)
                              : Colors.grey.withValues(alpha: 0.5),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$globalStreak',
                          style: TextStyle(
                            color: todayCompleted
                                ? Colors.white
                                : Colors.grey.withValues(alpha: 0.5),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Progress text below header
          if (_hobbies.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedToday of $totalTasksForSelectedDate tasks',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${progressPercentage.toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF6C3FFF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: _dayScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7, // Current week (7 days)
        physics: const BouncingScrollPhysics(),
        cacheExtent: 500, // Cache items for smooth scrolling
        itemBuilder: (context, index) {
          // Calculate date: index 0 = Monday, ..., index 6 = Sunday
          final startOfWeek = _getStartOfWeek();
          final date = startOfWeek.add(Duration(days: index));
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          final selectedStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

          final isSelected = dateStr == selectedStr;
          final isToday = dateStr == todayStr;

          return GestureDetector(
            key: Key(TestKeys.dayPill(dateStr)),
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              // Scroll to selected date after a brief delay
              Future.delayed(const Duration(milliseconds: 100), () {
                _animateToSelectedDate();
              });
            },
            child: Container(
              width: 48,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C3FFF)
                    : const Color(0xFF2A2238),
                borderRadius: BorderRadius.circular(24),
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFF6C3FFF), width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white54,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress() {
    // Hide progress section if there are no hobbies (first-time user)
    if (_hobbies.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine the title based on selected date
    final isToday = _isToday();
    final progressTitle = isToday
        ? 'Today\'s Progress'
        : DateFormat('EEEE, MMM dd').format(_selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progressPercentage.toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF6C3FFF),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFF2A2738),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6C3FFF),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completedToday of $totalTasksForSelectedDate tasks completed ${isToday ? "today" : "on this day"}',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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

  Widget _buildTaskCard(Hobby hobby, bool isCompleted) {
    // Check if selected date is in the future
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final isFutureDate = selectedDateOnly.isAfter(todayDate);

    return AnimatedContainer(
      key: Key(TestKeys.taskCard(hobby.id)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Opacity(
        opacity: isFutureDate ? 0.4 : 1.0, // Dim future tasks
        child: Row(
          children: [
            // Checkbox with hobby color
            Semantics(
              identifier: TestKeys.taskCheckbox(hobby.id),
              child: Builder(
                builder: (context) => AnimatedCheckbox(
                  key: Key(TestKeys.taskCheckbox(hobby.id)),
                  isChecked: isCompleted,
                  onTap: isFutureDate
                      ? null
                      : () =>
                            _toggleToday(hobby), // Disable tap for future dates
                  size: 24,
                  color: Color(hobby.color),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Name and notes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                      // Streak badges after subtitle
                      if (hobby.currentStreak > 0 || hobby.bestStreak > 0) ...[
                        const SizedBox(width: 8),
                        // Current streak
                        if (hobby.currentStreak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF6B35,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${hobby.currentStreak}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Color(0xFFFF6B35),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        // Best streak
                        if (hobby.bestStreak > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFD700,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${hobby.bestStreak}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.emoji_events,
                                  color: Color(0xFFFFD700),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            PopupMenuButton(
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
                      Icon(
                        Icons.edit_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
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
                  // Reload hobbies and wait for widget rebuild
                  await _loadHobbies();
                  // Wait for build to complete
                  await Future.delayed(const Duration(milliseconds: 100));
                  // Now scroll to the selected date
                  _animateToSelectedDate();
                } else if (value == 'delete') {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
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
                          'Are you sure you want to delete "${hobby.name}"? This action cannot be undone and will remove all completion history.',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
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
                      );
                    },
                  );

                  // Only delete if confirmed
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

                      // Reload hobbies and wait for widget rebuild
                      await _loadHobbies();
                      // Wait for build to complete
                      await Future.delayed(const Duration(milliseconds: 100));
                      // Now scroll to the selected date
                      _animateToSelectedDate();
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
          // Reload hobbies and wait for widget rebuild
          await _loadHobbies();
          // Wait for build to complete
          await Future.delayed(const Duration(milliseconds: 100));
          // Now scroll to the selected date
          _animateToSelectedDate();
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
            onTap: () {
              setState(() => _selectedIndex = index);
              // When returning to home screen (index 0), scroll to selected date
              if (index == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _dayScrollController.hasClients) {
                    _animateToSelectedDate();
                  }
                });
              }
            },
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

  IconData _getIconForHobby(Hobby hobby) {
    final name = hobby.name.toLowerCase();
    if (name.contains('paint') ||
        name.contains('draw') ||
        name.contains('art')) {
      return Icons.palette;
    } else if (name.contains('piano') ||
        name.contains('music') ||
        name.contains('guitar')) {
      return Icons.piano;
    } else if (name.contains('read') || name.contains('book')) {
      return Icons.menu_book;
    } else if (name.contains('exercise') ||
        name.contains('workout') ||
        name.contains('yoga')) {
      return Icons.fitness_center;
    } else if (name.contains('code') || name.contains('program')) {
      return Icons.code;
    } else if (name.contains('write') || name.contains('journal')) {
      return Icons.edit;
    }
    return Icons.check_circle;
  }

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

  bool _isToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final selected = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return today == selected;
  }

  bool _isFutureDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected.isAfter(today);
  }
}

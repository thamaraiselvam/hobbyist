import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hobby.dart';
import '../services/hobby_service.dart';
import '../services/sound_service.dart';
import '../services/quote_service.dart';
import '../widgets/animated_checkbox.dart';
import '../widgets/tada_animation.dart';
import '../utils/page_transitions.dart';
import 'add_hobby_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({Key? key}) : super(key: key);

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  final HobbyService _service = HobbyService();
  final SoundService _soundService = SoundService();
  final QuoteService _quoteService = QuoteService();
  List<Hobby> _hobbies = [];
  bool _loading = true;
  int _selectedIndex = 0;
  final Map<String, bool> _celebratingTasks = {};
  String _currentQuote = '';

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _loadHobbies();
  }

  Future<void> _loadQuote() async {
    setState(() {
      _currentQuote = _quoteService.getRandomQuote();
    });
  }

  Future<void> _loadHobbies() async {
    setState(() => _loading = true);
    final hobbies = await _service.loadHobbies();
    setState(() {
      _hobbies = hobbies;
      _loading = false;
    });
  }

  Future<void> _toggleToday(Hobby hobby) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isCompleted = hobby.completions[today]?.completed ?? false;
    
    // Update UI immediately
    final updatedCompletions = Map<String, HobbyCompletion>.from(hobby.completions);
    updatedCompletions[today] = HobbyCompletion(
      completed: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
    
    final updatedHobby = hobby.copyWith(completions: updatedCompletions);
    
    // Update UI first
    setState(() {
      final index = _hobbies.indexWhere((h) => h.id == hobby.id);
      if (index != -1) {
        _hobbies[index] = updatedHobby;
      }
      
      // Celebrate when marking as complete - always reset to trigger animation
      if (!isCompleted) {
        _celebratingTasks[hobby.id] = false; // Reset first
      }
    });
    
    // Trigger animation after a frame
    if (!isCompleted) {
      // Play completion sound
      _soundService.playCompletionSound();
      
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _celebratingTasks[hobby.id] = true;
          });
          
          // Remove celebration flag after animation
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _celebratingTasks.remove(hobby.id);
              });
            }
          });
        }
      });
    }
    
    // Sync to backend asynchronously
    _service.updateHobby(updatedHobby);
  }

  int get completedToday {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _hobbies.where((h) => h.completions[today]?.completed == true).length;
  }

  double get progressPercentage {
    if (_hobbies.isEmpty) return 0;
    return (completedToday / _hobbies.length * 100);
  }

  List<Hobby> get inProgressTasks {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _hobbies.where((h) => h.completions[today]?.completed != true).toList();
  }

  List<Hobby> get completedTasks {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _hobbies.where((h) => h.completions[today]?.completed == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _selectedIndex == 1
        ? AnalyticsScreen(
            hobbies: _hobbies,
            onBack: () => setState(() => _selectedIndex = 0),
            onNavigate: (index) => setState(() => _selectedIndex = index),
            onRefresh: _loadHobbies,
          )
        : _selectedIndex == 2
            ? SettingsScreen(
                onBack: () => setState(() => _selectedIndex = 0),
                onNavigate: (index) => setState(() => _selectedIndex = index),
              )
            : _buildTasksScreen();
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
                  const SizedBox(height: 8),
                  _buildOverallProgress(),
                  _buildQuoteSection(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadHobbies,
                      color: const Color(0xFF6C3FFF),
                      backgroundColor: const Color(0xFF2A2139),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (inProgressTasks.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'In Progress',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${inProgressTasks.length} Pending',
                                  style: const TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...inProgressTasks.map((hobby) => _buildTaskCard(hobby, false)),
                            const SizedBox(height: 32),
                          ],
                          if (completedTasks.isNotEmpty) ...[
                            const Text(
                              'Completed Today',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...completedTasks.map((hobby) => _buildTaskCard(hobby, true)),
                          ],
                          if (_hobbies.isEmpty) ...[
                            const SizedBox(height: 100),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.task_alt, size: 80, color: Colors.white24),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No hobbies yet',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap the + button to add your first hobby',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            SlidePageRoute(
              page: const AddHobbyScreen(),
              direction: AxisDirection.up,
            ),
          );
          _loadHobbies();
        },
        backgroundColor: const Color(0xFF6C3FFF),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
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
        } else if (i > 0) { // Don't break on today if it's not completed yet
          break;
        }
      }
      
      return {'streak': streak, 'todayCompleted': todayCompleted};
    }
    
    final streakData = _hobbies.isEmpty ? {'streak': 0, 'todayCompleted': false} : calculateGlobalStreak();
    final globalStreak = streakData['streak'] as int;
    final todayCompleted = streakData['todayCompleted'] as bool;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
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
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMM dd').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (globalStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2238),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: todayCompleted ? const Color(0xFFFF6B35) : Colors.grey.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$globalStreak',
                    style: TextStyle(
                      color: todayCompleted ? Colors.white : Colors.grey.withOpacity(0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C3FFF)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completedToday of ${_hobbies.length} tasks completed today',
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
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      width: double.infinity,
      padding: const EdgeInsets.only(left: 0, top: 14, bottom: 14, right: 16),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0xFF6C3FFF), width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(
          _currentQuote,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontStyle: FontStyle.italic,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.left,
          maxLines: null,
          softWrap: true,
        ),
      ),
    );
  }


  Widget _buildTaskCard(Hobby hobby, bool isCompleted) {
    final isCelebrating = _celebratingTasks[hobby.id] ?? false;
    
    return TadaAnimation(
      animate: isCelebrating,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hobby.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white38,
                      decorationThickness: 1.5,
                    ),
                  ),
                  if (hobby.currentStreak > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Color(0xFFFF6B35), size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '${hobby.currentStreak} day streak',
                          style: const TextStyle(
                            color: Color(0xFFFF6B35),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Builder(
              builder: (context) => AnimatedCheckbox(
                isChecked: isCompleted,
                onTap: () => _toggleToday(hobby),
                size: 32,
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 22),
            color: const Color(0xFF2A2738),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                await Navigator.push(
                  context,
                  SlidePageRoute(
                    page: AddHobbyScreen(hobby: hobby),
                    direction: AxisDirection.left,
                  ),
                );
                _loadHobbies();
              } else if (value == 'delete') {
                await _service.deleteHobby(hobby.id);
                _loadHobbies();
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
      decoration: const BoxDecoration(
        color: Color(0xFF2A2238),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: 12 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
        ),
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
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
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
}

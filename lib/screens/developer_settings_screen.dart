// ignore_for_file: avoid_print, unused_field, unused_local_variable
import 'package:flutter/material.dart';
import 'dart:math';
import '../services/hobby_service.dart';
import '../services/notification_service.dart';
import '../models/hobby.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  State<DeveloperSettingsScreen> createState() =>
      _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends State<DeveloperSettingsScreen> {
  final HobbyService _service = HobbyService();
  final NotificationService _notificationService = NotificationService();
  bool _isGenerating = false;
  bool _pullToRefreshEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pullToRefreshEnabled = prefs.getBool('pull_to_refresh_enabled') ?? false;
    });
  }

  Future<void> _togglePullToRefresh(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pull_to_refresh_enabled', value);
    setState(() {
      _pullToRefreshEnabled = value;
    });
  }

  final List<String> _hobbyNames = [
    'Morning Yoga',
    'Reading Books',
    'Guitar Practice',
    'Digital Painting',
    'Learning Spanish',
    'Photography',
    'Meditation',
    'Writing Journal',
    'Cooking New Recipes',
    'Running',
    'Swimming',
    'Drawing Sketches',
    'Playing Piano',
    'Learning Code',
    'Gardening',
    'Cycling',
    'Chess Practice',
    'Language Drill',
    'Calligraphy',
    'Origami',
    'Podcasting',
    'Video Editing',
    'Singing Practice',
    'Dance Classes',
    'Hiking',
    'Rock Climbing',
    'Surfing',
    'Skateboarding',
    'Boxing Training',
    'Martial Arts',
  ];

  final List<int> _colors = [
    0xFFFF6B6B,
    0xFF4ECDC4,
    0xFF45B7D1,
    0xFFFFA07A,
    0xFF98D8C8,
    0xFFF7DC6F,
    0xFFBB8FCE,
    0xFF85C1E2,
    0xFFF8B500,
    0xFFFF6B9D,
  ];

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2238),
        title: const Text(
          'Reset All Data?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will delete all hobbies, completions, and settings. The app will restart and you\'ll go through the onboarding again. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset Everything',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear SQLite database
      await _service.resetDatabase();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        // Navigate to splash screen to restart journey
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    }
  }

  Future<void> _generateRandomHobbies() async {
    if (!mounted) return;

    // Check if predefined hobbies already exist
    final existingHobbies = await _service.loadHobbies();
    final hasPredefinedHobbies =
        existingHobbies.any((h) => h.id.startsWith('predefined_'));

    setState(() {
      _isGenerating = true;
    });

    try {
      final random = Random();
      final now = DateTime.now();
      final last365Days = now.subtract(const Duration(days: 365));

      if (!hasPredefinedHobbies) {
        // First time: Create 5 daily, 5 weekly, 5 monthly tasks
        final dailyTasks = [
          'Morning Meditation',
          'Read 30 Minutes',
          'Exercise',
          'Practice Guitar',
          'Write Journal'
        ];
        final weeklyTasks = [
          'Deep Clean House',
          'Meal Prep Sunday',
          'Review Weekly Goals',
          'Family Video Call',
          'Update Budget'
        ];
        final monthlyTasks = [
          'Pay Bills',
          'Car Maintenance',
          'Review Investments',
          'Haircut Appointment',
          'Organize Closet'
        ];

        int taskIndex = 0;

        // Add daily tasks
        for (var taskName in dailyTasks) {
          final hobbyId = 'predefined_daily_$taskIndex';
          final hobby = Hobby(
            id: hobbyId,
            name: taskName,
            notes: 'Daily habit',
            repeatMode: 'daily',
            color: _colors[taskIndex % _colors.length],
            completions: {},
          );
          await _service.addHobby(hobby);
          taskIndex++;
        }

        // Add weekly tasks
        for (var taskName in weeklyTasks) {
          final hobbyId = 'predefined_weekly_$taskIndex';
          final hobby = Hobby(
            id: hobbyId,
            name: taskName,
            notes: 'Weekly routine',
            repeatMode: 'weekly',
            color: _colors[taskIndex % _colors.length],
            completions: {},
          );
          await _service.addHobby(hobby);
          taskIndex++;
        }

        // Add monthly tasks
        for (var taskName in monthlyTasks) {
          final hobbyId = 'predefined_monthly_$taskIndex';
          final hobby = Hobby(
            id: hobbyId,
            name: taskName,
            notes: 'Monthly task',
            repeatMode: 'monthly',
            color: _colors[taskIndex % _colors.length],
            completions: {},
          );
          await _service.addHobby(hobby);
          taskIndex++;
        }

        if (mounted) {
          setState(() {
            _isGenerating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Created 15 predefined tasks!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Subsequent times: Add random completions to existing predefined tasks
        final predefinedHobbies = existingHobbies
            .where((h) => h.id.startsWith('predefined_'))
            .toList();

        for (var hobby in predefinedHobbies) {
          // Generate random completions in last 365 days
          final numCompletions = random.nextInt(50) + 30; // 30-80 completions

          for (int i = 0; i < numCompletions; i++) {
            final randomDaysAgo = random.nextInt(365);
            final date = now.subtract(Duration(days: randomDaysAgo));
            final dateKey =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

            hobby.completions[dateKey] = HobbyCompletion(
              completed: true,
              completedAt: DateTime(
                date.year,
                date.month,
                date.day,
                random.nextInt(24),
                random.nextInt(60),
              ),
            );
          }

          await _service.updateHobby(hobby);
        }

        if (mounted) {
          setState(() {
            _isGenerating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Added random completions to existing tasks!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error generating hobbies: $e');
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _create100DayTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2238),
        title: const Text(
          'Create 100-Day Test Task?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will create a Daily task called "create app" with 100 consecutive days of completions (from 100 days ago to today).\n\nCurrent streak: 100 days\nBest streak: 100 days',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final now = DateTime.now();
      final createdAt = now.subtract(const Duration(days: 100));

      // Create the hobby
      final hobby = Hobby(
        id: 'test_100day_${DateTime.now().millisecondsSinceEpoch}',
        name: 'create app',
        repeatMode: 'Daily',
        color: 0xFFFF6B6B, // Red color
        bestStreak: 100,
        createdAt: createdAt,
        completions: {},
      );

      // Add 100 consecutive days of completions
      for (int i = 99; i >= 0; i--) {
        final date =
            DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        hobby.completions[dateKey] = HobbyCompletion(
          completed: true,
          completedAt: date.add(const Duration(hours: 10)),
        );
      }

      // Save to Firestore
      await _service.addHobby(hobby);

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Created "create app" with 100 days streak!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error creating 100-day task: $e');
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    // Check if push notifications are enabled in settings
    final pushEnabled = await _service.getSetting('push_notifications');
    if (pushEnabled == 'false') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Push notifications are disabled in Settings'),
            backgroundColor: Color(0xFFE88D39), // Readable orange
          ),
        );
      }
      return;
    }

    try {
      // Check if notifications are enabled at system level
      final enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable notifications in System Settings'),
              backgroundColor: Color(0xFFE88D39), // Readable orange
            ),
          );
        }
        // Request permissions
        await _notificationService.requestPermissions();
        return;
      }

      // Check exact alarm permission
      final canSchedule = await _notificationService.canScheduleExactAlarms();
      if (!canSchedule) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable exact alarms in System Settings'),
              backgroundColor: Color(0xFFE88D39), // Readable orange
            ),
          );
        }
        return;
      }

      // Show test notification
      await _notificationService.showTestNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test notification sent!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Developer Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FEATURE FLAGS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2238),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Color(0xFF4ECDC4),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Pull to Refresh',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Enable pull-to-refresh to jump to today',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                value: _pullToRefreshEnabled,
                thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF6C3FFF);
                  }
                  return null;
                }),
                onChanged: _togglePullToRefresh,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'TESTING TOOLS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2238),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notification_add,
                        color: Color(0xFFFFB800),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Test Notification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Send a test notification immediately',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                    ),
                    onTap: _testNotification,
                  ),
                  const Divider(color: Color(0xFF3D3449), height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C3FFF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF6C3FFF),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Generate Random Hobbies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Adds 10 hobbies with random completions',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    trailing: _isGenerating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6C3FFF),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                    onTap: _isGenerating ? null : _generateRandomHobbies,
                  ),
                  const Divider(color: Color(0xFF3D3449), height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Create 100-Day Streak Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Creates "create app" with 100 days completion',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    trailing: _isGenerating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6B35),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                    onTap: _isGenerating ? null : _create100DayTask,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'DANGER ZONE',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2238),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Reset All Data',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Delete everything and start fresh',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.red,
                ),
                onTap: _resetAllData,
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '⚠️ These tools are for development and testing purposes only. Use with caution.',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

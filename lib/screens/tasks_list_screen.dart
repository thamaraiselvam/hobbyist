import 'package:flutter/material.dart';
import '../constants/test_keys.dart';
import '../models/hobby.dart';
import '../services/hobby_service.dart';
import '../utils/page_transitions.dart';
import 'add_hobby_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksListScreen extends StatefulWidget {
  final List<Hobby> hobbies;
  final VoidCallback onBack;
  final Function(int) onNavigate;
  final Future<void> Function() onRefresh;

  const TasksListScreen({
    super.key,
    required this.hobbies,
    required this.onBack,
    required this.onNavigate,
    required this.onRefresh,
  });

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen>
    with SingleTickerProviderStateMixin {
  final HobbyService _service = HobbyService();
  List<Hobby> _hobbies = [];
  late TabController _tabController;
  int _selectedTab = 0;
  bool _pullToRefreshEnabled = false;

  @override
  void initState() {
    super.initState();
    _hobbies = widget.hobbies;
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
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
  void didUpdateWidget(TasksListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update when parent hobbies change
    if (widget.hobbies != oldWidget.hobbies) {
      setState(() {
        _hobbies = widget.hobbies;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHobbies() async {
    await widget.onRefresh();
  }

  List<Hobby> _getFilteredHobbies() {
    switch (_selectedTab) {
      case 0: // All (recurring only - one-time has its own tab)
        return _hobbies.where((h) => !h.isOneTime).toList();
      case 1: // Daily
        return _hobbies.where((h) => h.repeatMode == 'daily').toList();
      case 2: // Weekly
        return _hobbies.where((h) => h.repeatMode == 'weekly').toList();
      case 3: // Monthly
        return _hobbies.where((h) => h.repeatMode == 'monthly').toList();
      case 4: // One-time
        return _hobbies.where((h) => h.isOneTime).toList();
      default:
        return _hobbies.where((h) => !h.isOneTime).toList();
    }
  }

  String _getFrequencyText(String repeatMode) {
    switch (repeatMode) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'one_time':
        return 'One-time';
      default:
        return 'Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHobbies = _getFilteredHobbies();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: filteredHobbies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.list_alt,
                            size: 80,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_getTabName()} tasks yet',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first task',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _pullToRefreshEnabled
                  ? RefreshIndicator(
                      onRefresh: _loadHobbies,
                      color: const Color(0xFF6C3FFF),
                      backgroundColor: const Color(0xFF2A2139),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredHobbies.length,
                        itemBuilder: (context, index) {
                          final hobby = filteredHobbies[index];
                          return _buildTaskCard(hobby);
                        },
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredHobbies.length,
                      itemBuilder: (context, index) {
                        final hobby = filteredHobbies[index];
                        return _buildTaskCard(hobby);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  String _getTabName() {
    switch (_selectedTab) {
      case 0:
        return 'all';
      case 1:
        return 'daily';
      case 2:
        return 'weekly';
      case 3:
        return 'monthly';
      case 4:
        return 'one-time';
      default:
        return '';
    }
  }

  Widget _buildHeader() {
    final filteredHobbies = _getFilteredHobbies();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Text(
        'All Tasks (${filteredHobbies.length})',
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2139),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF382a54)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _getTabColor(_selectedTab),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(3),
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Daily'),
          Tab(text: 'Weekly'),
          Tab(text: 'Monthly'),
          Tab(text: 'One-time'),
        ],
      ),
    );
  }

  Color _getTabColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF6C3FFF); // All - Purple
      case 1:
        return const Color(0xFF6C3FFF); // Daily - Purple
      case 2:
        return const Color(0xFF10B981); // Weekly - Green
      case 3:
        return const Color(0xFFF59E0B); // Monthly - Amber
      case 4:
        return const Color(0xFFFF8056);
      default:
        return const Color(0xFF6C3FFF);
    }
  }

  Widget _buildTaskCard(Hobby hobby) {
    final totalCompletions = hobby.completions.values
        .where((c) => c.completed)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Color indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(hobby.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Task name and frequency
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hobby.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getFrequencyText(hobby.repeatMode),
                            style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // Current streak
                        if (!hobby.isOneTime && hobby.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Color(0xFFFF6B35),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Best streak
                        if (!hobby.isOneTime && hobby.bestStreak > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.emoji_events,
                                  color: Color(0xFFFFD700),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (hobby.isOneTime) ...[
                          const SizedBox(width: 8),
                          Builder(builder: (context) {
                            final isDone = hobby.completions.values.any((c) => c.completed);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                    : const Color(0xFFFF8056).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isDone ? const Color(0xFF10B981) : const Color(0xFFFF8056),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isDone ? 'Done' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDone
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFFF8056),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Edit and delete buttons
              PopupMenuButton(
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
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
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
                    _loadHobbies();
                  } else if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF2A2738),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Delete Task?',
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

                        _loadHobbies();
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
          // Stats row
          if (totalCompletions > 0 && !hobby.isOneTime) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C3FFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$totalCompletions',
                        style: const TextStyle(
                          color: Color(0xFF6C3FFF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Completed',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.white12),
                  Column(
                    children: [
                      Text(
                        '${hobby.currentStreak}',
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Current',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.white12),
                  Column(
                    children: [
                      Text(
                        '${hobby.bestStreak}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Best',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.push(
          context,
          SlidePageRoute(
            page: const AddHobbyScreen(),
            direction: AxisDirection.up,
          ),
        );
        _loadHobbies();
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
    final isSelected = index == 1; // Tasks List is index 1
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

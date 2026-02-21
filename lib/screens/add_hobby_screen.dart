// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../models/hobby.dart';
import '../services/hobby_service.dart';
import '../services/notification_service.dart';
import '../utils/default_hobbies.dart';
import '../constants/test_keys.dart';

class AddHobbyScreen extends StatefulWidget {
  final Hobby? hobby;

  const AddHobbyScreen({super.key, this.hobby});

  @override
  State<AddHobbyScreen> createState() => _AddHobbyScreenState();
}

class _AddHobbyScreenState extends State<AddHobbyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final HobbyService _service = HobbyService();
  final NotificationService _notificationService = NotificationService();

  String _repeatMode = 'daily';
  int _selectedColor = 0xFF590df2; // Default to first color
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  bool _notifyEnabled = false; // Default OFF
  bool _isOneTime = false; // If true, task disappears after first completion

  // Color palette - 10 bright colors matching theme
  final List<int> _colorPalette = const [
    0xFF590df2, // Purple (theme primary)
    0xFFF700C5, // Bright magenta
    0xFFFF8056, // Coral
    0xFFFFC347, // Orange/gold
    0xFF00C2A7, // Teal/cyan
    0xFF00D9FF, // Bright cyan
    0xFF6B5AED, // Light purple
    0xFFFF6B9D, // Pink
    0xFF00E676, // Bright green
    0xFFFFAB40, // Amber
  ];

  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  int _selectedWeekDay = 0; // Single day for weekly (0=Monday)
  int _selectedMonthDay = 1; // Day of month for monthly (1-31)

  List<HobbyData> _filteredHobbies = DefaultHobbies.hobbies;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.hobby != null) {
      _nameController.text = widget.hobby!.name;
      _notesController.text = widget.hobby!.notes;
      _repeatMode = widget.hobby!.repeatMode;
      _selectedColor = widget.hobby!.color;

      // Load custom day if exists
      if (widget.hobby!.customDay != null) {
        if (widget.hobby!.repeatMode == 'weekly') {
          _selectedWeekDay = widget.hobby!.customDay!;
        } else if (widget.hobby!.repeatMode == 'monthly') {
          _selectedMonthDay = widget.hobby!.customDay!;
        }
      }

      // Load notification time if exists
      if (widget.hobby!.reminderTime != null &&
          widget.hobby!.reminderTime!.isNotEmpty) {
        final timeParts = widget.hobby!.reminderTime!.split(':');
        if (timeParts.length == 2) {
          _notificationTime = TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 8,
            minute: int.tryParse(timeParts[1]) ?? 0,
          );
          _notifyEnabled = true;
        }
      }

      // Load one-time flag if exists
      _isOneTime = widget.hobby!.isOneTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveHobby() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Format notification time as HH:mm
        final notificationTimeString = _notifyEnabled
            ? '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}'
            : '';

        // Get custom day based on repeat mode
        int? customDay;
        if (_repeatMode == 'weekly') {
          customDay = _selectedWeekDay;
        } else if (_repeatMode == 'monthly') {
          customDay = _selectedMonthDay;
        }

        if (widget.hobby != null) {
          // Update existing hobby
          final updatedHobby = widget.hobby!.copyWith(
            name: _nameController.text,
            notes: _notesController.text,
            repeatMode: _repeatMode,
            color: _selectedColor,
            reminderTime: notificationTimeString,
            customDay: customDay,
          );
          await _service.updateHobby(updatedHobby);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '✅ Hobby "${_nameController.text}" updated successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Create new hobby
          final hobby = Hobby(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            notes: _notesController.text,
            repeatMode: _repeatMode,
            color: _selectedColor,
            reminderTime: notificationTimeString,
            customDay: customDay,
            isOneTime: _isOneTime,
          );
          await _service.addHobby(hobby);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '✅ Hobby "${_nameController.text}" created successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error saving hobby: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF590df2),
              onPrimary: Colors.white,
              surface: Color(0xFF221834),
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF221834),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredHobbies = DefaultHobbies.search(query);
      _showSuggestions = query.isNotEmpty && _filteredHobbies.isNotEmpty;
    });
  }

  void _selectHobby(HobbyData hobby) {
    setState(() {
      _nameController.text = hobby.name;
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161022),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Blurred background
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black26,
                ),
              ),
              // Bottom sheet
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF161022),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Handle bar
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                width: 48,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF433168),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Title
                            const Text(
                              'ADD NEW HOBBY TASK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFa490cb),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Search input with suggestions
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  identifier: TestKeys.addHobbyNameInput,
                                  child: TextFormField(
                                    key: const Key(TestKeys.addHobbyNameInput),
                                    controller: _nameController,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    onChanged: _onSearchChanged,
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Read book - 30 mins',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFa490cb),
                                        fontSize: 16,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF221834),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 20),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a hobby name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                // Suggestions list
                                if (_showSuggestions) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 200),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF221834),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFF382a54)),
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      itemCount:
                                          _filteredHobbies.take(6).length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                        color: Color(0xFF382a54),
                                        height: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        final hobby = _filteredHobbies[index];
                                        return InkWell(
                                          onTap: () => _selectHobby(hobby),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  hobby.emoji,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  hobby.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Frequency section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF221834),
                                borderRadius: BorderRadius.circular(24),
                                border:
                                    Border.all(color: const Color(0xFF382a54)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.repeat,
                                          color: Color(0xFFa490cb), size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'FREQUENCY',
                                        style: TextStyle(
                                          color: Color(0xFFa490cb),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Frequency buttons
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161022)
                                          .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildFrequencyButton('daily', 'Daily'),
                                        _buildFrequencyButton(
                                            'weekly', 'Weekly'),
                                        _buildFrequencyButton(
                                            'monthly', 'Monthly'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Conditional frequency selector based on mode
                                  if (_repeatMode == 'weekly') ...[
                                    // Week days selector (single selection)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(7, (index) {
                                        final isSelected =
                                            _selectedWeekDay == index;
                                        return GestureDetector(
                                          key: Key(
                                              TestKeys.addHobbyWeekdayButton(
                                                  index)),
                                          onTap: () {
                                            setState(() {
                                              _selectedWeekDay = index;
                                            });
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF590df2)
                                                  : Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF590df2)
                                                    : Colors.white.withValues(
                                                        alpha: 0.05),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _weekDays[index],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ] else if (_repeatMode == 'daily') ...[
                                    // Daily - just show info text
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161022)
                                            .withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.today,
                                              color: Color(0xFFa490cb),
                                              size: 20),
                                          SizedBox(width: 12),
                                          Text(
                                            'Repeats every day',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (_repeatMode == 'monthly') ...[
                                    // Monthly - show day picker slider
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_month,
                                                color: Color(0xFFa490cb),
                                                size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Day of month: $_selectedMonthDay${_getDaySuffix(_selectedMonthDay)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SliderTheme(
                                          data: SliderThemeData(
                                            activeTrackColor:
                                                const Color(0xFF590df2),
                                            inactiveTrackColor:
                                                const Color(0xFF590df2)
                                                    .withValues(alpha: 0.2),
                                            thumbColor: const Color(0xFF590df2),
                                            overlayColor:
                                                const Color(0xFF590df2)
                                                    .withValues(alpha: 0.2),
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                    enabledThumbRadius: 10),
                                            trackHeight: 4,
                                          ),
                                          child: Slider(
                                            value: _selectedMonthDay.toDouble(),
                                            min: 1,
                                            max: 31,
                                            divisions: 30,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedMonthDay =
                                                    value.toInt();
                                              });
                                            },
                                          ),
                                        ),
                                        // Show day markers
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('1',
                                                  style: TextStyle(
                                                      color: Color(0xFFa490cb),
                                                      fontSize: 10)),
                                              Text('15',
                                                  style: TextStyle(
                                                      color: Color(0xFFa490cb),
                                                      fontSize: 10)),
                                              Text('31',
                                                  style: TextStyle(
                                                      color: Color(0xFFa490cb),
                                                      fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  const Divider(
                                      color: Color(0xFF382a54), height: 1),
                                  const SizedBox(height: 20),
                                  // Notify Me toggle
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF590df2)
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.notifications,
                                              color: Color(0xFF590df2),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Notify Me',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Semantics(
                                        identifier:
                                            TestKeys.addHobbyNotifyToggle,
                                        child: Switch(
                                          key: const Key(
                                              TestKeys.addHobbyNotifyToggle),
                                          value: _notifyEnabled,
                                          onChanged: (value) async {
                                            if (value) {
                                              // Request permission when turning on for the first time
                                              // Check if already granted
                                              final alreadyEnabled =
                                                  await _notificationService
                                                      .areNotificationsEnabled();

                                              if (!alreadyEnabled) {
                                                // Request permissions
                                                final granted =
                                                    await _notificationService
                                                        .requestPermissions();

                                                if (!granted) {
                                                  // Permission denied, show message
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Notification permission denied. Please enable it in settings.',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        backgroundColor: Color(
                                                            0xFFE88D39), // Readable orange
                                                      ),
                                                    );
                                                  }
                                                  return; // Don't enable toggle
                                                }
                                              }
                                            }

                                            setState(() {
                                              _notifyEnabled = value;
                                            });
                                          },
                                          thumbColor: WidgetStateProperty
                                              .resolveWith<Color?>((states) {
                                            if (states.contains(
                                                WidgetState.selected)) {
                                              return const Color(0xFF590df2);
                                            }
                                            return null;
                                          }),
                                          trackColor: WidgetStateProperty
                                              .resolveWith<Color?>((states) {
                                            if (states.contains(
                                                WidgetState.selected)) {
                                              return const Color(0xFF590df2)
                                                  .withValues(alpha: 0.5);
                                            }
                                            return null;
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_notifyEnabled) ...[
                                    const SizedBox(height: 16),
                                    // Notification time
                                    Semantics(
                                      identifier:
                                          TestKeys.addHobbyReminderPicker,
                                      child: InkWell(
                                        key: const Key(
                                            TestKeys.addHobbyReminderPicker),
                                        onTap: _selectTime,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF161022)
                                                .withValues(alpha: 0.4),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.05)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.alarm,
                                                color: Color(0xFFa490cb),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'REMINDER TIME',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFFa490cb),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _formatTime(
                                                          _notificationTime),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.expand_more,
                                                color: Color(0xFF6B6B6B),
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(
                                color: Color(0xFF382a54), height: 1),
                            const SizedBox(height: 20),
                            // One-time task toggle
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF8056)
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.looks_one_outlined,
                                        color: Color(0xFFFF8056),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'One-time Task',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Disappears after completion',
                                          style: TextStyle(
                                            color: Color(0xFF8A7BA8),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isOneTime,
                                  onChanged: (value) {
                                    setState(() {
                                      _isOneTime = value;
                                    });
                                  },
                                  thumbColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                          (states) {
                                    if (states
                                        .contains(WidgetState.selected)) {
                                      return const Color(0xFFFF8056);
                                    }
                                    return null;
                                  }),
                                  trackColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                          (states) {
                                    if (states
                                        .contains(WidgetState.selected)) {
                                      return const Color(0xFFFF8056)
                                          .withValues(alpha: 0.5);
                                    }
                                    return null;
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Color Palette section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Text(
                                    'COLOR PALETTE',
                                    style: TextStyle(
                                      color: Color(0xFFa490cb),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: List.generate(_colorPalette.length,
                                      (index) {
                                    return _buildColorButton(
                                        _colorPalette[index], index);
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Create button
                            Semantics(
                              identifier: TestKeys.addHobbySubmitButton,
                              child: ElevatedButton(
                                key: const Key(TestKeys.addHobbySubmitButton),
                                onPressed: _saveHobby,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF590df2),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: const Color(0xFF590df2)
                                      .withValues(alpha: 0.3),
                                ),
                                child: Text(
                                  widget.hobby != null
                                      ? 'Update Activity'
                                      : 'Create Activity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Cancel button
                            TextButton(
                              key: const Key('cancelHobbyButton'),
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFa490cb),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyButton(String value, String label) {
    final isSelected = _repeatMode == value;
    return Expanded(
      child: Semantics(
        identifier: TestKeys.addHobbyFrequencyButton(value),
        child: GestureDetector(
          key: Key(TestKeys.addHobbyFrequencyButton(value)),
          onTap: () {
            setState(() {
              _repeatMode = value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF590df2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(int colorValue, int index) {
    final isSelected = _selectedColor == colorValue;
    return Semantics(
      identifier: TestKeys.addHobbyColorButton(index),
      // label is required so Flutter keeps this semantics node in the
      // accessibility tree. Without semantic content (no Text child),
      // Flutter may prune the node and the resource-id is never surfaced
      // to the Android accessibility service (and therefore Maestro).
      label: TestKeys.addHobbyColorButton(index),
      button: true,
      child: GestureDetector(
        key: Key(TestKeys.addHobbyColorButton(index)),
        onTap: () {
          setState(() {
            _selectedColor = colorValue;
          });
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(colorValue),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(colorValue).withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}

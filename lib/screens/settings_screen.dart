import 'package:flutter/material.dart';
import '../services/hobby_service.dart';
import 'developer_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(int) onNavigate;

  const SettingsScreen({
    Key? key, 
    required this.onBack,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _completionSoundEnabled = true;
  final HobbyService _service = HobbyService();
  String _userName = 'Tham';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadSettings();
  }

  Future<void> _loadUserName() async {
    final name = await _service.getSetting('userName');
    if (mounted && name != null) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadSettings() async {
    final completionSound = await _service.getSetting('completionSound');
    final pushNotifications = await _service.getSetting('pushNotifications');
    
    if (mounted) {
      setState(() {
        _completionSoundEnabled = completionSound != 'false';
        _pushNotificationsEnabled = pushNotifications != 'false';
      });
    }
  }

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _userName);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2238),
        title: const Text(
          'Edit Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6C3FFF)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6C3FFF), width: 2),
            ),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await _service.setSetting('userName', newName);
                setState(() {
                  _userName = newName;
                });
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF6C3FFF)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACCOUNT',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildAccountCard(),
            const SizedBox(height: 32),
            const Text(
              'PREFERENCES',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildPreferencesCard(),
            const SizedBox(height: 32),
            _buildDeveloperSettingsCard(),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Hobbyist v1.0.0 — Made for consistency',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ),
          ],
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
    final isSelected = index == 2; // Settings is index 2
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

  Widget _buildAccountCard() {
    final initial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'T';
    
    return GestureDetector(
      onTap: _showEditNameDialog,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2238),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF6C3FFF),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to edit name',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active,
            iconColor: const Color(0xFF6C3FFF),
            title: 'Push Notifications',
            value: _pushNotificationsEnabled,
            onChanged: (value) {
              setState(() => _pushNotificationsEnabled = value);
              _service.setSetting('pushNotifications', value.toString());
            },
          ),
          const Divider(color: Color(0xFF3D3449), height: 1),
          _buildSwitchTile(
            icon: Icons.volume_up,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Completion Sound',
            value: _completionSoundEnabled,
            onChanged: (value) {
              setState(() => _completionSoundEnabled = value);
              _service.setSetting('completionSound', value.toString());
            },
          ),
          const Divider(color: Color(0xFF3D3449), height: 1),
          _buildNavTile(
            icon: Icons.lock,
            iconColor: const Color(0xFF6C3FFF),
            title: 'Privacy & Security',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C3FFF),
            activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF3D3449),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildNavTile(
        icon: Icons.code,
        iconColor: const Color(0xFFFF6B35),
        title: 'Developer Settings',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeveloperSettingsScreen(),
            ),
          );
        },
      ),
    );
  }
}

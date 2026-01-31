import 'package:flutter/material.dart';
import '../services/hobby_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'developer_settings_screen.dart';
import 'landing_screen.dart';

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
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  String _userName = 'Tham';
  String? _userEmail;
  bool _isGoogleSignedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadSettings();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isGoogleSignedIn = await _authService.isGoogleSignedIn();
    final email = await _service.getSetting('userEmail');
    
    if (mounted) {
      setState(() {
        _isGoogleSignedIn = isGoogleSignedIn;
        _userEmail = email;
      });
    }
  }

  Future<void> _loadUserName() async {
    final name = await _service.getSetting('userName');
    if (mounted && name != null && name.isNotEmpty) {
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
    // Don't allow editing if signed in with Google
    if (_isGoogleSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is synced from your Google account'),
          backgroundColor: Color(0xFF6C3FFF),
        ),
      );
      return;
    }
    
    final controller = TextEditingController(text: _userName);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221834),
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221834),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout? Your hobbies will remain on this device.',
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
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LandingScreen(
              onGetStarted: () {
                Navigator.of(context).pushReplacementNamed('/name-input');
              },
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: const Text(
                'Settings',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
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
                    const Text(
                      'SUPPORT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSupportCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'ABOUT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAboutCard(),
                    const SizedBox(height: 32),
                    _buildDeveloperSettingsCard(),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '© 2026 Hobbyist. Made with ',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'for better hobbies',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
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
              _buildNavItemIcon(Icons.local_fire_department, 1),
              _buildNavItem(Icons.settings, 'Settings', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == 2; // Settings is index 2
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
    final isSelected = index == 2; // Settings is index 2
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

  Widget _buildAccountCard() {
    final initial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'T';
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Section
          GestureDetector(
            onTap: _showEditNameDialog,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF6C3FFF),
                    child: _isGoogleSignedIn && _userEmail != null
                        ? const Icon(Icons.person, color: Colors.white, size: 28)
                        : Text(
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
                        Text(
                          _isGoogleSignedIn && _userEmail != null 
                              ? _userEmail! 
                              : 'Tap to edit name',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isGoogleSignedIn)
                    const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
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
            icon: Icons.vibration,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Sound and Vibration',
            value: _completionSoundEnabled,
            onChanged: (value) {
              setState(() => _completionSoundEnabled = value);
              _service.setSetting('completionSound', value.toString());
            },
          ),
          // Logout button (only show if signed in with Google)
          if (_isGoogleSignedIn) ...[
            const Divider(color: Color(0xFF3D3449), height: 1),
            InkWell(
              onTap: _handleLogout,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout, color: Colors.red, size: 22),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNavTile(
            icon: Icons.star_outline,
            iconColor: const Color(0xFFFFD700),
            title: 'Rate the App',
            onTap: () {
              // TODO: Open app store rating
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening app store...'),
                  backgroundColor: Color(0xFF6C3FFF),
                ),
              );
            },
          ),
          const Divider(color: Color(0xFF382a54), height: 1),
          _buildNavTile(
            icon: Icons.feedback_outlined,
            iconColor: const Color(0xFF6C3FFF),
            title: 'Send Feedback',
            onTap: () {
              // TODO: Open email or feedback form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening feedback form...'),
                  backgroundColor: Color(0xFF6C3FFF),
                ),
              );
            },
          ),
          const Divider(color: Color(0xFF382a54), height: 1),
          _buildNavTile(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF10B981),
            title: 'Terms of Service',
            onTap: () {
              // TODO: Open terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Terms of Service...'),
                  backgroundColor: Color(0xFF6C3FFF),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildNavTile(
        icon: Icons.info_outline,
        iconColor: const Color(0xFF6C3FFF),
        title: 'Version 1.0.0',
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF221834),
              title: const Text(
                'About Hobbyist',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Track your hobbies, build streaks, and stay consistent with your goals.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Made with ',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'for better hobbies',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C3FFF),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeveloperSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
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

// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/hobby_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/performance_service.dart';
import '../services/crashlytics_service.dart';
import '../services/feature_flags_service.dart';
import '../services/rating_service.dart';
import '../utils/page_transitions.dart';
import 'add_hobby_screen.dart';
import 'developer_settings_screen.dart';
import 'landing_screen.dart';
import 'feedback_screen.dart';
import '../constants/test_keys.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(int) onNavigate;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _completionSoundEnabled = true;
  final HobbyService _service = HobbyService();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  final RatingService _ratingService = RatingService();
  String _userName = 'Tham';
  String? _userEmail;
  bool _isGoogleSignedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadSettings();
    _checkAuthStatus();
    // Ensure analytics are always enabled
    _ensureAnalyticsEnabled();
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
    final completionSound = await _service.getSetting('completion_sound');
    final pushNotifications = await _service.getSetting('push_notifications');

    if (mounted) {
      setState(() {
        _completionSoundEnabled = completionSound != 'false';
        _pushNotificationsEnabled = pushNotifications != 'false';
      });
    }
  }

  Future<void> _ensureAnalyticsEnabled() async {
    await _service.setSetting('telemetry_enabled', 'true');
    await PerformanceService().updateCollectionEnabled();
    await CrashlyticsService().updateCollectionEnabled();
  }

  Future<void> _showEditNameDialog() async {
    // Don't allow editing if signed in with Google
    if (_isGoogleSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is synced from your Google account'),
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
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6C3FFF)),
            ),
            focusedBorder: UnderlineInputBorder(
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
                      'DATA',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDataCard(),
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
                    // Debug: Remote Config refresh button (always show if signed in)
                    if (_isGoogleSignedIn) ...[
                      const SizedBox(height: 32),
                      _buildRefreshConfigCard(),
                    ],
                    // Developer Options - only show if enabled for this email
                    if (FeatureFlagsService().isDeveloperOptionsEnabled) ...[
                      const SizedBox(height: 32),
                      _buildDeveloperSettingsCard(),
                    ],
                    // Logout button at the end (only show if signed in with Google)
                    if (_isGoogleSignedIn) ...[
                      const SizedBox(height: 32),
                      _buildLogoutCard(),
                    ],
                    const SizedBox(height: 24),
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '© 2026 Hobbyist. Made with ',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
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
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildNavItemIcon(IconData icon, int index) {
    final isSelected = index == 3; // Settings is now index 3
    return Expanded(
      child: Material(
        color: Colors.transparent,
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
            key: const Key(TestKeys.settingsEditName),
            onTap: _showEditNameDialog,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: _isGoogleSignedIn && _userEmail != null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 28)
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
              _service.setSetting('push_notifications', value.toString());
            },
            testKey: TestKeys.settingsPushNotifications,
          ),
          const Divider(color: Color(0xFF3D3449), height: 1),
          _buildSwitchTile(
            icon: Icons.vibration,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Sound and Vibration',
            value: _completionSoundEnabled,
            onChanged: (value) {
              setState(() => _completionSoundEnabled = value);
              _service.setSetting('completion_sound', value.toString());
            },
            testKey: TestKeys.settingsSoundVibration,
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
    String? testKey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
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
            key: testKey != null ? Key(testKey) : null,
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF10B981);
              }
              return Colors.white;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF10B981).withValues(alpha: 0.5);
              }
              return const Color(0xFF3D3449);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isEnabled = true,
    String? testKey,
  }) {
    return InkWell(
      key: testKey != null ? Key(testKey) : null,
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isEnabled ? Colors.white54 : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNavTile(
            icon: Icons.file_download_outlined,
            iconColor: const Color(0xFF3B82F6),
            title: 'Export Data',
            subtitle: 'Coming Soon',
            isEnabled: false,
            onTap: () {},
          ),
          const Divider(color: Color(0xFF382a54), height: 1),
          _buildNavTile(
            icon: Icons.file_upload_outlined,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Import Data',
            subtitle: 'Coming Soon',
            isEnabled: false,
            onTap: () {},
          ),
        ],
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
            testKey: TestKeys.settingsRateApp,
            onTap: () async {
              try {
                await _ratingService.openStoreListing();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open app store: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const Divider(color: Color(0xFF382a54), height: 1),
          _buildNavTile(
            icon: Icons.feedback_outlined,
            iconColor: const Color(0xFF6C3FFF),
            title: 'Send Feedback',
            testKey: TestKeys.settingsSendFeedback,
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const FeedbackScreen(),
                  direction: AxisDirection.left,
                ),
              );
            },
          ),
          const Divider(color: Color(0xFF382a54), height: 1),
          _buildNavTile(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF10B981),
            title: 'Privacy Policy',
            testKey: TestKeys.settingsPrivacyPolicy,
            onTap: () async {
              final url = Uri.parse(
                  'https://github.com/thamaraiselvam/hobbyist-privacy-policy/blob/main/PRIVACY_POLICY.md');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open Privacy Policy: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
        testKey: TestKeys.settingsAbout,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF221834),
              title: const Text(
                'About Hobbyist',
                style: TextStyle(color: Colors.white),
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Track your hobbies, build streaks, and stay consistent with your goals.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Made with ',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
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
        title: 'Developer Options',
        testKey: TestKeys.settingsDeveloperOptions,
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

  Widget _buildLogoutCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        key: const Key(TestKeys.settingsLogout),
        onTap: _handleLogout,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
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
    );
  }

  Widget _buildRefreshConfigCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF221834),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        key: const Key(TestKeys.settingsRefreshFlags),
        onTap: () async {
          // Show loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refreshing feature flags from Firebase...'),
              duration: Duration(seconds: 2),
            ),
          );

          // Refresh Remote Config and feature flags
          await FeatureFlagsService().refresh();

          // Reload page to show updated features
          setState(() {});

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Feature flags refreshed! Email: ${_authService.userEmail}'),
                backgroundColor: const Color(0xFF4CAF78), // Readable green

                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C3FFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh,
                    color: Color(0xFF6C3FFF), size: 22),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refresh Feature Flags',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Force fetch from Firebase Remote Config',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'daily_tasks_screen.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  Future<void> _saveName() async {
    final rawName = _nameController.text.trim();
    if (rawName.isEmpty) return;

    // Auto-capitalize each word (e.g., "john doe" -> "John Doe")
    final name = rawName
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');

    // Save as offline user
    await _authService.saveOfflineUser(name);

    // Track onboarding completion
    await AnalyticsService().logOnboardingComplete();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    const Text(
                      'What should we call you?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set a display name for your hobby profile.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 80),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Tham',
                        hintStyle: TextStyle(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6C3FFF),
                            width: 2,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6C3FFF),
                            width: 2,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                    ),
                    const Spacer(),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled ? _saveName : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            disabledBackgroundColor: const Color(0xFF3D3449),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.white.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Journey',
                                style: TextStyle(
                                  color: _isButtonEnabled
                                      ? Colors.black87
                                      : Colors.white38,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: _isButtonEnabled
                                    ? Colors.black87
                                    : Colors.white38,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

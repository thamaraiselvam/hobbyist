// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import 'daily_tasks_screen.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const LandingScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Track landing page view
    AnalyticsService().logLandingView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161022),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTitleSection(),
            Expanded(child: _buildFeaturesList()),
            _buildFooter(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const SizedBox(height: 24);
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1.1,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Design Your\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Discipline',
                  style: TextStyle(color: Color(0xFF590df2)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track your hobbies with clarity — designed for focus, privacy, and simplicity.',
            style: TextStyle(
              color: Color(0xFFa490cb),
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ListView(
        children: [
          _buildFeatureItem(
            icon: Icons.cloud_off,
            title: 'Offline First',
            subtitle: 'Your data stays securely on your device.',
          ),
          _buildFeatureItem(
            icon: Icons.payments,
            title: 'Completely Free',
            subtitle: 'No subscriptions or hidden fees.',
          ),
          _buildFeatureItem(
            icon: Icons.leaderboard,
            title: 'Powerful Insights',
            subtitle: 'Visualize your progress with elegant charts.',
          ),
          _buildFeatureItem(
            icon: Icons.grid_view,
            title: 'Minimalist UI',
            subtitle: 'Designed for deep focus and zero distraction.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF590df2).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF590df2),
              size: 24,
            ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFa490cb),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Horizontal separator line
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3D3449),
                  Color(0xFF6C3FFF),
                  Color(0xFF3D3449),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Continue Offline Button - white background for easy readability
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 8,
                shadowColor: Colors.white.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 20, color: Colors.black87),
                  SizedBox(width: 10),
                  Text(
                    'Continue Offline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Bottom note text
          const Text(
            'All your data stays private and secure on your device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7d6f93),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Bottom indicator
          Container(
            width: 128,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2238),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'landing_screen.dart';
import 'daily_tasks_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    
    // Check first launch and navigate accordingly
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final hasSeenLanding = prefs.getBool('has_seen_landing') ?? false;
        
        if (!hasSeenLanding) {
          // Show landing page on first launch
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => LandingScreen(
                onGetStarted: () async {
                  await prefs.setBool('has_seen_landing', true);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const DailyTasksScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                        transitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return child;
              },
              transitionDuration: Duration.zero,
            ),
          );
        } else {
          // Go directly to main app
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const DailyTasksScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return child;
              },
              transitionDuration: Duration.zero,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF1A1625),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with circle border and triangle
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A3F6B),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C3FFF).withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Triangle
                      CustomPaint(
                        size: const Size(80, 70),
                        painter: TrianglePainter(),
                      ),
                      // Checkmark positioned on triangle
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Icon(
                          Icons.check,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // App name
              const Text(
                'Hobbyist',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              const Text(
                'DISCIPLINE BEATS MOTIVATION',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the triangle
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9F8FD8)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

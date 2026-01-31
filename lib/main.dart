import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/name_input_screen.dart';
import 'screens/daily_tasks_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize notification service
  try {
    await NotificationService().initialize();
    final permissionGranted = await NotificationService().requestPermissions();
    print('🔔 Notification permissions granted: $permissionGranted');
    
    final canSchedule = await NotificationService().canScheduleExactAlarms();
    print('⏰ Can schedule exact alarms: $canSchedule');
    
    final pending = await NotificationService().getPendingNotifications();
    print('📋 Pending notifications: ${pending.length}');
    for (var notif in pending) {
      print('   - ID: ${notif.id}, Title: ${notif.title}, Body: ${notif.body}');
    }
  } catch (e) {
    print('❌ Error initializing notifications: $e');
  }

  runApp(const HobbyTrackerApp());
}

class HobbyTrackerApp extends StatelessWidget {
  const HobbyTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hobbyist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C3FFF),
        scaffoldBackgroundColor: const Color(0xFF1A1625),
        cardColor: const Color(0xFF2A2238),
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C3FFF),
          secondary: Color(0xFF8B5CF6),
          surface: Color(0xFF2A2238),
          background: Color(0xFF1A1625),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF2A2238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1625),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C3FFF),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          case '/landing':
            return MaterialPageRoute(
              builder: (context) => LandingScreen(
                onGetStarted: () {
                  Navigator.of(context).pushReplacementNamed('/name-input');
                },
              ),
            );
          case '/name-input':
            return MaterialPageRoute(
                builder: (context) => const NameInputScreen());
          case '/dashboard':
            return MaterialPageRoute(
                builder: (context) => const DailyTasksScreen());
          default:
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
        }
      },
    );
  }
}

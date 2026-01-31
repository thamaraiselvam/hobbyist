import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/name_input_screen.dart';
import 'screens/daily_tasks_screen.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';
import 'services/performance_service.dart';
import 'services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase Core
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase Core initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase Core: $e');
  }

  // Initialize Firebase services
  try {
    // Initialize Crashlytics (must be first for error catching)
    await CrashlyticsService.initialize();
    
    // Initialize Analytics
    AnalyticsService.initialize();
    
    // Initialize Performance Monitoring
    await PerformanceService.initialize();
    
    // Initialize Remote Config
    await RemoteConfigService.initialize();
    
    print('✅ All Firebase services initialized');
  } catch (e) {
    print('❌ Error initializing Firebase services: $e');
  }

  // Initialize notification service (but don't request permission yet)
  try {
    await NotificationService().initialize();
    print('🔔 Notification service initialized (permissions will be requested on first use)');
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
      navigatorObservers: [
        if (AnalyticsService.observer != null) AnalyticsService.observer!,
      ],
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
        cardTheme: CardTheme(
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

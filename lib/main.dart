import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HobbyTrackerApp());
}

class HobbyTrackerApp extends StatelessWidget {
  const HobbyTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hobby Tracker',
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
      home: const SplashScreen(),
    );
  }
}

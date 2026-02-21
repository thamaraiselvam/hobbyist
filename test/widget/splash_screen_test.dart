import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {
            '/landing': (context) => const SizedBox(),
            '/dashboard': (context) => const SizedBox(),
          },
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SplashScreen),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('should navigate to landing screen when not onboarded',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': false});

      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {
            '/landing': (context) => const Scaffold(body: Text('Landing')),
            '/dashboard': (context) => const Scaffold(body: Text('Dashboard')),
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(find.text('Landing'), findsOneWidget);
    });

    testWidgets('should navigate to dashboard when onboarded',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});

      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {
            '/landing': (context) => const Scaffold(body: Text('Landing')),
            '/dashboard': (context) => const Scaffold(body: Text('Dashboard')),
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should have fade animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {
            '/landing': (context) => const SizedBox(),
            '/dashboard': (context) => const SizedBox(),
          },
        ),
      );

      final fadeTransition = tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(SplashScreen),
          matching: find.byType(FadeTransition),
        ),
      );

      expect(fadeTransition.opacity, isNotNull);

      // Drain the timer
      await tester.pump(const Duration(seconds: 3));
    });
  });
}

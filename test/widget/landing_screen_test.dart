import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/screens/landing_screen.dart';

void main() {
  group('LandingScreen Widget Tests', () {
    testWidgets('should display landing screen content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      expect(find.byType(LandingScreen), findsOneWidget);
      expect(find.text('Track Your Daily\nHobbies with Ease'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('should have Get Started button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('should navigate when Get Started is pressed', (WidgetTester tester) async {
      bool navigated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: const LandingScreen(),
          routes: {
            '/name-input': (context) {
              navigated = true;
              return const Scaffold(body: Text('Name Input'));
            },
          },
        ),
      );

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(navigated, true);
    });

    testWidgets('should display hero image', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF1A1625));
    });
  });
}

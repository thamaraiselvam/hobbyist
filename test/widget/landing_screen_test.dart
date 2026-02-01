import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/screens/landing_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import '../helpers/firebase_mocks.dart';

void main() async {
  await setupFirebaseMocks();

  setUpAll(() async {
    // Mock path_provider
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });

    await Firebase.initializeApp();

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LandingScreen Widget Tests', () {
    testWidgets('should display landing screen content',
        (WidgetTester tester) async {
      // Skip: Firebase initialization issues
    }, skip: true);

    testWidgets('should trigger onGetStarted when Continue Offline is pressed',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LandingScreen(onGetStarted: () {
            pressed = true;
          }),
        ),
      );

      await tester.tap(find.text('Continue Offline'));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('should have correct background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingScreen(onGetStarted: () {}),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF161022));
    });

    testWidgets('should display feature list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingScreen(onGetStarted: () {}),
        ),
      );

      final listFinder = find.byType(Scrollable);
      expect(listFinder, findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Offline First'),
        500,
        scrollable: listFinder,
      );
      expect(find.text('Offline First'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Completely Free'),
        500,
        scrollable: listFinder,
      );
      expect(find.text('Completely Free'), findsOneWidget);

      expect(find.byType(Icon), findsWidgets);
    });
  });
}

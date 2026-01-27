import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SettingsScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});
    });

    testWidgets('should display settings screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (_) {},
            onBack: () {},
          ),
        ),
      );

      // Settings appears twice: in AppBar title and in bottom nav
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('should display account section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (_) {},
            onBack: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('ACCOUNT'), findsOneWidget);
    });

    testWidgets('should display preferences section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (_) {},
            onBack: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('PREFERENCES'), findsOneWidget);
    });

    testWidgets('should display version info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (_) {},
            onBack: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('v1.0.0'), findsOneWidget);
    });

    testWidgets('should have bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (_) {},
            onBack: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('should call onNavigate when nav item is tapped', (WidgetTester tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (index) {
              navigatedIndex = index;
            },
            onBack: () {},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pump();

      expect(navigatedIndex, 0);
    });

    testWidgets('should show edit name dialog when account card is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (_) {},
            onBack: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the account card (CircleAvatar or containing GestureDetector)
      final accountCard = find.byType(GestureDetector).first;
      await tester.tap(accountCard);
      await tester.pumpAndSettle();

      expect(find.text('Edit Name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should cancel edit name operation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            onNavigate: (_) {},
            onBack: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      final accountCard = find.byType(GestureDetector).first;
      await tester.tap(accountCard);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Name'), findsNothing);
    });
  });
}

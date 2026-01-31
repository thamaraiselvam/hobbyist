import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/screens/name_input_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('NameInputScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display name input screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NameInputScreen(),
        ),
      );

      expect(find.text('What should we call you?'), findsOneWidget);
      expect(find.text('Set a display name for your hobby profile.'),
          findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Start My Journey'), findsOneWidget);
    });

    testWidgets('should disable button when text is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NameInputScreen(),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('should enable button when text is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NameInputScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNotNull);
    });

    testWidgets('should not enable button with only whitespace',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NameInputScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('should have correct hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NameInputScreen(),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, 'e.g. Tham');
    });

    testWidgets('should capitalize words', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NameInputScreen(),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textCapitalization, TextCapitalization.words);
    });

    testWidgets('should autofocus text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NameInputScreen(),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, true);
    });
  });
}

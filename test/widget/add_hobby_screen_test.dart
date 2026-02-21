import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/screens/add_hobby_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AddHobbyScreen Widget Tests', () {
    testWidgets('should display add hobby screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddHobbyScreen()));

      expect(find.text('ADD NEW HOBBY TASK'), findsOneWidget);
      expect(find.text('FREQUENCY'), findsOneWidget);
      expect(find.text('COLOR PALETTE'), findsOneWidget);
      expect(find.text('Create Activity'), findsOneWidget);
    });

    testWidgets('should enable create button always', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddHobbyScreen()));

      final button = find.widgetWithText(ElevatedButton, 'Create Activity');
      expect(button, findsOneWidget);

      // In the new UI, validation happens on press, button is always enabled
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('should show validation error when name is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddHobbyScreen()));

      final button = find.widgetWithText(ElevatedButton, 'Create Activity');
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Please enter a hobby name'), findsOneWidget);
    });

    testWidgets('should display frequency options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddHobbyScreen()));

      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('should display color selection', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddHobbyScreen()));

      expect(find.text('COLOR PALETTE'), findsOneWidget);
    });

    testWidgets('should have cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddHobbyScreen()));

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should pop when cancel button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddHobbyScreen(),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('ADD NEW HOBBY TASK'), findsOneWidget);

      final cancelButton = find.widgetWithText(TextButton, 'Cancel').first;
      await tester.scrollUntilVisible(
        cancelButton,
        100,
        scrollable: find
            .descendant(
              of: find.byType(AddHobbyScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.text('ADD NEW HOBBY TASK'), findsNothing);
    });
  });
}

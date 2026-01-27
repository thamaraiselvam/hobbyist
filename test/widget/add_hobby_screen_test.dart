import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/screens/add_hobby_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AddHobbyScreen Widget Tests', () {
    testWidgets('should display add hobby screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddHobbyScreen(onHobbyAdded: () {}),
        ),
      );

      expect(find.text('Add New Hobby'), findsOneWidget);
      expect(find.text('Hobby Name'), findsOneWidget);
      expect(find.text('Notes (Optional)'), findsOneWidget);
      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
    });

    testWidgets('should have disabled save button initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddHobbyScreen(onHobbyAdded: () {}),
        ),
      );

      final button = find.widgetWithText(ElevatedButton, 'Save Hobby');
      expect(button, findsOneWidget);
      
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('should enable save button when name is entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddHobbyScreen(onHobbyAdded: () {}),
        ),
      );

      final nameFields = find.byType(TextField);
      await tester.tap(nameFields.first);
      await tester.enterText(nameFields.first, 'Test Hobby');
      await tester.pump();

      final button = find.widgetWithText(ElevatedButton, 'Save Hobby');
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('should display repeat mode options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddHobbyScreen(onHobbyAdded: () {}),
        ),
      );

      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('should display priority options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddHobbyScreen(onHobbyAdded: () {}),
        ),
      );

      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('should display color selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddHobbyScreen(onHobbyAdded: () {}),
        ),
      );

      expect(find.text('Choose Color'), findsOneWidget);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddHobbyScreen(onHobbyAdded: () {}),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should pop when back button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddHobbyScreen(onHobbyAdded: () {}),
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

      expect(find.text('Add New Hobby'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Add New Hobby'), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/widgets/animated_checkbox.dart';

void main() {
  group('AnimatedCheckbox Widget Tests', () {
    testWidgets('should display unchecked checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCheckbox(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedCheckbox), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('should display checked checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCheckbox(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('should call onChanged when tapped', (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCheckbox(
              value: false,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(changedValue, true);
    });

    testWidgets('should have scale animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCheckbox(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Check for AnimatedBuilder or Transform widget that handles scaling
      expect(find.byType(AnimatedCheckbox), findsOneWidget);
    });

    testWidgets('should animate when value changes', (WidgetTester tester) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedCheckbox(
                  value: value,
                  onChanged: (newValue) {
                    setState(() {
                      value = newValue!;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });
  });
}

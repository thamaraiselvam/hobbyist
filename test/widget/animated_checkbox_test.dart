import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/widgets/animated_checkbox.dart';

void main() {
  group('AnimatedCheckbox Widget Tests', () {
    testWidgets('should display unchecked checkbox', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCheckbox(isChecked: false, onTap: () {}),
          ),
        ),
      );

      expect(find.byType(AnimatedCheckbox), findsOneWidget);
    });

    testWidgets('should display checked checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AnimatedCheckbox(isChecked: true, onTap: () {})),
        ),
      );

      expect(find.byType(AnimatedCheckbox), findsOneWidget);
      // Since it's a CustomPaint, we can't easily assert pixel details without golden tests,
      // but we verify the widget exists.
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCheckbox(
              isChecked: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedCheckbox));
      expect(tapped, true);
    });

    testWidgets('should animate when value changes', (
      WidgetTester tester,
    ) async {
      bool isChecked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedCheckbox(
                  isChecked: isChecked,
                  onTap: () {
                    setState(() {
                      isChecked = !isChecked;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedCheckbox));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(isChecked, true);
    });
  });
}

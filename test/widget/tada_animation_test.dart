import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/widgets/tada_animation.dart';

void main() {
  group('TadaAnimation Widget Tests', () {
    testWidgets('should display child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TadaAnimation(
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should have animation controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TadaAnimation(
              child: Icon(Icons.check),
            ),
          ),
        ),
      );

      expect(find.byType(TadaAnimation), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should animate child', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TadaAnimation(
              child: Text('Animated'),
            ),
          ),
        ),
      );

      // Let animation run
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Animated'), findsOneWidget);
    });

    testWidgets('should complete animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TadaAnimation(
              child: Text('Complete'),
            ),
          ),
        ),
      );

      // Complete the animation
      await tester.pumpAndSettle();

      expect(find.text('Complete'), findsOneWidget);
    });
  });
}

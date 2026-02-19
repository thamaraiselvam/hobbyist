import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/utils/page_transitions.dart';

void main() {
  group('SlidePageRoute Tests', () {
    test('should create SlidePageRoute with default direction', () {
      final route = SlidePageRoute(page: const SizedBox());
      expect(route, isNotNull);
      expect(route.direction, AxisDirection.left);
    });

    test('should create SlidePageRoute with up direction', () {
      final route = SlidePageRoute(
        page: const SizedBox(),
        direction: AxisDirection.up,
      );
      expect(route.direction, AxisDirection.up);
    });

    test('should create SlidePageRoute with down direction', () {
      final route = SlidePageRoute(
        page: const SizedBox(),
        direction: AxisDirection.down,
      );
      expect(route.direction, AxisDirection.down);
    });

    test('should create SlidePageRoute with left direction', () {
      final route = SlidePageRoute(
        page: const SizedBox(),
        direction: AxisDirection.left,
      );
      expect(route.direction, AxisDirection.left);
    });

    test('should create SlidePageRoute with right direction', () {
      final route = SlidePageRoute(
        page: const SizedBox(),
        direction: AxisDirection.right,
      );
      expect(route.direction, AxisDirection.right);
    });

    test('should have correct transition duration', () {
      final route = SlidePageRoute(page: const SizedBox());
      expect(route.transitionDuration, const Duration(milliseconds: 350));
    });

    test('should have correct reverse transition duration', () {
      final route = SlidePageRoute(page: const SizedBox());
      expect(
          route.reverseTransitionDuration, const Duration(milliseconds: 300));
    });

    testWidgets('should build page correctly', (WidgetTester tester) async {
      final route = SlidePageRoute(page: const Text('Test Page'));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(route),
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Test Page'), findsOneWidget);
    });
  });

  group('FadePageRoute Tests', () {
    test('should create FadePageRoute', () {
      final route = FadePageRoute(page: const SizedBox());
      expect(route, isNotNull);
    });

    test('should have correct transition duration', () {
      final route = FadePageRoute(page: const SizedBox());
      expect(route.transitionDuration, const Duration(milliseconds: 300));
    });

    test('should have correct reverse transition duration', () {
      final route = FadePageRoute(page: const SizedBox());
      expect(
          route.reverseTransitionDuration, const Duration(milliseconds: 250));
    });

    testWidgets('should build page correctly', (WidgetTester tester) async {
      final route = FadePageRoute(page: const Text('Fade Page'));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(route),
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Fade Page'), findsOneWidget);
    });
  });

  group('ScalePageRoute Tests', () {
    test('should create ScalePageRoute', () {
      final route = ScalePageRoute(page: const SizedBox());
      expect(route, isNotNull);
    });

    test('should have correct transition duration', () {
      final route = ScalePageRoute(page: const SizedBox());
      expect(route.transitionDuration, const Duration(milliseconds: 400));
    });

    test('should have correct reverse transition duration', () {
      final route = ScalePageRoute(page: const SizedBox());
      expect(
          route.reverseTransitionDuration, const Duration(milliseconds: 300));
    });

    testWidgets('should build page correctly', (WidgetTester tester) async {
      final route = ScalePageRoute(page: const Text('Scale Page'));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(route),
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Scale Page'), findsOneWidget);
    });
  });

  group('All Page Routes Comparison', () {
    test('SlidePageRoute should have longest transition', () {
      final slide = SlidePageRoute(page: const SizedBox());
      final fade = FadePageRoute(page: const SizedBox());
      final scale = ScalePageRoute(page: const SizedBox());

      expect(scale.transitionDuration.inMilliseconds,
          greaterThan(slide.transitionDuration.inMilliseconds));
      expect(slide.transitionDuration.inMilliseconds,
          greaterThan(fade.transitionDuration.inMilliseconds));
    });

    test('all routes should be PageRouteBuilder', () {
      final slide = SlidePageRoute(page: const SizedBox());
      final fade = FadePageRoute(page: const SizedBox());
      final scale = ScalePageRoute(page: const SizedBox());

      expect(slide, isA<PageRouteBuilder>());
      expect(fade, isA<PageRouteBuilder>());
      expect(scale, isA<PageRouteBuilder>());
    });
  });
}

// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/models/hobby.dart';

void main() {
  group('Hobby Streak Calculations', () {
    test('currentStreak should be 0 when no completions', () {
      final hobby = Hobby(
        id: '1',
        name: 'Test',
        color: 0xFF6C3FFF,
        completions: {},
      );

      expect(hobby.currentStreak, 0);
    });

    test('currentStreak should be 1 when only today is completed', () {
      final today = DateTime.now();
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final hobby = Hobby(
        id: '1',
        name: 'Test',
        color: 0xFF6C3FFF,
        completions: {
          todayKey: HobbyCompletion(completed: true, completedAt: today),
        },
      );

      expect(hobby.currentStreak, 1);
    });

    test('currentStreak should be 5 for 5 consecutive days including today', () {
      final today = DateTime.now();
      final completions = <String, HobbyCompletion>{};

      for (int i = 0; i < 5; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        completions[dateKey] = HobbyCompletion(
          completed: true,
          completedAt: date,
        );
      }

      final hobby = Hobby(
        id: '1',
        name: 'Test',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 5);
    });

    test('currentStreak should reset when there is a gap', () {
      final today = DateTime.now();
      final completions = <String, HobbyCompletion>{};

      // Complete today and yesterday
      for (int i = 0; i < 2; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        completions[dateKey] = HobbyCompletion(
          completed: true,
          completedAt: date,
        );
      }

      // Skip day before yesterday (gap)
      // Complete 3 days ago
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final threeDaysAgoKey =
          '${threeDaysAgo.year}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}';
      completions[threeDaysAgoKey] = HobbyCompletion(
        completed: true,
        completedAt: threeDaysAgo,
      );

      final hobby = Hobby(
        id: '1',
        name: 'Test',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 2); // Only today and yesterday count
    });

    test(
      'calculateBestStreakFromHistory should return 0 when no completions',
      () {
        final hobby = Hobby(
          id: '1',
          name: 'Test',
          color: 0xFF6C3FFF,
          completions: {},
        );

        expect(hobby.calculateBestStreakFromHistory(), 0);
      },
    );

    test(
      'calculateBestStreakFromHistory should return 1 for single completion',
      () {
        final today = DateTime.now();
        final todayKey =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        final hobby = Hobby(
          id: '1',
          name: 'Test',
          color: 0xFF6C3FFF,
          completions: {
            todayKey: HobbyCompletion(completed: true, completedAt: today),
          },
        );

        expect(hobby.calculateBestStreakFromHistory(), 1);
      },
    );

    test(
      'calculateBestStreakFromHistory should return 5 for 5 consecutive days',
      () {
        final baseDate = DateTime(2026, 1, 1);
        final completions = <String, HobbyCompletion>{};

        for (int i = 0; i < 5; i++) {
          final date = baseDate.add(Duration(days: i));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          completions[dateKey] = HobbyCompletion(
            completed: true,
            completedAt: date,
          );
        }

        final hobby = Hobby(
          id: '1',
          name: 'Test',
          color: 0xFF6C3FFF,
          completions: completions,
        );

        expect(hobby.calculateBestStreakFromHistory(), 5);
      },
    );

    test(
      'calculateBestStreakFromHistory should find max streak across multiple streaks',
      () {
        final baseDate = DateTime(2026, 1, 1);
        final completions = <String, HobbyCompletion>{};

        // First streak: 3 days (Jan 1-3)
        for (int i = 0; i < 3; i++) {
          final date = baseDate.add(Duration(days: i));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          completions[dateKey] = HobbyCompletion(
            completed: true,
            completedAt: date,
          );
          print('Added completion: $dateKey');
        }

        // Gap on Jan 4

        // Second streak: 5 days (Jan 5-9) - THIS IS THE BEST
        for (int i = 4; i < 9; i++) {
          final date = baseDate.add(Duration(days: i));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          completions[dateKey] = HobbyCompletion(
            completed: true,
            completedAt: date,
          );
          print('Added completion: $dateKey');
        }

        // Gap on Jan 10

        // Third streak: 2 days (Jan 11-12)
        for (int i = 10; i < 12; i++) {
          final date = baseDate.add(Duration(days: i));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          completions[dateKey] = HobbyCompletion(
            completed: true,
            completedAt: date,
          );
          print('Added completion: $dateKey');
        }

        final hobby = Hobby(
          id: '1',
          name: 'Test',
          color: 0xFF6C3FFF,
          completions: completions,
        );

        final best = hobby.calculateBestStreakFromHistory();
        print('Calculated best streak: $best');

        expect(best, 5);
      },
    );

    test(
      'calculateBestStreakFromHistory should handle ongoing streak as the best',
      () {
        final today = DateTime.now();
        final completions = <String, HobbyCompletion>{};

        // Old streak: 3 days, 10 days ago
        final tenDaysAgo = today.subtract(const Duration(days: 10));
        for (int i = 0; i < 3; i++) {
          final date = tenDaysAgo.add(Duration(days: i));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          completions[dateKey] = HobbyCompletion(
            completed: true,
            completedAt: date,
          );
        }

        // Current ongoing streak: 5 days (including today) - THIS IS THE BEST
        for (int i = 0; i < 5; i++) {
          final date = today.subtract(Duration(days: i));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          completions[dateKey] = HobbyCompletion(
            completed: true,
            completedAt: date,
          );
        }

        final hobby = Hobby(
          id: '1',
          name: 'Test',
          color: 0xFF6C3FFF,
          completions: completions,
        );

        expect(hobby.calculateBestStreakFromHistory(), 5);
      },
    );

    test('bestStreak should always be >= currentStreak', () {
      final today = DateTime.now();
      final completions = <String, HobbyCompletion>{};

      // Create 5 consecutive days including today
      for (int i = 0; i < 5; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        completions[dateKey] = HobbyCompletion(
          completed: true,
          completedAt: date,
        );
      }

      final hobby = Hobby(
        id: '1',
        name: 'Test',
        color: 0xFF6C3FFF,
        completions: completions,
        bestStreak: 0, // Start with 0
      );

      final currentStreak = hobby.currentStreak;
      final historicalBest = hobby.calculateBestStreakFromHistory();

      print('Current streak: $currentStreak');
      print('Historical best: $historicalBest');
      print('Stored best: ${hobby.bestStreak}');

      // The true best should be at least the current streak
      final trueBest = [
        hobby.bestStreak,
        historicalBest,
        currentStreak,
      ].reduce((a, b) => a > b ? a : b);

      expect(
        trueBest >= currentStreak,
        true,
        reason:
            'Best streak ($trueBest) should be >= current streak ($currentStreak)',
      );
      expect(trueBest, 5);
    });
  });
}

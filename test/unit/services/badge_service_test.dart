import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/models/badge.dart';
import 'package:hobbyist/models/hobby.dart';
import 'package:hobbyist/services/badge_service.dart';

void main() {
  group('BadgeService', () {
    test('unlocks streak badge once and persists unlocked IDs', () async {
      final store = <String, String>{};
      final service = BadgeService(
        getSetting: (key) async => store[key],
        setSetting: (key, value) async => store[key] = value,
      );

      final badges = [
        const Badge(
          id: 'spark_streak_3',
          name: 'Spark Streak',
          description: '3 days',
          category: 'streak',
          rarity: 'common',
          metric: 'streakDays',
          operator: '>=',
          value: 3,
          asset: 'assets/images/badges/spark_streak.svg',
          shareTemplate: 'assets/images/badges/share_card_template.svg',
        ),
      ];

      final now = DateTime.now();
      final completions = <String, HobbyCompletion>{
        _key(now): HobbyCompletion(completed: true),
        _key(now.subtract(const Duration(days: 1))): HobbyCompletion(completed: true),
        _key(now.subtract(const Duration(days: 2))): HobbyCompletion(completed: true),
      };

      final hobbies = [
        Hobby(id: 'h1', name: 'Read', color: 0xFF6C3FFF, completions: completions),
      ];

      final first = await service.evaluateNewUnlocks(hobbies, badgesOverride: badges);
      final second = await service.evaluateNewUnlocks(hobbies, badgesOverride: badges);

      expect(first.length, 1);
      expect(first.first.badge.id, 'spark_streak_3');
      expect(second, isEmpty);
      expect(store['unlocked_badge_ids'], contains('spark_streak_3'));
    });
  });
}

String _key(DateTime date) {
  final y = date.year.toString();
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/utils/default_hobbies.dart';

void main() {
  group('HobbyData Tests', () {
    test('should create HobbyData with emoji and name', () {
      const hobbyData = HobbyData(emoji: '🏃', name: 'Running');
      expect(hobbyData.emoji, '🏃');
      expect(hobbyData.name, 'Running');
    });

    test('should be const constructible', () {
      const hobbyData1 = HobbyData(emoji: '🏃', name: 'Running');
      const hobbyData2 = HobbyData(emoji: '🏃', name: 'Running');
      expect(hobbyData1.emoji, hobbyData2.emoji);
      expect(hobbyData1.name, hobbyData2.name);
    });
  });

  group('DefaultHobbies Tests', () {
    test('should have hobbies list', () {
      expect(DefaultHobbies.hobbies, isNotEmpty);
    });

    test('should have exactly 300 curated hobbies and tasks', () {
      expect(DefaultHobbies.hobbies.length, 300);
    });

    test('should include fitness hobbies', () {
      final fitnessHobbies = DefaultHobbies.hobbies
          .where(
            (h) => [
              'Running',
              'Cycling',
              'Swimming',
              'Yoga',
              'Gym Workout',
            ].contains(h.name),
          )
          .toList();
      expect(fitnessHobbies.length, 5);
    });

    test('should include creative hobbies', () {
      final creativeHobbies = DefaultHobbies.hobbies
          .where(
            (h) => [
              'Painting',
              'Drawing',
              'Photography',
              'Creative Writing',
            ].contains(h.name),
          )
          .toList();
      expect(creativeHobbies.length, 4);
    });

    test('should include music hobbies', () {
      final musicHobbies = DefaultHobbies.hobbies
          .where(
            (h) =>
                ['Guitar Practice', 'Piano Practice', 'Drum Practice', 'Music Production'].contains(h.name),
          )
          .toList();
      expect(musicHobbies.length, 4);
    });

    test('all hobbies should have emoji', () {
      for (final hobby in DefaultHobbies.hobbies) {
        expect(hobby.emoji, isNotEmpty);
      }
    });

    test('all hobbies should have name', () {
      for (final hobby in DefaultHobbies.hobbies) {
        expect(hobby.name, isNotEmpty);
      }
    });

    group('search Tests', () {
      test('should return all hobbies when query is empty', () {
        final results = DefaultHobbies.search('');
        expect(results.length, DefaultHobbies.hobbies.length);
      });

      test('should find hobbies by exact name', () {
        final results = DefaultHobbies.search('Running');
        expect(results, isNotEmpty);
        expect(results.first.name, 'Running');
      });

      test('should find hobbies by partial name', () {
        final results = DefaultHobbies.search('Run');
        expect(results.any((h) => h.name == 'Running'), true);
      });

      test('should be case insensitive', () {
        final resultsLower = DefaultHobbies.search('running');
        final resultsUpper = DefaultHobbies.search('RUNNING');
        final resultsMixed = DefaultHobbies.search('RuNnInG');

        expect(resultsLower, isNotEmpty);
        expect(resultsUpper, isNotEmpty);
        expect(resultsMixed, isNotEmpty);
        expect(resultsLower.first.name, 'Running');
        expect(resultsUpper.first.name, 'Running');
        expect(resultsMixed.first.name, 'Running');
      });

      test('should find multiple matches', () {
        final results = DefaultHobbies.search('music');
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('should return empty list for no matches', () {
        final results = DefaultHobbies.search('xyznonexistent');
        expect(results, isEmpty);
      });

      test('should find hobbies with partial match in middle', () {
        final results = DefaultHobbies.search('ball');
        expect(results.any((h) => h.name.toLowerCase().contains('ball')), true);
      });

      test('should include and find task templates by cadence', () {
        final weekly = DefaultHobbies.search('weekly task');
        final monthly = DefaultHobbies.search('monthly task');
        final oneTime = DefaultHobbies.search('one-time task');

        expect(weekly.any((h) => h.name.contains('(Weekly Task)')), true);
        expect(monthly.any((h) => h.name.contains('(Monthly Task)')), true);
        expect(oneTime.any((h) => h.name.contains('(One-time Task)')), true);
      });

      test('should support limiting results for UI performance', () {
        final limited = DefaultHobbies.search('task', limit: 6);
        expect(limited.length, lessThanOrEqualTo(6));
      });
    });
  });
}

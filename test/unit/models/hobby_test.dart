import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/models/hobby.dart';

void main() {
  group('Hobby Model Tests', () {
    test('should create hobby with default values', () {
      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
      );

      expect(hobby.id, 'test-id');
      expect(hobby.name, 'Test Hobby');
      expect(hobby.notes, '');
      expect(hobby.repeatMode, 'daily');
      // expect(hobby.priority, 'medium');
      expect(hobby.color, 0xFF6C3FFF);
      expect(hobby.completions, isEmpty);
      expect(hobby.createdAt, isNull);
    });

    test('should create hobby with custom values', () {
      final completions = {
        '2024-01-01':
            HobbyCompletion(completed: true, completedAt: DateTime(2024, 1, 1)),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        notes: 'Test notes',
        repeatMode: 'weekly',
        color: 0xFF6C3FFF,
        completions: completions,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(hobby.notes, 'Test notes');
      expect(hobby.repeatMode, 'weekly');
      // expect(hobby.priority, 'high');
      expect(hobby.completions.length, 1);
      expect(hobby.createdAt, DateTime(2024, 1, 1));
    });

    test('should create hobby with monthly repeat mode', () {
      final hobby = Hobby(
        id: 'test-id',
        name: 'Monthly Task',
        repeatMode: 'monthly',
        color: 0xFF6C3FFF,
      );

      expect(hobby.repeatMode, 'monthly');
      // expect(hobby.priority, 'low');
    });

    test('should calculate current streak correctly with consecutive days', () {
      final today = DateTime.now();
      final completions = {
        _formatDate(today):
            HobbyCompletion(completed: true, completedAt: today),
        _formatDate(today.subtract(const Duration(days: 1))):
            HobbyCompletion(completed: true),
        _formatDate(today.subtract(const Duration(days: 2))):
            HobbyCompletion(completed: true),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 3);
    });

    test('should calculate longer streak correctly', () {
      final today = DateTime.now();
      final completions = <String, HobbyCompletion>{};

      for (int i = 0; i < 10; i++) {
        final date = today.subtract(Duration(days: i));
        completions[_formatDate(date)] =
            HobbyCompletion(completed: true, completedAt: date);
      }

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 10);
    });

    test('should calculate streak as 0 when no completions', () {
      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
      );

      expect(hobby.currentStreak, 0);
    });

    test('should calculate streak as 1 when only today is completed', () {
      final today = DateTime.now();
      final completions = {
        _formatDate(today):
            HobbyCompletion(completed: true, completedAt: today),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 1);
    });

    test('should not count today if not completed', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final completions = {
        _formatDate(yesterday): HobbyCompletion(completed: true),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 1);
    });

    test('should stop streak at first gap', () {
      final today = DateTime.now();
      final completions = {
        _formatDate(today):
            HobbyCompletion(completed: true, completedAt: today),
        _formatDate(today.subtract(const Duration(days: 1))):
            HobbyCompletion(completed: true),
        // Gap on day 2
        _formatDate(today.subtract(const Duration(days: 3))):
            HobbyCompletion(completed: true),
        _formatDate(today.subtract(const Duration(days: 4))):
            HobbyCompletion(completed: true),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 2);
    });

    test('should handle incomplete completions in streak', () {
      final today = DateTime.now();
      final completions = {
        _formatDate(today):
            HobbyCompletion(completed: true, completedAt: today),
        _formatDate(today.subtract(const Duration(days: 1))):
            HobbyCompletion(completed: false),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      expect(hobby.currentStreak, 1);
    });

    test('should convert to JSON correctly', () {
      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        notes: 'Test notes',
        repeatMode: 'weekly',
        color: 0xFF6C3FFF,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = hobby.toJson();

      expect(json['id'], 'test-id');
      expect(json['name'], 'Test Hobby');
      expect(json['notes'], 'Test notes');
      expect(json['repeatMode'], 'weekly');
      // expect(json['priority'], 'high');
      expect(json['color'], 0xFF6C3FFF);
      expect(json['createdAt'], isNotNull);
      expect(json['completions'], isA<Map>());
    });

    test('should convert to JSON with completions', () {
      final completions = {
        '2024-01-01':
            HobbyCompletion(completed: true, completedAt: DateTime(2024, 1, 1)),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
        completions: completions,
      );

      final json = hobby.toJson();
      expect(json['completions'], isA<Map>());
      expect((json['completions'] as Map).containsKey('2024-01-01'), true);
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Hobby',
        'notes': 'Test notes',
        'repeatMode': 'weekly',
        'priority': 'high',
        'color': 0xFF6C3FFF,
        'completions': <String, dynamic>{},
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final hobby = Hobby.fromJson(json);

      expect(hobby.id, 'test-id');
      expect(hobby.name, 'Test Hobby');
      expect(hobby.notes, 'Test notes');
      expect(hobby.repeatMode, 'weekly');
      // expect(hobby.priority, 'high');
      expect(hobby.color, 0xFF6C3FFF);
    });

    test('should create from JSON with missing optional fields', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Hobby',
        'color': 0xFF6C3FFF,
      };

      final hobby = Hobby.fromJson(json);

      expect(hobby.id, 'test-id');
      expect(hobby.name, 'Test Hobby');
      expect(hobby.notes, '');
      expect(hobby.repeatMode, 'daily');
      // expect(hobby.priority, 'medium');
    });

    test('should create from JSON with completions', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Hobby',
        'color': 0xFF6C3FFF,
        'completions': {
          '2024-01-01': {
            'completed': true,
            'completedAt': '2024-01-01T00:00:00.000',
          },
        },
      };

      final hobby = Hobby.fromJson(json);

      expect(hobby.completions.length, 1);
      expect(hobby.completions['2024-01-01']?.completed, true);
    });

    test('should copy with new values', () {
      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
      );

      final copied = hobby.copyWith(
        name: 'New Name',
      );

      expect(copied.id, 'test-id');
      expect(copied.name, 'New Name');
      // expect(copied.priority, 'high');
      expect(copied.color, 0xFF6C3FFF);
    });

    test('should copy with all properties', () {
      final hobby = Hobby(
        id: 'test-id',
        name: 'Original',
        notes: 'Original notes',
        repeatMode: 'daily',
        color: 0xFF6C3FFF,
      );

      final copied = hobby.copyWith(
        name: 'New Name',
        notes: 'New notes',
        repeatMode: 'weekly',
        color: 0xFFFF6B35,
      );

      expect(copied.name, 'New Name');
      expect(copied.notes, 'New notes');
      expect(copied.repeatMode, 'weekly');
      // expect(copied.priority, 'high');
      expect(copied.color, 0xFFFF6B35);
    });

    test('should copy with completions', () {
      final completions = {
        '2024-01-01': HobbyCompletion(completed: true),
      };

      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
      );

      final copied = hobby.copyWith(completions: completions);

      expect(copied.completions.length, 1);
      expect(copied.completions['2024-01-01']?.completed, true);
    });

    test('should copy with createdAt', () {
      final hobby = Hobby(
        id: 'test-id',
        name: 'Test Hobby',
        color: 0xFF6C3FFF,
      );

      final date = DateTime(2024, 1, 1);
      final copied = hobby.copyWith(createdAt: date);

      expect(copied.createdAt, date);
    });
  });

  group('HobbyCompletion Tests', () {
    test('should create completion with values', () {
      final completion = HobbyCompletion(
        completed: true,
        completedAt: DateTime(2024, 1, 1),
      );

      expect(completion.completed, true);
      expect(completion.completedAt, DateTime(2024, 1, 1));
    });

    test('should create incomplete completion', () {
      final completion = HobbyCompletion(
        completed: false,
      );

      expect(completion.completed, false);
      expect(completion.completedAt, isNull);
    });

    test('should create completion without date', () {
      final completion = HobbyCompletion(
        completed: true,
      );

      expect(completion.completed, true);
      expect(completion.completedAt, isNull);
    });

    test('should convert to JSON correctly', () {
      final completion = HobbyCompletion(
        completed: true,
        completedAt: DateTime(2024, 1, 1),
      );

      final json = completion.toJson();

      expect(json['completed'], true);
      expect(json['completedAt'], isNotNull);
    });

    test('should convert to JSON without date', () {
      final completion = HobbyCompletion(
        completed: false,
      );

      final json = completion.toJson();

      expect(json['completed'], false);
      expect(json['completedAt'], isNull);
    });

    test('should create from JSON correctly', () {
      final json = {
        'completed': true,
        'completedAt': '2024-01-01T00:00:00.000',
      };

      final completion = HobbyCompletion.fromJson(json);

      expect(completion.completed, true);
      expect(completion.completedAt, isNotNull);
    });

    test('should create from JSON with missing date', () {
      final json = {
        'completed': false,
      };

      final completion = HobbyCompletion.fromJson(json);

      expect(completion.completed, false);
      expect(completion.completedAt, isNull);
    });

    test('should create from JSON with null date', () {
      final json = {
        'completed': true,
        'completedAt': null,
      };

      final completion = HobbyCompletion.fromJson(json);

      expect(completion.completed, true);
      expect(completion.completedAt, isNull);
    });
  });
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

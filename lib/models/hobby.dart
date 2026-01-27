import 'dart:convert';

class Hobby {
  final String id;
  final String name;
  final String notes;
  final String repeatMode; // daily, weekly, custom
  final String priority; // low, medium, high
  final int color;
  final Map<String, HobbyCompletion> completions; // date -> completion info

  Hobby({
    required this.id,
    required this.name,
    this.notes = '',
    this.repeatMode = 'daily',
    this.priority = 'medium',
    required this.color,
    Map<String, HobbyCompletion>? completions,
  }) : completions = completions ?? {};

  int get currentStreak {
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDate(date);
      if (completions[dateKey]?.completed == true) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'notes': notes,
        'repeatMode': repeatMode,
        'priority': priority,
        'color': color,
        'completions': completions.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory Hobby.fromJson(Map<String, dynamic> json) => Hobby(
        id: json['id'],
        name: json['name'],
        notes: json['notes'] ?? '',
        repeatMode: json['repeatMode'] ?? 'daily',
        priority: json['priority'] ?? 'medium',
        color: json['color'],
        completions: (json['completions'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, HobbyCompletion.fromJson(v)),
            ) ??
            {},
      );

  Hobby copyWith({
    String? name,
    String? notes,
    String? repeatMode,
    String? priority,
    int? color,
    Map<String, HobbyCompletion>? completions,
  }) =>
      Hobby(
        id: id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        repeatMode: repeatMode ?? this.repeatMode,
        priority: priority ?? this.priority,
        color: color ?? this.color,
        completions: completions ?? this.completions,
      );
}

class HobbyCompletion {
  final bool completed;
  final DateTime? completedAt;

  HobbyCompletion({
    required this.completed,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory HobbyCompletion.fromJson(Map<String, dynamic> json) =>
      HobbyCompletion(
        completed: json['completed'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}

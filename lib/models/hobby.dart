class Hobby {
  final String id;
  final String name;
  final String notes;
  final String repeatMode; // daily, weekly, custom
  final String priority; // low, medium, high
  final int color;
  final Map<String, HobbyCompletion> completions; // date -> completion info
  final DateTime? createdAt;

  Hobby({
    required this.id,
    required this.name,
    this.notes = '',
    this.repeatMode = 'daily',
    this.priority = 'medium',
    required this.color,
    Map<String, HobbyCompletion>? completions,
    this.createdAt,
  }) : completions = completions ?? {};

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if today has any completion (don't break streak for current day)
    final todayKey = _formatDate(today);
    bool todayStarted = completions[todayKey]?.completed == true;
    
    // Start from yesterday and count backwards
    for (int i = 1; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDate(date);
      if (completions[dateKey]?.completed == true) {
        streak++;
      } else {
        break;
      }
    }
    
    // Add today to streak if completed
    if (todayStarted) {
      streak++;
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
        'createdAt': createdAt?.toIso8601String(),
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
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );

  Hobby copyWith({
    String? name,
    String? notes,
    String? repeatMode,
    String? priority,
    int? color,
    Map<String, HobbyCompletion>? completions,
    DateTime? createdAt,
  }) =>
      Hobby(
        id: id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        repeatMode: repeatMode ?? this.repeatMode,
        priority: priority ?? this.priority,
        color: color ?? this.color,
        completions: completions ?? this.completions,
        createdAt: createdAt ?? this.createdAt,
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

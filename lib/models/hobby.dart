class Hobby {
  final String id;
  final String name;
  final String notes;
  final String repeatMode; // daily, weekly, custom
  final int color;
  final Map<String, HobbyCompletion> completions; // date -> completion info
  final DateTime? createdAt;
  final String? reminderTime; // Time in HH:mm format (e.g., "09:00")
  final int? customDay; // For weekly: 0-6 (Mon-Sun), For monthly: 1-31
  final int bestStreak; // Max historical streak (unbounded per FR-014)
  final bool isOneTime; // If true, task disappears after first completion

  Hobby({
    required this.id,
    required this.name,
    this.notes = '',
    this.repeatMode = 'daily',
    required this.color,
    Map<String, HobbyCompletion>? completions,
    this.createdAt,
    this.reminderTime,
    this.customDay,
    this.bestStreak = 0,
    this.isOneTime = false,
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

  /// Calculate the maximum historical streak from all completions
  int calculateBestStreakFromHistory() {
    if (completions.isEmpty) return 0;

    // Get all completed dates sorted chronologically
    final completedDates = completions.entries
        .where((e) => e.value.completed)
        .map((e) => e.key)
        .toList()
      ..sort();

    if (completedDates.isEmpty) return 0;

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < completedDates.length; i++) {
      final prevDateParts = completedDates[i - 1].split('-');
      final currDateParts = completedDates[i].split('-');

      final prevDate = DateTime(
        int.parse(prevDateParts[0]),
        int.parse(prevDateParts[1]),
        int.parse(prevDateParts[2]),
      );

      final currDate = DateTime(
        int.parse(currDateParts[0]),
        int.parse(currDateParts[1]),
        int.parse(currDateParts[2]),
      );

      final daysDiff = currDate.difference(prevDate).inDays;

      if (daysDiff == 1) {
        // Consecutive day
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'notes': notes,
        'repeatMode': repeatMode,
        'color': color,
        'completions': completions.map((k, v) => MapEntry(k, v.toJson())),
        'createdAt': createdAt?.toIso8601String(),
        'reminderTime': reminderTime,
        'bestStreak': bestStreak,
        'isOneTime': isOneTime,
      };

  factory Hobby.fromJson(Map<String, dynamic> json) => Hobby(
        id: json['id'],
        name: json['name'],
        notes: json['notes'] ?? '',
        repeatMode: json['repeatMode'] ?? 'daily',
        color: json['color'],
        completions: (json['completions'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, HobbyCompletion.fromJson(v)),
            ) ??
            {},
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        reminderTime: json['reminderTime'],
        bestStreak: json['bestStreak'] ?? 0,
        isOneTime: json['isOneTime'] as bool? ?? false,
      );

  Hobby copyWith({
    String? name,
    String? notes,
    String? repeatMode,
    int? color,
    Map<String, HobbyCompletion>? completions,
    DateTime? createdAt,
    String? reminderTime,
    int? customDay,
    int? bestStreak,
    bool? isOneTime,
  }) =>
      Hobby(
        id: id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        repeatMode: repeatMode ?? this.repeatMode,
        color: color ?? this.color,
        completions: completions ?? this.completions,
        createdAt: createdAt ?? this.createdAt,
        reminderTime: reminderTime ?? this.reminderTime,
        customDay: customDay ?? this.customDay,
        bestStreak: bestStreak ?? this.bestStreak,
        isOneTime: isOneTime ?? this.isOneTime,
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

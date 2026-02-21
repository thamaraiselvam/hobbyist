/// Task model for the Task Management feature.
///
/// Tasks are one-off items (not recurring habits) with a title,
/// optional description, optional due date, and a priority level.
/// They are stored locally in the SQLite database.
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearDueDate = false,
    bool clearCompletedAt = false,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    priority: priority ?? this.priority,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'due_date': dueDate?.millisecondsSinceEpoch,
    'priority': priority.name,
    'is_completed': isCompleted ? 1 : 0,
    'created_at': createdAt.millisecondsSinceEpoch,
    'completed_at': completedAt?.millisecondsSinceEpoch,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: (map['description'] as String?) ?? '',
    dueDate: map['due_date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
        : null,
    priority: TaskPriority.fromString((map['priority'] as String?) ?? 'medium'),
    isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    completedAt: map['completed_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
        : null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  int get colorValue {
    switch (this) {
      case TaskPriority.low:
        return 0xFF10B981; // Green
      case TaskPriority.medium:
        return 0xFFF59E0B; // Amber
      case TaskPriority.high:
        return 0xFFEF4444; // Red
    }
  }
}

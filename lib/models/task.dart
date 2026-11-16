/// Task model — the core data unit of TaskForge.
///
/// Designed to be flexible: supports priorities, categories,
/// subtasks (via parentId), due dates, and notes.
class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int priority; // 0 = low, 1 = medium, 2 = high, 3 = urgent
  final String category; // e.g. "Work", "Personal", "Health", "Study"
  final String? parentId; // for subtasks
  final int sortOrder;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.priority = 1,
    this.category = 'General',
    this.parentId,
    this.sortOrder = 0,
  });

  /// Create a Task from a SQLite row map.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      priority: map['priority'] as int? ?? 1,
      category: map['category'] as String? ?? 'General',
      parentId: map['parent_id'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  /// Convert to a map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'priority': priority,
      'category': category,
      'parent_id': parentId,
      'sort_order': sortOrder,
    };
  }

  /// Immutable copy with updated fields.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? priority,
    String? category,
    String? parentId,
    int? sortOrder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      priority: priority ?? this.priority,
      category: category ?? this.category,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Human-readable priority label.
  String get priorityLabel {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      case 3:
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  /// Whether this task is overdue.
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}

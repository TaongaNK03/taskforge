import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/models/task.dart';
import 'package:taskforge/models/user_profile.dart';

void main() {
  group('Task Model Tests', () {
    test('Task creation and map conversion', () {
      final now = DateTime.now();
      final task = Task(
        id: 'test-1',
        title: 'Complete Flutter architecture',
        description: 'SQLite integration and full CRUD',
        priority: 3,
        category: 'Work',
        createdAt: now,
      );

      expect(task.id, 'test-1');
      expect(task.title, 'Complete Flutter architecture');
      expect(task.priorityLabel, 'Urgent');
      expect(task.isCompleted, isFalse);

      final map = task.toMap();
      final restored = Task.fromMap(map);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.priority, 3);
      expect(restored.category, 'Work');
    });

    test('Task completion copyWith', () {
      final task = Task(
        id: 'test-2',
        title: 'Buy groceries',
        createdAt: DateTime.now(),
      );

      final completed = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completed.isCompleted, isTrue);
      expect(completed.completedAt, isNotNull);
    });
  });

  group('UserProfile Model Tests', () {
    test('UserProfile creation and map conversion', () {
      final profile = UserProfile(
        id: 'user-1',
        name: 'Alex Developer',
        email: 'alex@example.com',
        dailyGoal: 7,
        createdAt: DateTime.now(),
      );

      expect(profile.name, 'Alex Developer');
      expect(profile.dailyGoal, 7);

      final map = profile.toMap();
      final restored = UserProfile.fromMap(map);

      expect(restored.name, profile.name);
      expect(restored.email, profile.email);
      expect(restored.dailyGoal, 7);
    });
  });
}


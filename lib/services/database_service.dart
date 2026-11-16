import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/task.dart';
import '../models/user_profile.dart';
import 'fallback_store_stub.dart'
    if (dart.library.html) 'fallback_store_web.dart' as fallback_store;

/// DatabaseService — single point of access for all SQLite operations.
///
/// Uses the singleton pattern so only one DB connection exists.
/// Schema is versioned for easy migrations as the app grows.
/// Uses browser local storage on web and an in-memory fallback if native
/// SQLite cannot be initialized.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;
  bool _isFallback = false;
  final List<Task> _fallbackTasks = [];
  UserProfile? _fallbackProfile;

  final List<Map<String, dynamic>> _fallbackCategories = [
    {
      'id': 'cat_general',
      'name': 'General',
      'color': 0xFF64748B,
      'icon_code': 0xe156,
      'sort_order': 0
    },
    {
      'id': 'cat_work',
      'name': 'Work',
      'color': 0xFF2563EB,
      'icon_code': 0xe943,
      'sort_order': 1
    },
    {
      'id': 'cat_personal',
      'name': 'Personal',
      'color': 0xFF7C3AED,
      'icon_code': 0xe491,
      'sort_order': 2
    },
    {
      'id': 'cat_health',
      'name': 'Health',
      'color': 0xFF059669,
      'icon_code': 0xe3e0,
      'sort_order': 3
    },
    {
      'id': 'cat_study',
      'name': 'Study',
      'color': 0xFFF59E0B,
      'icon_code': 0xe865,
      'sort_order': 4
    },
  ];

  bool _fallbackLoaded = false;

  Future<void> _loadFallbackData() async {
    if (_fallbackLoaded) return;
    _fallbackLoaded = true;
    final stored = fallback_store.read();
    if (stored == null || stored.isEmpty) return;
    try {
      final data = jsonDecode(stored) as Map<String, dynamic>;
      _fallbackTasks
        ..clear()
        ..addAll((data['tasks'] as List<dynamic>? ?? const [])
            .map((row) => Task.fromMap(Map<String, dynamic>.from(row as Map))));
      final profile = data['profile'];
      if (profile is Map) {
        _fallbackProfile =
            UserProfile.fromMap(Map<String, dynamic>.from(profile));
      }
    } catch (error) {
      debugPrint(
          'DatabaseService: stored browser data could not be read ($error).');
    }
  }

  Future<void> _persistFallbackData() async {
    await fallback_store.write(jsonEncode({
      'tasks': _fallbackTasks.map((task) => task.toMap()).toList(),
      'profile': _fallbackProfile?.toMap(),
    }));
  }

  /// Get (or create) the database instance.
  Future<Database?> get database async {
    if (kIsWeb || _isFallback) {
      if (!_isFallback) {
        _isFallback = true;
      }
      await _loadFallbackData();
      return null;
    }
    if (_db != null) return _db;
    try {
      _db = await _initDB();
      return _db;
    } catch (e) {
      debugPrint(
          'DatabaseService: native SQLite init skipped ($e). Using in-memory fallback.');
      _isFallback = true;
      await _loadFallbackData();
      return null;
    }
  }

  Future<Database> _initDB() async {
    final String path;
    if (kIsWeb) {
      path = inMemoryDatabasePath;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      path = p.join(dir.path, 'taskforge.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates all tables on first launch.
  Future<void> _onCreate(Database db, int version) async {
    // Tasks table — flexible schema with indexes for fast queries
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        due_date INTEGER,
        completed_at INTEGER,
        priority INTEGER NOT NULL DEFAULT 1,
        category TEXT NOT NULL DEFAULT 'General',
        parent_id TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

    // Indexes for fast sorting and filtering
    await db.execute('CREATE INDEX idx_tasks_completed ON tasks(is_completed)');
    await db.execute('CREATE INDEX idx_tasks_category ON tasks(category)');
    await db.execute('CREATE INDEX idx_tasks_priority ON tasks(priority)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks(created_at)');

    // User profile table
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        avatar_url TEXT,
        created_at INTEGER NOT NULL,
        daily_goal INTEGER NOT NULL DEFAULT 5,
        preferred_start_time TEXT DEFAULT '08:00',
        preferred_end_time TEXT DEFAULT '17:00',
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        theme_mode TEXT NOT NULL DEFAULT 'system'
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color INTEGER NOT NULL,
        icon_code INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Seed default categories
    for (final cat in _fallbackCategories) {
      await db.insert('categories', cat);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ─── TASK OPERATIONS ───────────────────────────────────────────────

  Future<void> insertTask(Task task) async {
    final db = await database;
    if (db == null) {
      _fallbackTasks.removeWhere((t) => t.id == task.id);
      _fallbackTasks.insert(0, task);
      await _persistFallbackData();
      return;
    }
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    if (db == null) {
      final index = _fallbackTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _fallbackTasks[index] = task;
      } else {
        _fallbackTasks.add(task);
      }
      await _persistFallbackData();
      return;
    }
    await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    if (db == null) {
      _fallbackTasks.removeWhere((t) => t.id == id || t.parentId == id);
      await _persistFallbackData();
      return;
    }
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    if (db == null) {
      final list =
          List<Task>.from(_fallbackTasks.where((t) => t.parentId == null));
      list.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });
      return list;
    }
    final maps = await db.query(
      'tasks',
      where: 'parent_id IS NULL',
      orderBy: 'is_completed ASC, sort_order ASC, created_at DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getTodayTasks() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59)
        .millisecondsSinceEpoch;

    if (db == null) {
      final list = _fallbackTasks.where((t) {
        if (t.parentId != null) return false;
        if (t.dueDate != null) {
          final ms = t.dueDate!.millisecondsSinceEpoch;
          return ms >= startOfDay && ms <= endOfDay;
        }
        final created = t.createdAt.millisecondsSinceEpoch;
        return created >= startOfDay && created <= endOfDay;
      }).toList();
      list.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return b.priority.compareTo(a.priority);
      });
      return list;
    }

    final maps = await db.query(
      'tasks',
      where:
          'parent_id IS NULL AND ((due_date >= ? AND due_date <= ?) OR (due_date IS NULL AND created_at >= ? AND created_at <= ?))',
      whereArgs: [startOfDay, endOfDay, startOfDay, endOfDay],
      orderBy: 'is_completed ASC, priority DESC, sort_order ASC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await database;
    if (db == null) {
      return _fallbackTasks
          .where((t) => t.category == category && t.parentId == null)
          .toList();
    }
    final maps = await db.query(
      'tasks',
      where: 'category = ? AND parent_id IS NULL',
      whereArgs: [category],
      orderBy: 'is_completed ASC, priority DESC, created_at DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getTasksByPriority(int priority) async {
    final db = await database;
    if (db == null) {
      return _fallbackTasks
          .where((t) => t.priority == priority && t.parentId == null)
          .toList();
    }
    final maps = await db.query(
      'tasks',
      where: 'priority = ? AND parent_id IS NULL',
      whereArgs: [priority],
      orderBy: 'is_completed ASC, created_at DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getSubtasks(String parentId) async {
    final db = await database;
    if (db == null) {
      return _fallbackTasks.where((t) => t.parentId == parentId).toList();
    }
    final maps = await db.query('tasks',
        where: 'parent_id = ?',
        whereArgs: [parentId],
        orderBy: 'sort_order ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<Task> toggleTaskCompletion(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
      clearCompletedAt: task.isCompleted,
    );
    await updateTask(updated);
    return updated;
  }

  Future<List<Task>> searchTasks(String query) async {
    final db = await database;
    if (db == null) {
      final q = query.toLowerCase();
      return _fallbackTasks.where((t) {
        if (t.parentId != null) return false;
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchDesc = t.description?.toLowerCase().contains(q) ?? false;
        return matchTitle || matchDesc;
      }).toList();
    }
    final maps = await db.query(
      'tasks',
      where: 'parent_id IS NULL AND (title LIKE ? OR description LIKE ?)',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  // ─── ANALYTICS / STATS QUERIES ─────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCompletionStats(int days) async {
    final db = await database;
    final results = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final now = DateTime.now();
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final start = day.millisecondsSinceEpoch;
      final end = day
          .add(const Duration(hours: 23, minutes: 59, seconds: 59))
          .millisecondsSinceEpoch;

      if (db == null) {
        final total = _fallbackTasks.where((t) {
          final c = t.createdAt.millisecondsSinceEpoch;
          return c >= start && c <= end;
        }).length;
        final completed = _fallbackTasks.where((t) {
          if (t.completedAt == null) return false;
          final c = t.completedAt!.millisecondsSinceEpoch;
          return c >= start && c <= end;
        }).length;

        results.add({'date': day, 'total': total, 'completed': completed});
      } else {
        final total = Sqflite.firstIntValue(
              await db.rawQuery(
                  'SELECT COUNT(*) FROM tasks WHERE created_at >= ? AND created_at <= ?',
                  [start, end]),
            ) ??
            0;

        final completed = Sqflite.firstIntValue(
              await db.rawQuery(
                  'SELECT COUNT(*) FROM tasks WHERE completed_at >= ? AND completed_at <= ?',
                  [
                    start,
                    end,
                  ]),
            ) ??
            0;

        results.add({'date': day, 'total': total, 'completed': completed});
      }
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getTaskCountByCategory() async {
    final db = await database;
    if (db == null) {
      final map = <String, Map<String, dynamic>>{};
      for (final t in _fallbackTasks.where((x) => x.parentId == null)) {
        map.putIfAbsent(t.category,
            () => {'category': t.category, 'total': 0, 'completed': 0});
        map[t.category]!['total'] = (map[t.category]!['total'] as int) + 1;
        if (t.isCompleted) {
          map[t.category]!['completed'] =
              (map[t.category]!['completed'] as int) + 1;
        }
      }
      return map.values.toList();
    }
    return await db.rawQuery('''
      SELECT category, 
             COUNT(*) as total,
             SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed
      FROM tasks
      WHERE parent_id IS NULL
      GROUP BY category
      ORDER BY total DESC
    ''');
  }

  Future<Map<String, int>> getOverallStats() async {
    final db = await database;
    if (db == null) {
      final topTasks = _fallbackTasks.where((t) => t.parentId == null).toList();
      final total = topTasks.length;
      final completed = topTasks.where((t) => t.isCompleted).length;
      final now = DateTime.now();
      final overdue = topTasks
          .where((t) =>
              !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now))
          .length;

      return {
        'total': total,
        'completed': completed,
        'pending': total - completed,
        'overdue': overdue,
      };
    }
    final total = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COUNT(*) FROM tasks WHERE parent_id IS NULL')) ??
        0;
    final completed = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM tasks WHERE is_completed = 1 AND parent_id IS NULL'),
        ) ??
        0;
    final overdue = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM tasks WHERE is_completed = 0 AND due_date IS NOT NULL AND due_date < ? AND parent_id IS NULL',
            [DateTime.now().millisecondsSinceEpoch],
          ),
        ) ??
        0;

    return {
      'total': total,
      'completed': completed,
      'pending': total - completed,
      'overdue': overdue,
    };
  }

  Future<double> getTodayProductivity() async {
    final tasks = await getTodayTasks();
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return (completed / tasks.length) * 100;
  }

  Future<int> getCompletionStreak() async {
    final db = await database;
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final start = day.millisecondsSinceEpoch;
      final end = day
          .add(const Duration(hours: 23, minutes: 59, seconds: 59))
          .millisecondsSinceEpoch;

      final int count;
      if (db == null) {
        count = _fallbackTasks.where((t) {
          if (t.completedAt == null) return false;
          final ms = t.completedAt!.millisecondsSinceEpoch;
          return ms >= start && ms <= end;
        }).length;
      } else {
        count = Sqflite.firstIntValue(
              await db.rawQuery(
                  'SELECT COUNT(*) FROM tasks WHERE completed_at >= ? AND completed_at <= ?',
                  [
                    start,
                    end,
                  ]),
            ) ??
            0;
      }

      if (count > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // ─── CATEGORY OPERATIONS ───────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    if (db == null) return _fallbackCategories;
    return await db.query('categories', orderBy: 'sort_order ASC');
  }

  // ─── USER PROFILE OPERATIONS ───────────────────────────────────────

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    if (db == null) return _fallbackProfile;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    if (db == null) {
      _fallbackProfile = profile;
      await _persistFallbackData();
      return;
    }
    await db.insert('user_profile', profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}

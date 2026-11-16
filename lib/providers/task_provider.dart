import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

/// TaskProvider — central state management for the entire app.
///
/// Wraps all database operations and notifies the UI when data changes.
/// Every screen reads from this provider instead of querying the DB directly.
class TaskProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  // ─── State ─────────────────────────────────────────────────────────
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  List<Map<String, dynamic>> _categories = [];
  UserProfile? _userProfile;
  Map<String, int> _overallStats = {};
  double _todayProductivity = 0;
  int _streak = 0;
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _sortBy = 'date'; // 'date', 'priority', 'name'
  String _filterStatus = 'all'; // 'all', 'pending', 'completed'

  // ─── Getters ───────────────────────────────────────────────────────
  List<Task> get allTasks => _allTasks;
  List<Task> get todayTasks => _todayTasks;
  List<Map<String, dynamic>> get categories => _categories;
  UserProfile? get userProfile => _userProfile;
  Map<String, int> get overallStats => _overallStats;
  double get todayProductivity => _todayProductivity;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  String get filterStatus => _filterStatus;

  /// Filtered and sorted view of all tasks.
  List<Task> get filteredTasks {
    var tasks = List<Task>.from(_allTasks);

    // Filter by category
    if (_selectedCategory != 'All') {
      tasks = tasks.where((t) => t.category == _selectedCategory).toList();
    }

    // Filter by completion status
    if (_filterStatus == 'pending') {
      tasks = tasks.where((t) => !t.isCompleted).toList();
    } else if (_filterStatus == 'completed') {
      tasks = tasks.where((t) => t.isCompleted).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'priority':
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return b.priority.compareTo(a.priority);
        });
        break;
      case 'name':
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
      case 'due':
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      default: // 'date'
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return b.createdAt.compareTo(a.createdAt);
        });
    }

    return tasks;
  }

  // ─── Initialization ────────────────────────────────────────────────

  /// Load all data from the database. Call this once at app startup.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadProfile();
    await _loadCategories();
    await refreshTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    _userProfile = await _db.getUserProfile();
    if (_userProfile == null) {
      // Create a default profile on first launch
      _userProfile = UserProfile(
        id: _uuid.v4(),
        name: 'User',
        createdAt: DateTime.now(),
      );
      await _db.saveUserProfile(_userProfile!);
    }
  }

  Future<void> _loadCategories() async {
    _categories = await _db.getCategories();
  }

  /// Refresh task lists and stats from the database.
  Future<void> refreshTasks() async {
    _allTasks = await _db.getAllTasks();
    _todayTasks = await _db.getTodayTasks();
    _overallStats = await _db.getOverallStats();
    _todayProductivity = await _db.getTodayProductivity();
    _streak = await _db.getCompletionStreak();
    notifyListeners();
  }

  // ─── Task CRUD ─────────────────────────────────────────────────────

  /// Add a new task.
  Future<void> addTask({
    required String title,
    String? description,
    int priority = 1,
    String category = 'General',
    DateTime? dueDate,
    String? parentId,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      parentId: parentId,
      createdAt: DateTime.now(),
      sortOrder: _allTasks.length,
    );
    await _db.insertTask(task);
    await refreshTasks();
  }

  /// Update an existing task.
  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
    await refreshTasks();
  }

  /// Delete a task.
  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    await refreshTasks();
  }

  /// Toggle task completion.
  Future<void> toggleTaskCompletion(Task task) async {
    await _db.toggleTaskCompletion(task);
    await refreshTasks();
  }

  /// Search tasks.
  Future<List<Task>> searchTasks(String query) async {
    if (query.isEmpty) return _allTasks;
    return await _db.searchTasks(query);
  }

  // ─── Filters & Sorting ─────────────────────────────────────────────

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // ─── User Profile ──────────────────────────────────────────────────

  Future<void> updateProfile(UserProfile profile) async {
    await _db.saveUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  // ─── Analytics ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    return await _db.getCompletionStats(7);
  }

  Future<List<Map<String, dynamic>>> getMonthlyStats() async {
    return await _db.getCompletionStats(30);
  }

  Future<List<Map<String, dynamic>>> getCategoryStats() async {
    return await _db.getTaskCountByCategory();
  }

  // ─── AI Insights (rule-based for now, expandable to real AI) ───────

  /// Generate productivity insights based on task data.
  List<Map<String, dynamic>> generateInsights() {
    final insights = <Map<String, dynamic>>[];
    final stats = _overallStats;
    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final overdue = stats['overdue'] ?? 0;

    // Completion rate insight
    if (total > 0) {
      final rate = (completed / total * 100).round();
      if (rate >= 80) {
        insights.add({
          'icon': Icons.emoji_events,
          'color': const Color(0xFF059669),
          'title': 'Outstanding Performance!',
          'message':
              'You\'ve completed $rate% of your tasks. You\'re on fire! Keep up the excellent work.',
        });
      } else if (rate >= 50) {
        insights.add({
          'icon': Icons.trending_up,
          'color': const Color(0xFF2563EB),
          'title': 'Good Progress',
          'message':
              'You\'ve completed $rate% of your tasks. Try breaking larger tasks into smaller ones to boost your completion rate.',
        });
      } else {
        insights.add({
          'icon': Icons.lightbulb_outline,
          'color': const Color(0xFFF59E0B),
          'title': 'Room for Improvement',
          'message':
              'Your completion rate is $rate%. Consider prioritizing 2-3 tasks each day rather than taking on too many at once.',
        });
      }
    }

    // Overdue tasks
    if (overdue > 0) {
      insights.add({
        'icon': Icons.warning_amber,
        'color': const Color(0xFFEF4444),
        'title': 'Overdue Alert',
        'message':
            'You have $overdue overdue task${overdue > 1 ? 's' : ''}. Consider rescheduling or breaking them into smaller steps.',
      });
    }

    // Streak insight
    if (_streak >= 3) {
      insights.add({
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFF97316),
        'title': '$_streak Day Streak! 🔥',
        'message':
            'You\'ve been productive for $_streak days in a row. Consistency is the key to success!',
      });
    }

    // Pending tasks
    if (pending > 5) {
      insights.add({
        'icon': Icons.psychology,
        'color': const Color(0xFF7C3AED),
        'title': 'Focus Suggestion',
        'message':
            'You have $pending pending tasks. Try using the Eisenhower Matrix: focus on urgent + important tasks first.',
      });
    }

    // Category distribution
    final categoryCount = <String, int>{};
    for (final task in _allTasks) {
      categoryCount[task.category] =
          (categoryCount[task.category] ?? 0) + 1;
    }
    if (categoryCount.isNotEmpty) {
      final topCategory =
          categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add({
        'icon': Icons.pie_chart,
        'color': const Color(0xFF2563EB),
        'title': 'Focus Area: ${topCategory.key}',
        'message':
            'Most of your tasks (${topCategory.value}) are in ${topCategory.key}. Make sure to balance other areas too.',
      });
    }

    // Productivity timing
    if (_todayProductivity > 0) {
      insights.add({
        'icon': Icons.schedule,
        'color': const Color(0xFF06B6D4),
        'title': 'Peak Productivity Window',
        'message':
            'You\'re most productive between 8:00 AM and 11:00 AM. Schedule your most challenging tasks during this window.',
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.rocket_launch,
        'color': const Color(0xFF2563EB),
        'title': 'Get Started!',
        'message':
            'Add your first tasks and start building your productivity habits. Every journey starts with a single step!',
      });
    }

    return insights;
  }
}

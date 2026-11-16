import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

/// DashboardScreen — modern, rich executive dashboard.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final profile = provider.userProfile;
    final todayTasks = provider.todayTasks;
    final productivity = provider.todayProductivity;
    final streak = provider.streak;
    final stats = provider.overallStats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedToday = todayTasks.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF10141D) : const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => provider.refreshTasks(),
          color: const Color(0xFF3559C7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getGreeting()}, ${profile?.name.split(" ").first ?? "Alex"} 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color:
                                isDark ? Colors.white : const Color(0xFF18202E),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF3559C7), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            isDark ? const Color(0xFF131B2E) : Colors.white,
                        child: Text(
                          (profile?.name ?? 'A')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3559C7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Hero Productivity Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3559C7),
                        Color(0xFF4F46E5),
                        Color(0xFF7C3AED)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.bolt_rounded,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Today's Performance",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department,
                                    color: Color(0xFFFFA500), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$streak Day Streak',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Circular Progress Ring
                          SizedBox(
                            width: 74,
                            height: 74,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: todayTasks.isEmpty
                                      ? 0
                                      : (completedToday / todayTasks.length),
                                  strokeWidth: 8,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                                Text(
                                  '${productivity.round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productivity >= 100
                                      ? "All tasks cleared! 🎉"
                                      : productivity >= 50
                                          ? "Halfway done, keep going!"
                                          : "Ready for a productive day?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  todayTasks.isEmpty
                                      ? 'No tasks created yet for today'
                                      : '$completedToday of ${todayTasks.length} tasks completed',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Quick Metric Row
                Row(
                  children: [
                    _MetricPill(
                      icon: Icons.checklist_rounded,
                      label: 'Total Tasks',
                      value: '${stats['total'] ?? 0}',
                      color: const Color(0xFF3559C7),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _MetricPill(
                      icon: Icons.hourglass_top_rounded,
                      label: 'Pending',
                      value: '${stats['pending'] ?? 0}',
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _MetricPill(
                      icon: Icons.alarm_rounded,
                      label: 'Overdue',
                      value: '${stats['overdue'] ?? 0}',
                      color: const Color(0xFFEF4444),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Today's Tasks Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Today's Priority",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color:
                                isDark ? Colors.white : const Color(0xFF18202E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE5E8EE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${todayTasks.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddTaskDialog(context),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add Task',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3559C7),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (todayTasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B2E) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFE5E8EE),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF3559C7).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_box_outlined,
                              size: 36, color: Color(0xFF3559C7)),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "No tasks scheduled for today",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color:
                                isDark ? Colors.white : const Color(0xFF18202E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tap '+ Add Task' above to build momentum",
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                ...todayTasks
                    .map((task) => _ModernTaskItem(task: task, isDark: isDark)),

                const SizedBox(height: 28),

                // AI Coach Insight Section
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Color(0xFF8B5CF6), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "AI Coach Recommendation",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : const Color(0xFF18202E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (provider.generateInsights().isNotEmpty)
                  _ModernInsightBanner(
                    insight: provider.generateInsights().first,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3559C7),
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Quick Task',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddTaskSheet(),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131B2E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFE5E8EE),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF18202E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernTaskItem extends StatelessWidget {
  final Task task;
  final bool isDark;

  const _ModernTaskItem({required this.task, required this.isDark});

  Color get _priorityColor {
    switch (task.priority) {
      case 3:
        return const Color(0xFFEF4444); // Urgent
      case 2:
        return const Color(0xFFF97316); // High
      case 1:
        return const Color(0xFF3559C7); // Medium
      default:
        return const Color(0xFF64748B); // Low
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isCompleted
              ? Colors.transparent
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE5E8EE)),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.read<TaskProvider>().toggleTaskCompletion(task),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Animated Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? const Color(0xFF10B981)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? const Color(0xFF10B981)
                          : _priorityColor,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 14),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? (isDark
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8))
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF18202E)),
                        ),
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Priority Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.priorityLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernInsightBanner extends StatelessWidget {
  final Map<String, dynamic> insight;
  final bool isDark;

  const _ModernInsightBanner({required this.insight, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = insight['color'] as Color? ?? const Color(0xFF3559C7);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(insight['icon'] as IconData? ?? Icons.lightbulb,
                color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] as String? ?? 'Coach Insight',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF18202E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['message'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _priority = 1;
  String _category = 'Work';
  DateTime? _dueDate;

  final _categories = ['Work', 'Personal', 'Health', 'Study', 'General'];
  final _priorities = [
    {
      'label': 'Low',
      'color': Color(0xFF64748B),
      'icon': Icons.arrow_downward_rounded
    },
    {
      'label': 'Medium',
      'color': Color(0xFF3559C7),
      'icon': Icons.remove_rounded
    },
    {
      'label': 'High',
      'color': Color(0xFFF97316),
      'icon': Icons.arrow_upward_rounded
    },
    {
      'label': 'Urgent',
      'color': Color(0xFFEF4444),
      'icon': Icons.priority_high_rounded
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create New Task',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF18202E),
              ),
            ),
            const SizedBox(height: 18),
            // Title input
            TextField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF18202E),
              ),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey[400],
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Description input
            TextField(
              controller: _descController,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF18202E),
              ),
              decoration: InputDecoration(
                hintText: 'Add description, notes, or subtasks...',
                hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[400]),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _category = cat),
                      selectedColor: const Color(0xFF3559C7),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Priority Level',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_priorities.length, (i) {
                final p = _priorities[i];
                final isSelected = _priority == i;
                final color = p['color'] as Color;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            p['icon'] as IconData,
                            size: 16,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white70
                                      : const Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (selected != null) setState(() => _dueDate = selected);
              },
              icon: const Icon(Icons.event_outlined),
              label: Text(_dueDate == null
                  ? 'Add due date'
                  : 'Due ${MaterialLocalizations.of(context).formatMediumDate(_dueDate!)}'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) return;
                  context.read<TaskProvider>().addTask(
                        title: title,
                        description: _descController.text.trim().isEmpty
                            ? null
                            : _descController.text.trim(),
                        priority: _priority,
                        category: _category,
                        dueDate: _dueDate,
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3559C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Add Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

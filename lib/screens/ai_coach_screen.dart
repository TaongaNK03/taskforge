import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

/// AI Coach Screen — displays smart productivity insights and tips.
///
/// Currently uses rule-based insights from the TaskProvider.
/// Architecture is ready for a real AI backend when needed.
class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = provider.generateInsights();
    final stats = provider.overallStats;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A1040), const Color(0xFF090D16)]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // AI Avatar + greeting
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Coach',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.25),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your personal productivity assistant',
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Frosted stat pills
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            _GlassStat(
                              emoji: '🎯',
                              value: stats['total'] != null &&
                                      stats['total']! > 0
                                  ? '${((stats['completed'] ?? 0) / stats['total']! * 100).round()}%'
                                  : '0%',
                              label: 'Rate',
                            ),
                            _statDivider(),
                            _GlassStat(
                              emoji: '✅',
                              value: '${stats['completed'] ?? 0}',
                              label: 'Done',
                            ),
                            _statDivider(),
                            _GlassStat(
                              emoji: '🔥',
                              value: '${provider.streak}',
                              label: 'Streak',
                            ),
                            _statDivider(),
                            _GlassStat(
                              emoji: '⏳',
                              value: '${stats['pending'] ?? 0}',
                              label: 'Pending',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section: Insights ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6)
                          .withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.lightbulb_outline,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Insights & Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color:
                          isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (insights.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.psychology_outlined,
                        size: 40,
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    Text(
                      'Add some tasks to unlock insights',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Insights list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ModernInsightCard(
                  insight: insights[index],
                  isDark: isDark,
                  index: index,
                ),
                childCount: insights.length,
              ),
            ),
          ),

          // ── Section: Productivity Tips ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6)
                          .withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school_outlined,
                        size: 20,
                        color: isDark
                            ? const Color(0xFFA78BFA)
                            : const Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Productivity Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color:
                          isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tips = _getProductivityTips();
                  return _ModernTipCard(
                    tip: tips[index],
                    isDark: isDark,
                    index: index,
                  );
                },
                childCount: _getProductivityTips().length,
              ),
            ),
          ),

          // Bottom safe area
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  List<Map<String, dynamic>> _getProductivityTips() {
    return [
      {
        'icon': Icons.timer_outlined,
        'title': 'Pomodoro Technique',
        'description':
            'Work in focused 25-minute intervals with 5-minute breaks. After 4 intervals, take a longer 15-30 minute break.',
        'gradient': [const Color(0xFFEF4444), const Color(0xFFF97316)],
      },
      {
        'icon': Icons.grid_view_rounded,
        'title': 'Eisenhower Matrix',
        'description':
            'Categorize tasks by urgency and importance: Do urgent+important first, schedule important ones, delegate urgent ones, eliminate the rest.',
        'gradient': [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
      },
      {
        'icon': Icons.flash_on_rounded,
        'title': 'Two-Minute Rule',
        'description':
            'If a task takes less than two minutes, do it immediately instead of adding it to your list. This prevents small tasks from piling up.',
        'gradient': [const Color(0xFF059669), const Color(0xFF10B981)],
      },
      {
        'icon': Icons.nightlight_round,
        'title': 'Evening Planning',
        'description':
            'Plan tomorrow\'s top 3 priorities the night before. This reduces morning decision fatigue and gives you a clear starting point.',
        'gradient': [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      },
      {
        'icon': Icons.layers_rounded,
        'title': 'Task Batching',
        'description':
            'Group similar tasks together and tackle them in one session. Switching between different types of work costs mental energy.',
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      },
    ];
  }
}

// ─── Widgets ───────────────────────────────────────────────────────

class _GlassStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _GlassStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernInsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  final bool isDark;
  final int index;

  const _ModernInsightCard({
    required this.insight,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final color = insight['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF1F5F9),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          // Accent gradient bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.4)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    size: 22,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insight['message'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
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

class _ModernTipCard extends StatelessWidget {
  final Map<String, dynamic> tip;
  final bool isDark;
  final int index;

  const _ModernTipCard({
    required this.tip,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = tip['gradient'] as List<Color>;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF1F5F9),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                tip['icon'] as IconData,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color:
                          isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip['description'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

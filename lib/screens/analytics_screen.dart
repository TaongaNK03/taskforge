import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';

/// Analytics Screen — visual productivity dashboard with charts and stats.
///
/// Shows weekly completion trends, category breakdown, and overall metrics.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _weeklyStats = [];
  List<Map<String, dynamic>> _categoryStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final provider = context.read<TaskProvider>();
    final weekly = await provider.getWeeklyStats();
    final categories = await provider.getCategoryStats();
    setState(() {
      _weeklyStats = weekly;
      _categoryStats = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = provider.overallStats;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF10141D) : const Color(0xFFF5F6F8),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF3559C7)),
                      backgroundColor: const Color(0xFF3559C7)
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading analytics...',
                    style: TextStyle(
                      color:
                          isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: const Color(0xFF3559C7),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // ── Hero header ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF0D2137),
                                  const Color(0xFF10141D)
                                ]
                              : [
                                  const Color(0xFF0EA5E9),
                                  const Color(0xFF3559C7)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF0EA5E9),
                                          Color(0xFF3559C7)
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0EA5E9)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                        Icons.insights_rounded,
                                        color: Colors.white,
                                        size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Analytics',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Track your productivity',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _isLoading = true);
                                  _loadStats();
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Metric pills row
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _HeaderMetric(
                                      label: 'Total',
                                      value: '${stats['total'] ?? 0}',
                                      color: const Color(0xFF60A5FA),
                                    ),
                                    _metricDivider(),
                                    _HeaderMetric(
                                      label: 'Done',
                                      value:
                                          '${stats['completed'] ?? 0}',
                                      color: const Color(0xFF34D399),
                                    ),
                                    _metricDivider(),
                                    _HeaderMetric(
                                      label: 'Pending',
                                      value: '${stats['pending'] ?? 0}',
                                      color: const Color(0xFFFBBF24),
                                    ),
                                    _metricDivider(),
                                    _HeaderMetric(
                                      label: 'Overdue',
                                      value: '${stats['overdue'] ?? 0}',
                                      color: const Color(0xFFF87171),
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

                  // ── Weekly Trend section ──────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3559C7)
                                      .withValues(
                                          alpha: isDark ? 0.15 : 0.1),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.show_chart_rounded,
                                    size: 20,
                                    color: isDark
                                        ? const Color(0xFF60A5FA)
                                        : const Color(0xFF3559C7)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weekly Trend',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF18202E),
                                    ),
                                  ),
                                  Text(
                                    'Tasks completed over last 7 days',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white38
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Chart card
                          Container(
                            height: 220,
                            padding: const EdgeInsets.fromLTRB(
                                12, 20, 16, 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white
                                      .withValues(alpha: 0.04)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white
                                        .withValues(alpha: 0.06)
                                    : const Color(0xFFF1F5F9),
                              ),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            child: _weeklyStats.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                            Icons
                                                .bar_chart_rounded,
                                            size: 36,
                                            color: isDark
                                                ? Colors.white24
                                                : const Color(
                                                    0xFFCBD5E1)),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No data yet — complete some tasks!',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white38
                                                : const Color(
                                                    0xFF94A3B8),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : BarChart(
                                    BarChartData(
                                      alignment:
                                          BarChartAlignment.spaceAround,
                                      maxY: _getMaxY(),
                                      barTouchData: BarTouchData(
                                        touchTooltipData:
                                            BarTouchTooltipData(
                                          getTooltipItem: (group,
                                              groupIndex,
                                              rod,
                                              rodIndex) {
                                            return BarTooltipItem(
                                              '${rod.toY.toInt()} tasks',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget:
                                                (value, meta) {
                                              if (value.toInt() <
                                                  _weeklyStats.length) {
                                                final date =
                                                    _weeklyStats[value
                                                                .toInt()]
                                                            ['date']
                                                        as DateTime;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets
                                                          .only(top: 8),
                                                  child: Text(
                                                    DateFormat('E')
                                                        .format(date)
                                                        .substring(0, 2),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isDark
                                                          ? Colors
                                                              .white38
                                                          : const Color(
                                                              0xFF94A3B8),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false),
                                        ),
                                      ),
                                      gridData: const FlGridData(
                                          show: false),
                                      borderData:
                                          FlBorderData(show: false),
                                      barGroups: _weeklyStats
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final completed =
                                            (entry.value['completed']
                                                    as int)
                                                .toDouble();
                                        final total =
                                            (entry.value['total']
                                                    as int)
                                                .toDouble();
                                        return BarChartGroupData(
                                          x: entry.key,
                                          barRods: [
                                            BarChartRodData(
                                              toY: total > 0
                                                  ? total
                                                  : 0,
                                              color: isDark
                                                  ? Colors.white
                                                      .withValues(
                                                          alpha: 0.08)
                                                  : const Color(
                                                      0xFFE5E8EE),
                                              width: 18,
                                              borderRadius:
                                                  const BorderRadius
                                                      .vertical(
                                                      top: Radius
                                                          .circular(
                                                              8)),
                                            ),
                                            BarChartRodData(
                                              toY: completed,
                                              gradient:
                                                  const LinearGradient(
                                                colors: [
                                                  Color(0xFF3559C7),
                                                  Color(0xFF6366F1),
                                                ],
                                                begin: Alignment
                                                    .bottomCenter,
                                                end: Alignment
                                                    .topCenter,
                                              ),
                                              width: 18,
                                              borderRadius:
                                                  const BorderRadius
                                                      .vertical(
                                                      top: Radius
                                                          .circular(
                                                              8)),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Category Breakdown ────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(
                                      alpha: isDark ? 0.15 : 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.donut_small_rounded,
                                size: 20,
                                color: isDark
                                    ? const Color(0xFFA78BFA)
                                    : const Color(0xFF7C3AED)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'By Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF18202E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_categoryStats.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white
                                  .withValues(alpha: 0.04)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white
                                    .withValues(alpha: 0.06)
                                : const Color(0xFFF1F5F9),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.pie_chart_outline_rounded,
                                size: 36,
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFFCBD5E1)),
                            const SizedBox(height: 8),
                            Text(
                              'Add tasks to see category breakdown',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cat = _categoryStats[index];
                          return _ModernCategoryRow(
                            category: cat,
                            isDark: isDark,
                          );
                        },
                        childCount: _categoryStats.length,
                      ),
                    ),
                  ),

                  // ── Streak Card ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Text('🔥',
                                  style: TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${provider.streak} Day Streak',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.streak > 0
                                      ? 'Keep going! Don\'t break the chain.'
                                      : 'Complete a task to start your streak!',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom safe area
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _metricDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  double _getMaxY() {
    double max = 1;
    for (final stat in _weeklyStats) {
      final total = (stat['total'] as int).toDouble();
      if (total > max) max = total;
    }
    return max + 1;
  }
}

// ─── Widgets ───────────────────────────────────────────────────────

class _HeaderMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
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

class _ModernCategoryRow extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isDark;

  const _ModernCategoryRow({
    required this.category,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = category['total'] as int;
    final completed = category['completed'] as int;
    final percentage = total > 0 ? (completed / total * 100).round() : 0;
    final catColors = {
      'Work': const Color(0xFF3559C7),
      'Personal': const Color(0xFF8B5CF6),
      'Health': const Color(0xFF10B981),
      'Study': const Color(0xFFF59E0B),
      'General': const Color(0xFF64748B),
    };
    final color =
        catColors[category['category'] as String] ?? const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF1F5F9),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category['category'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF18202E),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$completed of $total completed',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

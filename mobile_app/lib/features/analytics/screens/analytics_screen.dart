import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:mobile_app/features/analytics/domain/analytics_models.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';

class AnalyticsScreen extends HookConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(analyticsProvider.notifier).loadAnalytics();
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Study Analytics',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: analyticsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : analyticsState.error != null
              ? _buildErrorState(context, ref, analyticsState.error!)
              : analyticsState.data == null
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: () => ref.read(analyticsProvider.notifier).refresh(),
                      child: _buildContent(context, analyticsState.data!),
                    ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text('Failed to load analytics', style: GoogleFonts.poppins(fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.read(analyticsProvider.notifier).loadAnalytics(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.barChart3, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No study data yet',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start studying to see your analytics',
            style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnalyticsData data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Card
          _buildStreakCard(context, data.streaks),
          const SizedBox(height: 16),

          // Summary Stats
          _buildSummaryGrid(context, data.summary),
          const SizedBox(height: 24),

          // Weekly Chart
          Text(
            'This Week',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildWeeklyChart(context, data.dailyData),
          const SizedBox(height: 24),

          // Subject Breakdown
          if (data.subjectData.isNotEmpty) ...[
            Text(
              'Time by Subject',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSubjectChart(context, data.subjectData),
            const SizedBox(height: 16),
            _buildSubjectList(context, data.subjectData),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, StreakData streaks) {
    return ModernCard(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
        ],
      ),
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.flame, color: Colors.orange, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${streaks.currentStreak} Day Streak',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Best: ${streaks.longestStreak} days',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.trophy, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Keep going!',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, StudySummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: LucideIcons.clock,
            label: 'Today',
            value: _formatMinutes(summary.totalMinutesToday),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: LucideIcons.calendar,
            label: 'This Week',
            value: _formatMinutes(summary.totalMinutesThisWeek),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: LucideIcons.trendingUp,
            label: 'Sessions',
            value: '${summary.totalSessions}',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<DailyStudyData> dailyData) {
    final maxMinutes = dailyData.isEmpty
        ? 60.0
        : dailyData.map((d) => d.minutes.toDouble()).reduce((a, b) => a > b ? a : b).clamp(60.0, double.infinity);

    return ModernCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxMinutes * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Theme.of(context).colorScheme.surfaceContainerHighest,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final data = dailyData[groupIndex];
                  return BarTooltipItem(
                    '${data.minutes} min',
                    GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= dailyData.length) return const SizedBox();
                    final date = DateTime.parse(dailyData[value.toInt()].date);
                    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[date.weekday - 1],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: dailyData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.minutes.toDouble(),
                    width: 24,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectChart(BuildContext context, List<SubjectStudyData> subjectData) {
    final total = subjectData.fold<int>(0, (sum, s) => sum + s.totalMinutes);
    if (total == 0) return const SizedBox();

    return ModernCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 50,
            sections: subjectData.map((subject) {
              final percentage = (subject.totalMinutes / total * 100);
              return PieChartSectionData(
                value: subject.totalMinutes.toDouble(),
                title: percentage >= 10 ? '${percentage.toStringAsFixed(0)}%' : '',
                color: _parseColor(subject.subjectColor),
                radius: 40,
                titleStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectList(BuildContext context, List<SubjectStudyData> subjectData) {
    return Column(
      children: subjectData.map((subject) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _parseColor(subject.subjectColor),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                _formatMinutes(subject.totalMinutes),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}

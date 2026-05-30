import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/analytics_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_states.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final analyticsAsync = ref.watch(analyticsDataProvider);
    final selectedMonth = ref.watch(analyticsMonthProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final currency = user?.preferredCurrency ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Categories'),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
        ),
        actions: [
          PopupMenuButton<DateTime>(
            icon: const Icon(Icons.calendar_month_rounded),
            onSelected: (v) => ref.read(analyticsMonthProvider.notifier).state = v,
            itemBuilder: (_) => DateFormatter.getLast12Months().reversed.map((m) =>
              PopupMenuItem(
                value: m,
                child: Text(DateFormatter.toMonthShort(m)),
              ),
            ).toList(),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (data) => TabBarView(
          controller: _tabs,
          children: [
            _OverviewTab(data: data, currency: currency, selectedMonth: selectedMonth),
            _TrendsTab(data: data, currency: currency),
            _CategoriesTab(data: data, currency: currency),
          ],
        ),
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final AnalyticsData data;
  final String currency;
  final DateTime selectedMonth;
  const _OverviewTab({required this.data, required this.currency, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final total = data.categoryBreakdown.fold(0.0, (s, c) => s + c.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormatter.toMonthYear(selectedMonth), style: tt.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))
            .animate().fadeIn(),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.format(total, currency), style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary))
            .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Pie Chart
          if (data.categoryBreakdown.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spending by Category', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: data.categoryBreakdown.take(6).map((cat) {
                          final catDef = AppConstants.categories.firstWhere((c) => c.id == cat.category, orElse: () => AppConstants.categories.last);
                          return PieChartSectionData(
                            value: cat.amount,
                            color: catDef.color,
                            title: '${(cat.percentage * 100).toInt()}%',
                            radius: 70,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12, runSpacing: 8,
                    children: data.categoryBreakdown.take(6).map((cat) {
                      final catDef = AppConstants.categories.firstWhere((c) => c.id == cat.category, orElse: () => AppConstants.categories.last);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: catDef.color, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(catDef.name, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
          ],

          // Stats Row
          Row(
            children: [
              Expanded(child: StatCard(
                title: 'Avg. Expense',
                value: CurrencyFormatter.format(data.average, currency),
                icon: Icons.analytics_rounded,
                color: AppColors.primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: StatCard(
                title: 'Largest',
                value: CurrencyFormatter.format(data.maxExpense, currency),
                icon: Icons.arrow_upward_rounded,
                color: AppColors.error,
              )),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),

          // Top Expenses
          if (data.topExpenses.isNotEmpty) ...[
            Text('Top Expenses', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 10),
            ...data.topExpenses.map((e) {
              final cat = AppConstants.categories.firstWhere((c) => c.id == e.category, orElse: () => AppConstants.categories.last);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(cat.icon, color: cat.color, size: 16)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.description, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(CurrencyFormatter.format(e.amount, e.currency), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Trends Tab ───────────────────────────────────────────────────────────────
class _TrendsTab extends StatelessWidget {
  final AnalyticsData data;
  final String currency;
  const _TrendsTab({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final monthlyMax = data.monthlyTrends.map((m) => m.total).fold(0.0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar Chart - Monthly
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Spending', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('Last 6 months', style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: monthlyMax > 0 ? monthlyMax * 1.2 : 100,
                      barGroups: data.monthlyTrends.asMap().entries.map((entry) =>
                        BarChartGroupData(
                          x: entry.key,
                          barRods: [BarChartRodData(
                            toY: entry.value.total,
                            gradient: AppColors.gradientPrimary,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          )],
                        ),
                      ).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= data.monthlyTrends.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(DateFormat('MMM').format(data.monthlyTrends[idx].month),
                                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                            );
                          },
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (v, _) => Text(
                            CurrencyFormatter.formatCompact(v, currency),
                            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                          ),
                        )),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant.withOpacity(0.5), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 16),

          // Line Chart - Weekly
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Evolution', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('Last 7 weeks', style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.weeklyTrends.asMap().entries.map((e) =>
                            FlSpot(e.key.toDouble(), e.value.total)).toList(),
                          isCurved: true,
                          gradient: AppColors.gradientPrimary,
                          barWidth: 3,
                          dotData: FlDotData(
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 4, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0)],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= data.weeklyTrends.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('W${idx + 1}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                            );
                          },
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true, reservedSize: 50,
                          getTitlesWidget: (v, _) => Text(CurrencyFormatter.formatCompact(v, currency),
                            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                        )),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant.withOpacity(0.5), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                    duration: const Duration(milliseconds: 800),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Categories Tab ───────────────────────────────────────────────────────────
class _CategoriesTab extends StatelessWidget {
  final AnalyticsData data;
  final String currency;
  const _CategoriesTab({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    if (data.categoryBreakdown.isEmpty) {
      return const EmptyState(title: 'No data yet', subtitle: 'Add expenses to see category analytics', icon: Icons.pie_chart_outline_rounded);
    }
    final total = data.categoryBreakdown.fold(0.0, (s, c) => s + c.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Category Ranking', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(),
        const SizedBox(height: 12),
        ...data.categoryBreakdown.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          final catDef = AppConstants.categories.firstWhere((c) => c.id == cat.category, orElse: () => AppConstants.categories.last);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: catDef.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: catDef.color))),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: catDef.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(catDef.icon, color: catDef.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(catDef.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: cat.percentage,
                          backgroundColor: catDef.color.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation(catDef.color),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.format(cat.amount, currency),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${(cat.percentage * 100).toInt()}% • ${cat.count} txn',
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 50 * i)).fadeIn().slideX(begin: 0.1, end: 0);
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}

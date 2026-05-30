import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CategoryData {
  final String category;
  final double amount;
  final double percentage;
  final int count;
  const CategoryData({required this.category, required this.amount, required this.percentage, required this.count});
}

class MonthlyData {
  final DateTime month;
  final double total;
  final Map<String, double> byCategory;
  const MonthlyData({required this.month, required this.total, required this.byCategory});
}

class WeeklyData {
  final DateTime weekStart;
  final double total;
  const WeeklyData({required this.weekStart, required this.total});
}

class AnalyticsData {
  final List<CategoryData> categoryBreakdown;
  final List<MonthlyData> monthlyTrends;
  final List<WeeklyData> weeklyTrends;
  final double average;
  final double maxExpense;
  final String mostExpensiveCategory;
  final List<ExpenseEntity> topExpenses;

  const AnalyticsData({
    required this.categoryBreakdown,
    required this.monthlyTrends,
    required this.weeklyTrends,
    required this.average,
    required this.maxExpense,
    required this.mostExpensiveCategory,
    required this.topExpenses,
  });
}

final analyticsMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final analyticsDataProvider = Provider<AsyncValue<AnalyticsData>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);
  final selectedMonth = ref.watch(analyticsMonthProvider);

  return expensesAsync.whenData((all) {
    // Filter to selected month
    final monthly = all.where((e) =>
      e.date.year == selectedMonth.year && e.date.month == selectedMonth.month
    ).toList();

    // Category breakdown
    final catTotals = <String, double>{};
    final catCounts = <String, int>{};
    for (final e in monthly) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
      catCounts[e.category] = (catCounts[e.category] ?? 0) + 1;
    }
    final totalAmount = catTotals.values.fold(0.0, (s, v) => s + v);
    final categoryBreakdown = catTotals.entries.map((entry) => CategoryData(
      category: entry.key,
      amount: entry.value,
      percentage: totalAmount > 0 ? entry.value / totalAmount : 0,
      count: catCounts[entry.key] ?? 0,
    )).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    // Monthly trends (last 6 months)
    final now = DateTime.now();
    final monthlyTrends = <MonthlyData>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final expenses = all.where((e) => e.date.year == month.year && e.date.month == month.month);
      final total = expenses.fold(0.0, (s, e) => s + e.amount);
      final byCategory = <String, double>{};
      for (final e in expenses) {
        byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
      }
      monthlyTrends.add(MonthlyData(month: month, total: total, byCategory: byCategory));
    }

    // Weekly trends (last 7 weeks)
    final weeklyTrends = <WeeklyData>[];
    for (int i = 6; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final total = all
        .where((e) => !e.date.isBefore(weekStart) && !e.date.isAfter(weekEnd))
        .fold(0.0, (s, e) => s + e.amount);
      weeklyTrends.add(WeeklyData(weekStart: weekStart, total: total));
    }

    final allAmounts = all.map((e) => e.amount);
    final avg = allAmounts.isNotEmpty ? allAmounts.fold(0.0, (s, a) => s + a) / allAmounts.length : 0.0;
    final maxExp = allAmounts.isNotEmpty ? allAmounts.reduce((a, b) => a > b ? a : b) : 0.0;
    final topCat = categoryBreakdown.isNotEmpty ? categoryBreakdown.first.category : '';
    final topExpenses = List<ExpenseEntity>.from(all)..sort((a, b) => b.amount.compareTo(a.amount));

    return AnalyticsData(
      categoryBreakdown: categoryBreakdown,
      monthlyTrends: monthlyTrends,
      weeklyTrends: weeklyTrends,
      average: avg,
      maxExpense: maxExp,
      mostExpensiveCategory: topCat,
      topExpenses: topExpenses.take(5).toList(),
    );
  });
});

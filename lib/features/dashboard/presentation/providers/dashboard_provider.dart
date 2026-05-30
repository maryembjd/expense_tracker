import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../../core/utils/date_formatter.dart';

class DashboardSummary {
  final double totalThisMonth;
  final double totalLastMonth;
  final int transactionCount;
  final String topCategory;
  final double? budgetUsage;
  final List<ExpenseEntity> recentExpenses;

  const DashboardSummary({
    required this.totalThisMonth,
    required this.totalLastMonth,
    required this.transactionCount,
    required this.topCategory,
    this.budgetUsage,
    required this.recentExpenses,
  });

  double get monthOverMonthChange => totalLastMonth > 0
    ? ((totalThisMonth - totalLastMonth) / totalLastMonth) * 100
    : 0;

  bool get isSpendingUp => totalThisMonth > totalLastMonth;
}

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);
  final budgetStatusAsync = ref.watch(budgetStatusProvider);

  return expensesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (expenses) {
      final now = DateTime.now();
      final thisMonth = expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
      final lastMonth = expenses.where((e) {
        final lm = DateTime(now.year, now.month - 1);
        return e.date.year == lm.year && e.date.month == lm.month;
      }).toList();

      final totalThisMonth = thisMonth.fold(0.0, (s, e) => s + e.amount);
      final totalLastMonth = lastMonth.fold(0.0, (s, e) => s + e.amount);

      // Top category by spending
      final catTotals = <String, double>{};
      for (final e in thisMonth) { catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount; }
      final topCategory = catTotals.isEmpty ? '' :
        catTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final budgetUsage = budgetStatusAsync.whenData((s) => s?.percentage).value;

      return AsyncValue.data(DashboardSummary(
        totalThisMonth: totalThisMonth,
        totalLastMonth: totalLastMonth,
        transactionCount: thisMonth.length,
        topCategory: topCategory,
        budgetUsage: budgetUsage,
        recentExpenses: expenses.take(5).toList(),
      ));
    },
  );
});

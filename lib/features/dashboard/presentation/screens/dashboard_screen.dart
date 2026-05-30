import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/dashboard_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../budget/presentation/widgets/budget_progress_widget.dart';
import '../../../expenses/presentation/widgets/expense_card.dart';
import '../../../../core/widgets/loading_states.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final budgetStatusAsync = ref.watch(budgetStatusProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async { ref.invalidate(expensesStreamProvider); },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                decoration: BoxDecoration(gradient: AppColors.gradientPrimary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good ${_greeting()},', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                            Text(
                              user?.displayName.split(' ').first ?? 'User',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                            child: user?.photoUrl == null ? Text(
                              user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                            ) : null,
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                    const SizedBox(height: 20),
                    summaryAsync.when(
                      loading: () => const ShimmerBox(width: double.infinity, height: 60),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (summary) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This Month\'s Spending', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(summary.totalThisMonth, user?.preferredCurrency ?? 'USD'),
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                summary.isSpendingUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                color: summary.isSpendingUp ? AppColors.error : AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${summary.monthOverMonthChange.abs().toStringAsFixed(1)}% vs last month',
                                style: TextStyle(
                                  color: summary.isSpendingUp ? Colors.red.shade200 : Colors.green.shade200,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats
                    summaryAsync.when(
                      loading: () => const ShimmerBox(width: double.infinity, height: 100, radius: 16),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (summary) => _QuickStatsRow(summary: summary, currency: user?.preferredCurrency ?? 'USD'),
                    ),
                    const SizedBox(height: 20),

                    // Budget Card
                    budgetStatusAsync.when(
                      loading: () => const ShimmerBox(width: double.infinity, height: 160, radius: 20),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (status) => status != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Budget Overview', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))
                                .animate().fadeIn(),
                              const SizedBox(height: 12),
                              BudgetProgressCard(
                                status: status,
                                onTap: () => context.go('/home/budget'),
                              ).animate().fadeIn(delay: 100.ms),
                              const SizedBox(height: 20),
                            ],
                          )
                        : _NoBudgetBanner(onTap: () => context.go('/home/budget')),
                    ),

                    // Quick Actions
                    Text('Quick Actions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))
                      .animate().fadeIn(),
                    const SizedBox(height: 12),
                    _QuickActionsRow().animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 20),

                    // Recent Transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Transactions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        TextButton(
                          onPressed: () => context.go('/home/expenses'),
                          child: const Text('See all'),
                        ),
                      ],
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),
                    summaryAsync.when(
                      loading: () => const ExpenseListShimmer(count: 3),
                      error: (e, _) => ErrorState(message: e.toString()),
                      data: (summary) => summary.recentExpenses.isEmpty
                        ? EmptyState(
                            title: 'No transactions yet',
                            subtitle: 'Start adding your expenses',
                            icon: Icons.receipt_long_rounded,
                            action: ElevatedButton.icon(
                              onPressed: () => context.push('/expense/add'),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Expense'),
                            ),
                          )
                        : Column(
                            children: summary.recentExpenses.asMap().entries.map((entry) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ExpenseCard(
                                  expense: entry.value,
                                  index: entry.key,
                                  onTap: () => context.push('/expense/detail', extra: entry.value),
                                ),
                              ),
                            ).toList(),
                          ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}


class _QuickStatsRow extends StatelessWidget {
  final DashboardSummary summary;
  final String currency;
  const _QuickStatsRow({required this.summary, required this.currency});

  @override
  Widget build(BuildContext context) {
    final cat = summary.topCategory.isNotEmpty
      ? AppConstants.categories.firstWhere((c) => c.id == summary.topCategory, orElse: () => AppConstants.categories.last)
      : null;

    return Row(
      children: [
        Expanded(child: StatCard(
          title: 'Transactions',
          value: '${summary.transactionCount}',
          subtitle: 'this month',
          icon: Icons.receipt_rounded,
          color: AppColors.primary,
          trend: summary.transactionCount > 0 ? '${summary.transactionCount}' : null,
          trendUp: false,
        )),
        const SizedBox(width: 12),
        Expanded(child: StatCard(
          title: 'Top Category',
          value: cat?.name ?? 'None',
          icon: cat?.icon ?? Icons.category_rounded,
          color: cat?.color ?? AppColors.primary,
        )),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickAction(icon: Icons.add_rounded, label: 'Add Expense', color: AppColors.primary, onTap: () => context.push('/expense/add'))),
        const SizedBox(width: 10),
        Expanded(child: _QuickAction(icon: Icons.bar_chart_rounded, label: 'Analytics', color: AppColors.secondary, onTap: () => context.go('/home/analytics'))),
        const SizedBox(width: 10),
        Expanded(child: _QuickAction(icon: Icons.account_balance_wallet_rounded, label: 'Budget', color: AppColors.warning, onTap: () => context.go('/home/budget'))),
        const SizedBox(width: 10),
        Expanded(child: _QuickAction(icon: Icons.share_rounded, label: 'Export', color: AppColors.accent, onTap: () => context.push('/export'))),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NoBudgetBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _NoBudgetBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Text('Set a monthly budget to track your spending', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

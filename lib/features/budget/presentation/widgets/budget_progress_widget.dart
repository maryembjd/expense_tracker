import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetStatus status;
  final VoidCallback? onTap;

  const BudgetProgressCard({super.key, required this.status, this.onTap});

  Color get _progressColor {
    if (status.isOver) return AppColors.error;
    if (status.isWarning) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pct = (status.percentage * 100).clamp(0, 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Budget', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(status.budget.totalBudget, status.budget.currency),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                CircularPercentIndicator(
                  radius: 36,
                  lineWidth: 6,
                  percent: status.percentage.clamp(0, 1).toDouble(),
                  center: Text('$pct%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  progressColor: status.isOver ? AppColors.error : Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1000,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: status.percentage.clamp(0, 1).toDouble(),
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: AlwaysStoppedAnimation(
                  status.isOver ? AppColors.error : (status.isWarning ? AppColors.warning : Colors.white),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BudgetStat(
                  label: 'Spent',
                  value: CurrencyFormatter.format(status.spent, status.budget.currency),
                  color: status.isOver ? AppColors.error : Colors.white,
                ),
                _BudgetStat(
                  label: 'Remaining',
                  value: CurrencyFormatter.format(status.remaining, status.budget.currency),
                  color: status.isOver ? Colors.white.withOpacity(0.6) : Colors.white,
                ),
                _BudgetStat(
                  label: 'Status',
                  value: status.isOver ? 'Over budget' : (status.isWarning ? 'Warning' : 'On track'),
                  color: status.isOver ? AppColors.error : (status.isWarning ? AppColors.warning : AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class CategoryBudgetTile extends StatelessWidget {
  final String categoryId;
  final double budget;
  final double spent;
  final String currency;

  const CategoryBudgetTile({
    super.key,
    required this.categoryId,
    required this.budget,
    required this.spent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final cat = AppConstants.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => AppConstants.categories.last,
    );
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(cat.icon, color: cat.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${CurrencyFormatter.format(spent, currency)} / ${CurrencyFormatter.format(budget, currency)}',
                      style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOver ? AppColors.error : cat.color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(pct * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isOver ? AppColors.error : cat.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: cat.color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(isOver ? AppColors.error : cat.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cat = AppConstants.categories.firstWhere(
      (c) => c.id == expense.category,
      orElse: () => AppConstants.categories.last,
    );
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete?.call(),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(cat.name, style: TextStyle(fontSize: 10, color: cat.color, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.toRelative(expense.date),
                            style: tt.bodySmall?.copyWith(fontSize: 11, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(expense.amount, expense.currency),
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: expense.amount > 500 ? AppColors.error : scheme.onSurface,
                      ),
                    ),
                    if (expense.isRecurring)
                      const Icon(Icons.repeat_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms),
    );
  }
}

class ExpenseListGrouped extends StatelessWidget {
  final List<ExpenseEntity> expenses;
  final void Function(ExpenseEntity)? onTap;
  final void Function(ExpenseEntity)? onDelete;

  const ExpenseListGrouped({super.key, required this.expenses, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ExpenseEntity>>{};
    for (final e in expenses) {
      final key = DateFormatter.toGroupHeader(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        int count = 0;
        for (final entry in grouped.entries) {
          if (i == count) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                  Text(
                    CurrencyFormatter.format(
                      entry.value.fold(0.0, (s, e) => s + e.amount),
                      entry.value.first.currency,
                    ),
                    style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            );
          }
          count++;
          for (int j = 0; j < entry.value.length; j++) {
            if (i == count) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExpenseCard(
                  expense: entry.value[j],
                  index: j,
                  onTap: onTap != null ? () => onTap!(entry.value[j]) : null,
                  onDelete: onDelete != null ? () => onDelete!(entry.value[j]) : null,
                ),
              );
            }
            count++;
          }
        }
        return null;
      }, childCount: grouped.entries.fold(0, (s, e) => s + 1 + e.value.length)),
    );
  }
}

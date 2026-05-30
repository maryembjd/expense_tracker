import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expense_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseEntity expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = AppConstants.categories.firstWhere(
      (c) => c.id == expense.category,
      orElse: () => AppConstants.categories.last,
    );
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Expense Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/expense/add', extra: expense),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Expense'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(expenseNotifierProvider.notifier).deleteExpense(expense.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cat.color, cat.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: cat.color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(16)),
                    child: Icon(cat.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expense.description, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(cat.name, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            const SizedBox(height: 20),

            // Amount
            _DetailSection(
              children: [
                _DetailRow(
                  icon: Icons.attach_money_rounded,
                  label: 'Amount',
                  value: CurrencyFormatter.formatFull(expense.amount, expense.currency),
                  valueStyle: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                _DetailRow(
                  icon: Icons.currency_exchange_rounded,
                  label: 'Currency',
                  value: '${expense.currency} — ${CurrencyFormatter.nameFor(expense.currency)}',
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),

            _DetailSection(
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: DateFormatter.toLong(expense.date),
                ),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Added',
                  value: DateFormatter.toDateTime(expense.createdAt),
                ),
                if (expense.updatedAt != null)
                  _DetailRow(
                    icon: Icons.edit_calendar_rounded,
                    label: 'Updated',
                    value: DateFormatter.toDateTime(expense.updatedAt!),
                  ),
              ],
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 12),

            if (expense.note != null) ...[
              _DetailSection(
                children: [
                  _DetailRow(icon: Icons.note_outlined, label: 'Note', value: expense.note!),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
            ],

            if (expense.isRecurring) ...[
              _DetailSection(
                children: [
                  _DetailRow(
                    icon: Icons.repeat_rounded,
                    label: 'Recurring',
                    value: expense.recurringFrequency ?? 'Yes',
                    valueColor: AppColors.primary,
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 12),
            ],

            if (expense.tags.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tags', style: tt.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: expense.tags.map((t) => Chip(
                        label: Text(t),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
                      )).toList(),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Edit Expense',
              icon: Icons.edit_rounded,
              onPressed: () => context.push('/expense/add', extra: expense),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final List<Widget> children;
  const _DetailSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: children.expand((w) => [w, if (w != children.last) Divider(height: 16, color: scheme.outlineVariant)]).toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? valueColor;

  const _DetailRow({required this.icon, required this.label, required this.value, this.valueStyle, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: valueStyle ?? tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: valueColor)),
            ],
          ),
        ),
      ],
    );
  }
}

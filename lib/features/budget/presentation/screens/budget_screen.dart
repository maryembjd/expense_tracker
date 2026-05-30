import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_progress_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_states.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetStatus = ref.watch(budgetStatusProvider);
    final currentBudget = ref.watch(currentBudgetProvider);
    final selectedMonth = ref.watch(selectedBudgetMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showBudgetDialog(context, ref, null),
          ),
        ],
      ),
      body: budgetStatus.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (status) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => ref.read(selectedBudgetMonthProvider.notifier).update(
                            (d) => DateTime(d.year, d.month - 1),
                          ),
                        ),
                        Text(
                          DateFormatter.toMonthYear(selectedMonth),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {
                            final next = DateTime(selectedMonth.year, selectedMonth.month + 1);
                            if (next.isBefore(DateTime.now()) || (next.year == DateTime.now().year && next.month == DateTime.now().month)) {
                              ref.read(selectedBudgetMonthProvider.notifier).state = next;
                            }
                          },
                        ),
                      ],
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),

                    if (status == null)
                      _NoBudgetCard(onSet: () => _showBudgetDialog(context, ref, null))
                    else ...[
                      BudgetProgressCard(
                        status: status,
                        onTap: () => _showBudgetDialog(context, ref, status),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 20),

                      if (status.isWarning || status.isOver)
                        _BudgetAlert(isOver: status.isOver).animate().fadeIn(delay: 150.ms),

                      if (status.budget.categoryBudgets.isNotEmpty) ...[
                        Text('Category Budgets',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))
                          .animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 12),
                        ...status.budget.categoryBudgets.entries.map((entry) =>
                          CategoryBudgetTile(
                            categoryId: entry.key,
                            budget: entry.value,
                            spent: status.categorySpent[entry.key] ?? 0,
                            currency: status.budget.currency,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      SecondaryButton(
                        label: 'Edit Budget',
                        icon: Icons.edit_rounded,
                        onPressed: () => _showBudgetDialog(context, ref, status),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, BudgetStatus? status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _BudgetSetupSheet(status: status),
      ),
    );
  }
}

class _BudgetSetupSheet extends ConsumerStatefulWidget {
  final BudgetStatus? status;
  const _BudgetSetupSheet({this.status});

  @override
  ConsumerState<_BudgetSetupSheet> createState() => _BudgetSetupSheetState();
}

class _BudgetSetupSheetState extends ConsumerState<_BudgetSetupSheet> {
  final _totalCtrl = TextEditingController();
  final _catCtrls = <String, TextEditingController>{};
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    if (widget.status != null) {
      _totalCtrl.text = widget.status!.budget.totalBudget.toString();
      _currency = widget.status!.budget.currency;
      for (final entry in widget.status!.budget.categoryBudgets.entries) {
        _catCtrls[entry.key] = TextEditingController(text: entry.value.toString());
      }
    }
    final user = ref.read(currentUserProvider);
    if (user != null && widget.status == null) _currency = user.preferredCurrency;
    for (final cat in AppConstants.categories) {
      _catCtrls.putIfAbsent(cat.id, () => TextEditingController());
    }
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    for (final c in _catCtrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetNotifierProvider);
    final selectedMonth = ref.watch(selectedBudgetMonthProvider);
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Set Budget', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          Text(DateFormatter.toMonthYear(selectedMonth), style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _totalCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            decoration: const InputDecoration(labelText: 'Total Monthly Budget', prefixIcon: Icon(Icons.account_balance_wallet_rounded)),
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: Text('Category Budgets (optional)', style: tt.titleSmall),
            children: AppConstants.categories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(cat.icon, color: cat.color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cat.name, style: tt.bodyMedium)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _catCtrls[cat.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '0.00', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Save Budget',
            isLoading: budgetState.isLoading,
            icon: Icons.save_rounded,
            onPressed: () async {
              final total = double.tryParse(_totalCtrl.text) ?? 0;
              final catBudgets = <String, double>{};
              for (final entry in _catCtrls.entries) {
                final v = double.tryParse(entry.value.text) ?? 0;
                if (v > 0) catBudgets[entry.key] = v;
              }
              final ok = await ref.read(budgetNotifierProvider.notifier).setBudget(
                totalBudget: total,
                currency: _currency,
                categoryBudgets: catBudgets,
                month: selectedMonth.month,
                year: selectedMonth.year,
                existingId: widget.status?.budget.id,
              );
              if (ok && context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NoBudgetCard extends StatelessWidget {
  final VoidCallback onSet;
  const _NoBudgetCard({required this.onSet});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('No Budget Set', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Set a monthly budget to track your spending', style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GradientButton(label: 'Set Budget', onPressed: onSet, icon: Icons.add_rounded),
        ],
      ),
    );
  }
}

class _BudgetAlert extends StatelessWidget {
  final bool isOver;
  const _BudgetAlert({required this.isOver});

  @override
  Widget build(BuildContext context) {
    final color = isOver ? AppColors.error : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(isOver ? Icons.error_rounded : Icons.warning_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOver ? 'You\'ve exceeded your monthly budget!' : 'You\'ve used 80% of your budget',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../../../../core/widgets/loading_states.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredExpensesProvider);
    final filter = ref.watch(expenseFilterProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            title: _showSearch
              ? SearchTextField(
                  controller: _searchCtrl,
                  hint: 'Search expenses...',
                  onChanged: (v) => ref.read(expenseFilterProvider.notifier).update(
                    (s) => s.copyWith(searchQuery: v),
                  ),
                  onClear: () => ref.read(expenseFilterProvider.notifier).update(
                    (s) => s.copyWith(searchQuery: ''),
                  ),
                )
              : const Text('Expenses'),
            actions: [
              IconButton(
                icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
                onPressed: () {
                  setState(() => _showSearch = !_showSearch);
                  if (!_showSearch) {
                    _searchCtrl.clear();
                    ref.read(expenseFilterProvider.notifier).update((s) => s.copyWith(searchQuery: ''));
                  }
                },
              ),
              IconButton(
                icon: Badge(
                  isLabelVisible: filter.hasActiveFilters,
                  child: const Icon(Icons.filter_list_rounded),
                ),
                onPressed: () => _showFilterSheet(context),
              ),
            ],
          ),
          filtered.when(
            loading: () => const SliverFillRemaining(child: ExpenseListShimmer()),
            error: (e, _) => SliverFillRemaining(child: ErrorState(message: e.toString())),
            data: (expenses) {
              if (expenses.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    title: filter.hasActiveFilters ? 'No results found' : 'No expenses yet',
                    subtitle: filter.hasActiveFilters
                      ? 'Try adjusting your filters'
                      : 'Start by adding your first expense',
                    icon: Icons.receipt_long_rounded,
                    action: filter.hasActiveFilters
                      ? TextButton.icon(
                          onPressed: () => ref.read(expenseFilterProvider.notifier).state = const ExpenseFilter(),
                          icon: const Icon(Icons.clear_rounded),
                          label: const Text('Clear filters'),
                        )
                      : null,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: ExpenseListGrouped(
                  expenses: expenses,
                  onTap: (e) => context.push('/expense/detail', extra: e),
                  onDelete: (e) => ref.read(expenseNotifierProvider.notifier).deleteExpense(e.id),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expense/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w600)),
      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => _FilterSheet(scrollController: scrollCtrl),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const _FilterSheet({required this.scrollController});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ExpenseFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(expenseFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    ref.read(expenseFilterProvider.notifier).state = const ExpenseFilter();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset all'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Text('Category', style: tt.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter.category == null,
                      onTap: () => setState(() => _filter = _filter.copyWith(clearCategory: true)),
                    ),
                    ...AppConstants.categories.map((cat) => _FilterChip(
                      label: cat.name,
                      selected: _filter.category == cat.id,
                      color: cat.color,
                      icon: cat.icon,
                      onTap: () => setState(() => _filter = _filter.copyWith(category: cat.id)),
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Sort By', style: tt.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _FilterChip(label: 'Date', selected: _filter.sortBy == 'date', onTap: () => setState(() => _filter = _filter.copyWith(sortBy: 'date'))),
                    _FilterChip(label: 'Amount', selected: _filter.sortBy == 'amount', onTap: () => setState(() => _filter = _filter.copyWith(sortBy: 'amount'))),
                    _FilterChip(label: 'Category', selected: _filter.sortBy == 'category', onTap: () => setState(() => _filter = _filter.copyWith(sortBy: 'category'))),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    ref.read(expenseFilterProvider.notifier).state = _filter;
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.15) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon!, size: 14, color: selected ? c : Theme.of(context).colorScheme.onSurfaceVariant), const SizedBox(width: 4)],
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? c : Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}

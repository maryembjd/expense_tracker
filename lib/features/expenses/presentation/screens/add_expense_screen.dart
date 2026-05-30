import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expense_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseEntity? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _category = 'other';
  String _currency = 'USD';
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  String _recurringFreq = 'monthly';

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.expense!;
      _amountCtrl.text = e.amount.toString();
      _descCtrl.text = e.description;
      _noteCtrl.text = e.note ?? '';
      _category = e.category;
      _currency = e.currency;
      _date = e.date;
      _isRecurring = e.isRecurring;
      _recurringFreq = e.recurringFrequency ?? 'monthly';
    } else {
      final user = ref.read(currentUserProvider);
      if (user != null) _currency = user.preferredCurrency;
    }
  }

  @override
  void dispose() { _amountCtrl.dispose(); _descCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final expense = ExpenseEntity(
      id: widget.expense?.id ?? const Uuid().v4(),
      userId: user.uid,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      currency: _currency,
      category: _category,
      description: _descCtrl.text.trim(),
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      isRecurring: _isRecurring,
      recurringFrequency: _isRecurring ? _recurringFreq : null,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
    );

    final notifier = ref.read(expenseNotifierProvider.notifier);
    final ok = _isEditing ? await notifier.updateExpense(expense) : await notifier.addExpense(expense);
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final expState = ref.watch(expenseNotifierProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    ref.listen(expenseNotifierProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AppColors.error));
        ref.read(expenseNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: () async {
                final ok = await ref.read(expenseNotifierProvider.notifier).deleteExpense(widget.expense!.id);
                if (ok && mounted) context.pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount + Currency
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Amount',
                      hint: '0.00',
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.amount,
                      prefixIcon: Icons.attach_money_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CurrencyDropdown(
                    value: _currency,
                    onChanged: (v) => setState(() => _currency = v),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                label: 'Description',
                hint: 'What did you spend on?',
                controller: _descCtrl,
                prefixIcon: Icons.description_outlined,
                validator: (v) => Validators.required(v, 'Description'),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 16),

              // Category
              Text('Category', style: tt.labelMedium?.copyWith(color: scheme.onSurfaceVariant))
                .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              _CategoryGrid(
                selected: _category,
                onSelected: (v) => setState(() => _category = v),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 16),

              // Date
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 20, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: tt.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, size: 20, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),

              // Note
              AppTextField(
                label: 'Note (optional)',
                hint: 'Add a note...',
                controller: _noteCtrl,
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 16),

              // Recurring
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.repeat_rounded, size: 20, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text('Recurring expense', style: tt.bodyMedium),
                          ],
                        ),
                        Switch(value: _isRecurring, onChanged: (v) => setState(() => _isRecurring = v)),
                      ],
                    ),
                    if (_isRecurring) ...[
                      const Divider(height: 16),
                      DropdownButtonFormField<String>(
                        value: _recurringFreq,
                        decoration: const InputDecoration(labelText: 'Frequency', border: InputBorder.none, contentPadding: EdgeInsets.zero),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                        ],
                        onChanged: (v) => setState(() => _recurringFreq = v ?? 'monthly'),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 28),

              GradientButton(
                label: _isEditing ? 'Update Expense' : 'Add Expense',
                onPressed: expState.isLoading ? null : _submit,
                isLoading: expState.isLoading,
                icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final String selected;
  final void Function(String) onSelected;
  const _CategoryGrid({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.categories.map((cat) {
        final isSelected = cat.id == selected;
        return GestureDetector(
          onTap: () => onSelected(cat.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? cat.color.withOpacity(0.15) : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? cat.color : Colors.transparent, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, color: isSelected ? cat.color : Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
                const SizedBox(width: 6),
                Text(cat.name, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isSelected ? cat.color : Theme.of(context).colorScheme.onSurface,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  const _CurrencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: AppConstants.currencies.map((c) =>
            DropdownMenuItem(value: c['code']!, child: Text(c['code']!, style: const TextStyle(fontWeight: FontWeight.w600)))
          ).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

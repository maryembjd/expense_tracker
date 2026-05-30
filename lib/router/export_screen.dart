import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/services/export_service.dart';
import '../features/expenses/presentation/providers/expense_provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/utils/date_formatter.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();
  String _format = 'pdf';
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Report'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date Range', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _DateTile(label: 'From', date: _from, onTap: () => _pickDate(isFrom: true))),
                const SizedBox(width: 12),
                Expanded(child: _DateTile(label: 'To', date: _to, onTap: () => _pickDate(isFrom: false))),
              ],
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            Text('Format', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 12),
            Row(
              children: [
                _FormatCard(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'PDF',
                  subtitle: 'Formatted report',
                  format: 'pdf',
                  selected: _format == 'pdf',
                  color: AppColors.error,
                  onTap: () => setState(() => _format = 'pdf'),
                ),
                const SizedBox(width: 12),
                _FormatCard(
                  icon: Icons.table_chart_rounded,
                  label: 'CSV',
                  subtitle: 'Spreadsheet data',
                  format: 'csv',
                  selected: _format == 'csv',
                  color: AppColors.success,
                  onTap: () => setState(() => _format = 'csv'),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),

            GradientButton(
              label: _exporting ? 'Exporting...' : 'Export & Share',
              isLoading: _exporting,
              icon: Icons.share_rounded,
              onPressed: _exporting ? null : _export,
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() { if (isFrom) _from = picked; else _to = picked; });
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    final expensesAsync = ref.read(filteredExpensesProvider);
    final user = ref.read(currentUserProvider);
    expensesAsync.whenData((expenses) async {
      final filtered = expenses.where((e) =>
        !e.date.isBefore(_from) && !e.date.isAfter(_to)
      ).toList();
      try {
        if (_format == 'pdf') {
          await ExportService.exportPdf(expenses: filtered, from: _from, to: _to, userName: user?.displayName ?? 'User', currency: user?.preferredCurrency ?? 'USD');
        } else {
          await ExportService.exportCsv(expenses: filtered, from: _from, to: _to);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export successful!'), backgroundColor: AppColors.success));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error));
        }
      }
    });
    setState(() => _exporting = false);
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(DateFormatter.toMedium(date), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String format;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FormatCard({required this.icon, required this.label, required this.subtitle, required this.format, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : Colors.transparent, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

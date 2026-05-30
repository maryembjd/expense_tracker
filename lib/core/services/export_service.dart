import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import '../../features/expenses/domain/entities/expense_entity.dart';
import '../constants/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class ExportService {
  static Future<void> exportPdf({
    required List<ExpenseEntity> expenses,
    required DateTime from,
    required DateTime to,
    required String userName,
    required String currency,
  }) async {
    final pdf = pw.Document();
    final total = expenses.fold(0.0, (s, e) => s + e.amount);

    // Group by category
    final catTotals = <String, double>{};
    for (final e in expenses) { catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount; }

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context ctx) => [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#6C63FF'),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text(userName, style: const pw.TextStyle(fontSize: 14, color: PdfColors.white)),
            pw.Text('${DateFormatter.toMedium(from)} — ${DateFormatter.toMedium(to)}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.white)),
          ]),
        ),
        pw.SizedBox(height: 20),

        // Summary
        pw.Row(children: [
          pw.Expanded(child: _pdfStatBox('Total Spent', CurrencyFormatter.formatFull(total, currency))),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _pdfStatBox('Transactions', '${expenses.length}')),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _pdfStatBox('Avg. per day', CurrencyFormatter.format(total / (to.difference(from).inDays + 1), currency))),
        ]),
        pw.SizedBox(height: 20),

        // Category breakdown
        pw.Text('Spending by Category', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
          columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(2), 2: const pw.FlexColumnWidth(2)},
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F0F1FA')),
              children: ['Category', 'Amount', '% of Total'].map((h) => pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              )).toList(),
            ),
            ...catTotals.entries.map((e) {
              final cat = AppConstants.categories.firstWhere((c) => c.id == e.key, orElse: () => AppConstants.categories.last);
              return pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(cat.name, style: const pw.TextStyle(fontSize: 11))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(CurrencyFormatter.formatFull(e.value, currency), style: const pw.TextStyle(fontSize: 11))),
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${(total > 0 ? (e.value / total * 100) : 0).toStringAsFixed(1)}%', style: const pw.TextStyle(fontSize: 11))),
              ]);
            }),
          ],
        ),
        pw.SizedBox(height: 20),

        // Transaction List
        pw.Text('Transactions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
          columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(2), 2: const pw.FlexColumnWidth(2), 3: const pw.FlexColumnWidth(2)},
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F0F1FA')),
              children: ['Description', 'Category', 'Date', 'Amount'].map((h) => pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              )).toList(),
            ),
            ...expenses.map((e) {
              final cat = AppConstants.categories.firstWhere((c) => c.id == e.category, orElse: () => AppConstants.categories.last);
              return pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e.description, style: const pw.TextStyle(fontSize: 10))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(cat.name, style: const pw.TextStyle(fontSize: 10))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(DateFormatter.toShort(e.date), style: const pw.TextStyle(fontSize: 10))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(CurrencyFormatter.formatFull(e.amount, e.currency), style: const pw.TextStyle(fontSize: 10))),
              ]);
            }),
          ],
        ),
      ],
    ));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expense_report_${DateFormatter.toIso(from)}_${DateFormatter.toIso(to)}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], subject: 'Expense Report');
  }

  static pw.Widget _pdfStatBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E8EAF6')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ]),
    );
  }

  static Future<void> exportCsv({
    required List<ExpenseEntity> expenses,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = [
      ['Date', 'Description', 'Category', 'Amount', 'Currency', 'Note'],
      ...expenses.map((e) {
        final cat = AppConstants.categories.firstWhere((c) => c.id == e.category, orElse: () => AppConstants.categories.last);
        return [
          DateFormatter.toIso(e.date),
          e.description,
          cat.name,
          e.amount.toStringAsFixed(2),
          e.currency,
          e.note ?? '',
        ];
      }),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expenses_${DateFormatter.toIso(from)}_${DateFormatter.toIso(to)}.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], subject: 'Expenses CSV');
  }
}

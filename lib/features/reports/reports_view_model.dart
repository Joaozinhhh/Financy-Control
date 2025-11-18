import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/locator.dart';
import 'package:financy_control/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CategoryTotal {
  final TransactionCategory category;
  final double total;
  final int count;
  final double percentage;

  CategoryTotal({
    required this.category,
    required this.total,
    required this.count,
    required this.percentage,
  });
}

class ReportsViewModel extends ChangeNotifier {
  final TransactionRepository _repository = locator<TransactionRepository>();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isGeneratingPdf = false;
  String? _errorMessage;
  String? _pdfSavedMessage;
  DateTime? _startDate;
  DateTime? _endDate;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isGeneratingPdf => _isGeneratingPdf;
  String? get errorMessage => _errorMessage;
  String? get pdfSavedMessage => _pdfSavedMessage;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  String get dateRangeText {
    if (_startDate == null || _endDate == null) return 'All Time';
    final start = DateFormat.yMMMd().format(_startDate!);
    final end = DateFormat.yMMMd().format(_endDate!);
    return '$start - $end';
  }

  // Statistics
  double get totalIncome {
    return _transactions.where((t) => t.category.income).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions.where((t) => t.category.expense).fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  double get netBalance => totalIncome - totalExpense;

  List<CategoryTotal> get incomeCategories {
    final Map<TransactionCategory, List<TransactionModel>> grouped = {};

    for (final transaction in _transactions.where((t) => t.category.income)) {
      grouped.putIfAbsent(transaction.category, () => []).add(transaction);
    }

    return grouped.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      final percentage = totalIncome > 0 ? (total / totalIncome * 100) : 0.0;
      return CategoryTotal(
        category: entry.key,
        total: total,
        count: entry.value.length,
        percentage: percentage,
      );
    }).toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  List<CategoryTotal> get expenseCategories {
    final Map<TransactionCategory, List<TransactionModel>> grouped = {};

    for (final transaction in _transactions.where((t) => t.category.expense)) {
      grouped.putIfAbsent(transaction.category, () => []).add(transaction);
    }

    return grouped.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, t) => sum + t.amount.abs());
      final percentage = totalExpense > 0 ? (total / totalExpense * 100) : 0.0;
      return CategoryTotal(
        category: entry.key,
        total: total,
        count: entry.value.length,
        percentage: percentage,
      );
    }).toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    rebuild();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    rebuild();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      final result = await _repository.getTransactions(
        startDate: _startDate,
        endDate: _endDate,
      );
      result.fold(
        (error) => _errorMessage = error.message,
        (data) => _transactions = data,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      rebuild();
    }
  }

  Future<void> generateAndSharePdf() async {
    _isGeneratingPdf = true;
    _errorMessage = null;
    rebuild();

    try {
      final pdf = await _generatePdfDocument();
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'financial_report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      _errorMessage = 'Failed to generate PDF: $e';
    } finally {
      _isGeneratingPdf = false;
      rebuild();
    }
  }

  Future<void> printPdf() async {
    _isGeneratingPdf = true;
    _errorMessage = null;
    rebuild();

    try {
      final pdf = await _generatePdfDocument();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      _errorMessage = 'Failed to print PDF: $e';
    } finally {
      _isGeneratingPdf = false;
      rebuild();
    }
  }

  Future<pw.Document> _generatePdfDocument() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Financial Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              dateRangeText,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Text(
              'Generated on ${DateFormat.yMMMMd().format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),

            // Summary Section
            pw.Text(
              'Summary',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _buildPdfTableRow(
                  'Total Income',
                  '\$${totalIncome.toStringAsFixed(2)}',
                  PdfColors.green,
                ),
                _buildPdfTableRow(
                  'Total Expenses',
                  '\$${totalExpense.toStringAsFixed(2)}',
                  PdfColors.red,
                ),
                _buildPdfTableRow(
                  'Net Balance',
                  '\$${netBalance.toStringAsFixed(2)}',
                  netBalance >= 0 ? PdfColors.blue : PdfColors.orange,
                ),
                _buildPdfTableRow(
                  'Total Transactions',
                  '${_transactions.length}',
                  PdfColors.grey800,
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Income by Category
            if (incomeCategories.isNotEmpty) ...[
              pw.Text(
                'Income by Category',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildPdfTableCell('Category', bold: true),
                      _buildPdfTableCell('Amount', bold: true),
                      _buildPdfTableCell('Count', bold: true),
                      _buildPdfTableCell('%', bold: true),
                    ],
                  ),
                  ...incomeCategories.map(
                    (cat) => pw.TableRow(
                      children: [
                        _buildPdfTableCell(
                          _capitalize(cat.category.description),
                        ),
                        _buildPdfTableCell('\$${cat.total.toStringAsFixed(2)}'),
                        _buildPdfTableCell('${cat.count}'),
                        _buildPdfTableCell(
                          '${cat.percentage.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
            ],

            // Expenses by Category
            if (expenseCategories.isNotEmpty) ...[
              pw.Text(
                'Expenses by Category',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildPdfTableCell('Category', bold: true),
                      _buildPdfTableCell('Amount', bold: true),
                      _buildPdfTableCell('Count', bold: true),
                      _buildPdfTableCell('%', bold: true),
                    ],
                  ),
                  ...expenseCategories.map(
                    (cat) => pw.TableRow(
                      children: [
                        _buildPdfTableCell(
                          _capitalize(cat.category.description),
                        ),
                        _buildPdfTableCell('\$${cat.total.toStringAsFixed(2)}'),
                        _buildPdfTableCell('${cat.count}'),
                        _buildPdfTableCell(
                          '${cat.percentage.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
            ],

            // Transaction Details
            if (_transactions.isNotEmpty) ...[
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildPdfTableCell('Date', bold: true),
                      _buildPdfTableCell('Description', bold: true),
                      _buildPdfTableCell('Category', bold: true),
                      _buildPdfTableCell('Amount', bold: true),
                    ],
                  ),
                  ..._transactions.map(
                    (transaction) => pw.TableRow(
                      children: [
                        _buildPdfTableCell(
                          DateFormat.yMMMd().format(transaction.date),
                        ),
                        _buildPdfTableCell(transaction.description),
                        _buildPdfTableCell(
                          _capitalize(transaction.category.description),
                        ),
                        _buildPdfTableCell(
                          '\$${transaction.amount.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ];
        },
      ),
    );

    return pdf;
  }

  pw.TableRow _buildPdfTableRow(String label, String value, PdfColor color) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

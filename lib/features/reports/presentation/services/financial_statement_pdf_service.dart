import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/utils/money_utils.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../domain/entities/financial_statement.dart';

final class FinancialStatementPdfService {
  const FinancialStatementPdfService();

  Future<void> generate(FinancialStatement statement) async {
    await Printing.layoutPdf(
      name: statement.fileName,
      onLayout: (PdfPageFormat pageFormat) {
        return buildPdf(statement, pageFormat: pageFormat);
      },
    );
  }

  Future<Uint8List> buildPdf(
    FinancialStatement statement, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pw.Document document = pw.Document(
      title: 'Personal Financial Statement - ${statement.periodLabel}',
      author: 'Splitwise Expense Tracker',
      subject: 'Personal Financial Statement',
      creator: 'Splitwise Expense Tracker',
    );

    final DateTime generatedAt = DateTime.now();

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(34, 34, 34, 42),
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }

          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 14),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Text(
                  'Personal Financial Statement',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  '${statement.periodLabel} | ${statement.currencyCode}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.6),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Text(
                  'Generated locally by Splitwise Expense Tracker',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return <pw.Widget>[
            _buildHeader(statement, generatedAt),
            pw.SizedBox(height: 20),
            _buildSummary(statement),
            pw.SizedBox(height: 22),
            if (statement.categorySummaries.isNotEmpty) ...<pw.Widget>[
              _sectionTitle('Expense Breakdown by Category'),
              pw.SizedBox(height: 8),
              _buildCategoryTable(statement),
              pw.SizedBox(height: 22),
            ],
            if (statement.period ==
                FinancialStatementPeriod.yearly) ...<pw.Widget>[
              _sectionTitle('Month-by-Month Summary'),
              pw.SizedBox(height: 8),
              _buildMonthlyTable(statement),
              pw.SizedBox(height: 22),
            ],
            _sectionTitle('Transaction Statement'),
            pw.SizedBox(height: 8),
            _buildTransactionTable(statement),
            pw.SizedBox(height: 22),
            _buildDisclaimer(),
          ];
        },
      ),
    );

    return document.save();
  }

  pw.Widget _buildHeader(FinancialStatement statement, DateTime generatedAt) {
    final DateTime periodEnd = statement.periodEndExclusive.subtract(
      const Duration(days: 1),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'SPLITWISE EXPENSE TRACKER',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey700,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Personal Financial Statement',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                child: _headerField(
                  'Statement Period',
                  '${DateFormat('dd MMM yyyy').format(statement.periodStart)}'
                      ' - '
                      '${DateFormat('dd MMM yyyy').format(periodEnd)}',
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _headerField('Currency', statement.currencyCode),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _headerField(
                  'Generated',
                  DateFormat('dd MMM yyyy, HH:mm').format(generatedAt),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _headerField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildSummary(FinancialStatement statement) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _sectionTitle('Summary'),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
          children: <pw.TableRow>[
            _summaryRow(
              'Total Income',
              _money(statement.totalIncomeMinor, statement),
              PdfColors.green700,
            ),
            _summaryRow(
              'Total Expenses',
              _money(statement.totalExpenseMinor, statement),
              PdfColors.red700,
            ),
            _summaryRow(
              'Net Position',
              _money(statement.netPositionMinor, statement),
              statement.netPositionMinor >= 0
                  ? PdfColors.green700
                  : PdfColors.red700,
            ),
            _summaryRow(
              'Transactions',
              statement.transactionCount.toString(),
              PdfColors.blueGrey900,
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _summaryRow(String label, String value, PdfColor valueColor) {
    return pw.TableRow(
      children: <pw.Widget>[
        _tableCell(label, bold: true),
        _tableCell(value, alignRight: true, color: valueColor, bold: true),
      ],
    );
  }

  pw.Widget _buildCategoryTable(FinancialStatement statement) {
    final List<pw.TableRow> rows = <pw.TableRow>[
      _tableHeader(<String>['Category', 'Amount']),
    ];

    for (final FinancialStatementCategorySummary summary
        in statement.categorySummaries) {
      rows.add(
        pw.TableRow(
          children: <pw.Widget>[
            _tableCell(summary.categoryName),
            _tableCell(
              _money(summary.amountMinor, statement),
              alignRight: true,
            ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
      },
      children: rows,
    );
  }

  pw.Widget _buildMonthlyTable(FinancialStatement statement) {
    final List<pw.TableRow> rows = <pw.TableRow>[
      _tableHeader(<String>['Month', 'Income', 'Expenses', 'Net']),
    ];

    for (final FinancialStatementMonthSummary summary
        in statement.monthSummaries) {
      rows.add(
        pw.TableRow(
          children: <pw.Widget>[
            _tableCell(financialStatementMonthName(summary.month)),
            _tableCell(
              _money(summary.incomeMinor, statement),
              alignRight: true,
            ),
            _tableCell(
              _money(summary.expenseMinor, statement),
              alignRight: true,
            ),
            _tableCell(_money(summary.netMinor, statement), alignRight: true),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(1.5),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
      },
      children: rows,
    );
  }

  pw.Widget _buildTransactionTable(FinancialStatement statement) {
    if (statement.transactions.isEmpty) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'No transactions were recorded for this statement period.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      );
    }

    final List<pw.TableRow> rows = <pw.TableRow>[
      _tableHeader(<String>[
        'Date',
        'Description',
        'Category',
        'Type',
        'Amount',
      ]),
    ];

    for (final FinancialStatementTransaction transaction
        in statement.transactions) {
      final bool isIncome = transaction.entryType == ExpenseEntryType.income;

      rows.add(
        pw.TableRow(
          children: <pw.Widget>[
            _tableCell(
              DateFormat('dd MMM yyyy').format(transaction.occurredAt),
            ),
            _tableCell(transaction.title),
            _tableCell(transaction.categoryName),
            _tableCell(isIncome ? 'Income' : 'Expense'),
            _tableCell(
              '${isIncome ? '+' : '-'} '
              '${_money(transaction.amountMinor, statement)}',
              alignRight: true,
              color: isIncome ? PdfColors.green700 : PdfColors.red700,
            ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(1.35),
        1: pw.FlexColumnWidth(2.5),
        2: pw.FlexColumnWidth(1.6),
        3: pw.FlexColumnWidth(1.1),
        4: pw.FlexColumnWidth(1.6),
      },
      children: rows,
    );
  }

  pw.TableRow _tableHeader(List<String> labels) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
      children: labels
          .map(
            (String label) =>
                _tableCell(label, bold: true, color: PdfColors.blueGrey900),
          )
          .toList(growable: false),
    );
  }

  pw.Widget _tableCell(
    String value, {
    bool bold = false,
    bool alignRight = false,
    PdfColor color = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      child: pw.Align(
        alignment: alignRight
            ? pw.Alignment.centerRight
            : pw.Alignment.centerLeft,
        child: pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8,
            color: color,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey900,
      ),
    );
  }

  pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        'This statement was generated from financial records stored locally '
        'in Splitwise Expense Tracker. It is a personal record and is not a '
        'bank-issued or independently verified financial statement.',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
      ),
    );
  }

  String _money(int amountMinor, FinancialStatement statement) {
    return MoneyUtils.formatMinorUnits(
      amountMinor,
      currencyCode: statement.currencyCode,
      scale: statement.currencyScale,
    );
  }
}

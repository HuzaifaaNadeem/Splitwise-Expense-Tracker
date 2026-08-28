import '../../../expenses/domain/entities/expense.dart';

enum FinancialStatementPeriod { monthly, yearly }

final class FinancialStatementTransaction {
  const FinancialStatementTransaction({
    required this.occurredAt,
    required this.title,
    required this.categoryName,
    required this.amountMinor,
    required this.entryType,
  });

  final DateTime occurredAt;
  final String title;
  final String categoryName;
  final int amountMinor;
  final ExpenseEntryType entryType;
}

final class FinancialStatementCategorySummary {
  const FinancialStatementCategorySummary({
    required this.categoryName,
    required this.amountMinor,
  });

  final String categoryName;
  final int amountMinor;
}

final class FinancialStatementMonthSummary {
  const FinancialStatementMonthSummary({
    required this.month,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  final int month;
  final int incomeMinor;
  final int expenseMinor;

  int get netMinor => incomeMinor - expenseMinor;
}

final class FinancialStatement {
  const FinancialStatement({
    required this.period,
    required this.year,
    required this.month,
    required this.currencyCode,
    required this.currencyScale,
    required this.periodStart,
    required this.periodEndExclusive,
    required this.transactions,
    required this.totalIncomeMinor,
    required this.totalExpenseMinor,
    required this.categorySummaries,
    required this.monthSummaries,
  });

  final FinancialStatementPeriod period;
  final int year;
  final int? month;
  final String currencyCode;
  final int currencyScale;
  final DateTime periodStart;
  final DateTime periodEndExclusive;
  final List<FinancialStatementTransaction> transactions;
  final int totalIncomeMinor;
  final int totalExpenseMinor;
  final List<FinancialStatementCategorySummary> categorySummaries;
  final List<FinancialStatementMonthSummary> monthSummaries;

  int get netPositionMinor => totalIncomeMinor - totalExpenseMinor;

  int get transactionCount => transactions.length;

  String get periodLabel {
    if (period == FinancialStatementPeriod.yearly) {
      return year.toString();
    }

    return '${_monthName(month!)} $year';
  }

  String get fileName {
    if (period == FinancialStatementPeriod.yearly) {
      return 'financial_statement_${year}_$currencyCode.pdf';
    }

    return 'financial_statement_'
        '${year}_${month!.toString().padLeft(2, '0')}_'
        '$currencyCode.pdf';
  }
}

String financialStatementPeriodName(FinancialStatementPeriod period) {
  return switch (period) {
    FinancialStatementPeriod.monthly => 'Monthly',
    FinancialStatementPeriod.yearly => 'Yearly',
  };
}

String financialStatementMonthName(int month) {
  return _monthName(month);
}

String _monthName(int month) {
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months[month - 1];
}

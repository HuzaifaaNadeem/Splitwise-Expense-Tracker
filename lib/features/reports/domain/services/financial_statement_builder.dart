import '../../../expenses/domain/entities/expense.dart';
import '../entities/financial_statement.dart';

final class FinancialStatementBuilder {
  const FinancialStatementBuilder();

  FinancialStatement build({
    required List<Expense> expenses,
    required Map<String, String> categoryNames,
    required FinancialStatementPeriod period,
    required int year,
    required int? month,
    required String currencyCode,
    required int currencyScale,
  }) {
    if (period == FinancialStatementPeriod.monthly &&
        (month == null || month < 1 || month > 12)) {
      throw ArgumentError.value(
        month,
        'month',
        'A valid month is required for a monthly statement.',
      );
    }

    final String normalizedCurrency = currencyCode.trim().toUpperCase();

    final DateTime start;
    final DateTime endExclusive;

    if (period == FinancialStatementPeriod.monthly) {
      start = DateTime(year, month!);
      endExclusive = DateTime(year, month + 1);
    } else {
      start = DateTime(year);
      endExclusive = DateTime(year + 1);
    }

    final List<Expense> filtered =
        expenses
            .where((Expense expense) {
              if (expense.isDeleted) {
                return false;
              }

              if (expense.currencyCode.toUpperCase() != normalizedCurrency ||
                  expense.currencyScale != currencyScale) {
                return false;
              }

              final DateTime occurredAt = expense.occurredAt.toLocal();

              return !occurredAt.isBefore(start) &&
                  occurredAt.isBefore(endExclusive);
            })
            .toList(growable: false)
          ..sort((Expense left, Expense right) {
            return left.occurredAt.compareTo(right.occurredAt);
          });

    int totalIncomeMinor = 0;
    int totalExpenseMinor = 0;

    final Map<String, int> categoryExpenseTotals = <String, int>{};
    final List<int> monthlyIncome = List<int>.filled(12, 0);
    final List<int> monthlyExpense = List<int>.filled(12, 0);

    final List<FinancialStatementTransaction> transactions =
        <FinancialStatementTransaction>[];

    for (final Expense expense in filtered) {
      final DateTime localDate = expense.occurredAt.toLocal();

      if (expense.entryType == ExpenseEntryType.income) {
        totalIncomeMinor += expense.amountMinor;
        monthlyIncome[localDate.month - 1] += expense.amountMinor;
      } else {
        totalExpenseMinor += expense.amountMinor;
        monthlyExpense[localDate.month - 1] += expense.amountMinor;

        final String categoryName =
            categoryNames[expense.categoryId] ?? expense.categoryId;

        categoryExpenseTotals.update(
          categoryName,
          (int current) => current + expense.amountMinor,
          ifAbsent: () => expense.amountMinor,
        );
      }

      transactions.add(
        FinancialStatementTransaction(
          occurredAt: localDate,
          title: expense.title,
          categoryName: categoryNames[expense.categoryId] ?? expense.categoryId,
          amountMinor: expense.amountMinor,
          entryType: expense.entryType,
        ),
      );
    }

    final List<FinancialStatementCategorySummary> categorySummaries =
        categoryExpenseTotals.entries
            .map(
              (MapEntry<String, int> entry) =>
                  FinancialStatementCategorySummary(
                    categoryName: entry.key,
                    amountMinor: entry.value,
                  ),
            )
            .toList(growable: false)
          ..sort((
            FinancialStatementCategorySummary left,
            FinancialStatementCategorySummary right,
          ) {
            final int byAmount = right.amountMinor.compareTo(left.amountMinor);

            if (byAmount != 0) {
              return byAmount;
            }

            return left.categoryName.compareTo(right.categoryName);
          });

    final List<FinancialStatementMonthSummary> monthSummaries =
        List<FinancialStatementMonthSummary>.generate(
          12,
          (int index) => FinancialStatementMonthSummary(
            month: index + 1,
            incomeMinor: monthlyIncome[index],
            expenseMinor: monthlyExpense[index],
          ),
          growable: false,
        );

    return FinancialStatement(
      period: period,
      year: year,
      month: period == FinancialStatementPeriod.monthly ? month : null,
      currencyCode: normalizedCurrency,
      currencyScale: currencyScale,
      periodStart: start,
      periodEndExclusive: endExclusive,
      transactions: transactions,
      totalIncomeMinor: totalIncomeMinor,
      totalExpenseMinor: totalExpenseMinor,
      categorySummaries: categorySummaries,
      monthSummaries: monthSummaries,
    );
  }
}

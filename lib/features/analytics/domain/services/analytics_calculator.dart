import '../../../expenses/domain/entities/expense.dart';
import '../entities/analytics_snapshot.dart';
import '../entities/category_spending.dart';
import '../entities/period_financial_summary.dart';

final class AnalyticsCalculator {
  const AnalyticsCalculator();

  AnalyticsSnapshot calculate({
    required List<Expense> entries,
    DateTime? now,
    String currencyCode = 'PKR',
    int currencyScale = 2,
  }) {
    final DateTime localNow = (now ?? DateTime.now()).toLocal();

    final (DateTime, DateTime) weekRange = _weekRange(localNow);

    final (DateTime, DateTime) monthRange = _monthRange(localNow);

    final Map<String, int> categoryTotals = <String, int>{};

    int weeklyExpense = 0;
    int weeklyIncome = 0;

    int monthlyExpense = 0;
    int monthlyIncome = 0;

    for (final Expense entry in entries) {
      if (entry.isDeleted ||
          entry.currencyCode != currencyCode ||
          entry.currencyScale != currencyScale) {
        continue;
      }

      final DateTime occurredAt = entry.occurredAt.toLocal();

      if (_isInside(occurredAt, weekRange.$1, weekRange.$2)) {
        if (entry.entryType == ExpenseEntryType.expense) {
          weeklyExpense += entry.amountMinor;
        } else {
          weeklyIncome += entry.amountMinor;
        }
      }

      if (_isInside(occurredAt, monthRange.$1, monthRange.$2)) {
        if (entry.entryType == ExpenseEntryType.expense) {
          monthlyExpense += entry.amountMinor;

          categoryTotals.update(
            entry.categoryId,
            (int current) => current + entry.amountMinor,
            ifAbsent: () => entry.amountMinor,
          );
        } else {
          monthlyIncome += entry.amountMinor;
        }
      }
    }

    final List<CategorySpending> categorySpending =
        categoryTotals.entries
            .map((MapEntry<String, int> entry) {
              return CategorySpending(
                categoryId: entry.key,
                amountMinor: entry.value,
              );
            })
            .toList(growable: false)
          ..sort((CategorySpending first, CategorySpending second) {
            return second.amountMinor.compareTo(first.amountMinor);
          });

    return AnalyticsSnapshot(
      categorySpending: List<CategorySpending>.unmodifiable(categorySpending),
      weekly: PeriodFinancialSummary(
        expenseMinor: weeklyExpense,
        incomeMinor: weeklyIncome,
      ),
      monthly: PeriodFinancialSummary(
        expenseMinor: monthlyExpense,
        incomeMinor: monthlyIncome,
      ),
    );
  }

  bool _isInside(DateTime value, DateTime start, DateTime endExclusive) {
    return !value.isBefore(start) && value.isBefore(endExclusive);
  }

  (DateTime, DateTime) _weekRange(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);

    final DateTime start = day.subtract(
      Duration(days: day.weekday - DateTime.monday),
    );

    final DateTime end = start.add(const Duration(days: 7));

    return (start, end);
  }

  (DateTime, DateTime) _monthRange(DateTime date) {
    final DateTime start = DateTime(date.year, date.month);

    final DateTime end = DateTime(date.year, date.month + 1);

    return (start, end);
  }
}

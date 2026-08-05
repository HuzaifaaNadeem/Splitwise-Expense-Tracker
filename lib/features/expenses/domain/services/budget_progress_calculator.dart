import '../entities/budget.dart';
import '../entities/expense.dart';

enum BudgetWarningLevel { safe, warning, danger }

final class BudgetProgress {
  const BudgetProgress({
    required this.spentMinor,
    required this.budgetMinor,
    required this.ratio,
    required this.warningLevel,
  });

  final int spentMinor;
  final int budgetMinor;
  final double ratio;
  final BudgetWarningLevel warningLevel;

  int get remainingMinor {
    final int remaining = budgetMinor - spentMinor;
    return remaining < 0 ? 0 : remaining;
  }

  double get clampedRatio {
    return ratio.clamp(0.0, 1.0);
  }
}

final class BudgetProgressCalculator {
  const BudgetProgressCalculator();

  BudgetProgress calculate({
    required Budget budget,
    required List<Expense> expenses,
    DateTime? now,
  }) {
    final DateTime localNow = (now ?? DateTime.now()).toLocal();

    final (DateTime, DateTime) range = switch (budget.period) {
      BudgetPeriod.weekly => _weekRange(localNow),
      BudgetPeriod.monthly => _monthRange(localNow),
    };

    final DateTime start = range.$1;
    final DateTime endExclusive = range.$2;

    int spentMinor = 0;

    for (final Expense expense in expenses) {
      if (expense.entryType != ExpenseEntryType.expense ||
          expense.isDeleted ||
          expense.currencyCode != budget.currencyCode ||
          expense.currencyScale != budget.currencyScale) {
        continue;
      }

      final DateTime occurredAt = expense.occurredAt.toLocal();

      if (!occurredAt.isBefore(start) && occurredAt.isBefore(endExclusive)) {
        spentMinor += expense.amountMinor;
      }
    }

    final double ratio = budget.amountMinor == 0
        ? 0
        : spentMinor / budget.amountMinor;

    final BudgetWarningLevel warningLevel;

    if (ratio >= 0.90) {
      warningLevel = BudgetWarningLevel.danger;
    } else if (ratio >= 0.70) {
      warningLevel = BudgetWarningLevel.warning;
    } else {
      warningLevel = BudgetWarningLevel.safe;
    }

    return BudgetProgress(
      spentMinor: spentMinor,
      budgetMinor: budget.amountMinor,
      ratio: ratio,
      warningLevel: warningLevel,
    );
  }

  (DateTime, DateTime) _weekRange(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);

    final DateTime start = day.subtract(
      Duration(days: day.weekday - DateTime.monday),
    );

    return (start, start.add(const Duration(days: 7)));
  }

  (DateTime, DateTime) _monthRange(DateTime date) {
    final DateTime start = DateTime(date.year, date.month);

    final DateTime end = DateTime(date.year, date.month + 1);

    return (start, end);
  }
}

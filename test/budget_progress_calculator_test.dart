import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/budget.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/services/budget_progress_calculator.dart';

void main() {
  const BudgetProgressCalculator calculator = BudgetProgressCalculator();

  group('BudgetProgressCalculator', () {
    test('returns safe level below seventy percent', () {
      final BudgetProgress result = calculator.calculate(
        budget: _budget(amountMinor: 100000),
        expenses: <Expense>[
          _expense(amountMinor: 50000, occurredAt: DateTime(2026, 8, 5)),
        ],
        now: DateTime(2026, 8, 5),
      );

      expect(result.spentMinor, 50000);
      expect(result.remainingMinor, 50000);
      expect(result.ratio, 0.5);
      expect(result.warningLevel, BudgetWarningLevel.safe);
    });

    test('returns warning level at seventy percent', () {
      final BudgetProgress result = calculator.calculate(
        budget: _budget(amountMinor: 100000),
        expenses: <Expense>[
          _expense(amountMinor: 70000, occurredAt: DateTime(2026, 8, 5)),
        ],
        now: DateTime(2026, 8, 5),
      );

      expect(result.warningLevel, BudgetWarningLevel.warning);
    });

    test('returns danger level at ninety percent', () {
      final BudgetProgress result = calculator.calculate(
        budget: _budget(amountMinor: 100000),
        expenses: <Expense>[
          _expense(amountMinor: 90000, occurredAt: DateTime(2026, 8, 5)),
        ],
        now: DateTime(2026, 8, 5),
      );

      expect(result.warningLevel, BudgetWarningLevel.danger);
    });

    test('excludes expenses outside the current month', () {
      final BudgetProgress result = calculator.calculate(
        budget: _budget(amountMinor: 100000),
        expenses: <Expense>[
          _expense(
            id: 'current',
            amountMinor: 25000,
            occurredAt: DateTime(2026, 8, 5),
          ),
          _expense(
            id: 'previous',
            amountMinor: 50000,
            occurredAt: DateTime(2026, 7, 31),
          ),
        ],
        now: DateTime(2026, 8, 5),
      );

      expect(result.spentMinor, 25000);
    });

    test('excludes income and expenses in another currency', () {
      final BudgetProgress result = calculator.calculate(
        budget: _budget(amountMinor: 100000),
        expenses: <Expense>[
          _expense(
            id: 'expense',
            amountMinor: 20000,
            occurredAt: DateTime(2026, 8, 5),
          ),
          _expense(
            id: 'income',
            amountMinor: 60000,
            occurredAt: DateTime(2026, 8, 5),
            entryType: ExpenseEntryType.income,
          ),
          _expense(
            id: 'usd-expense',
            amountMinor: 30000,
            occurredAt: DateTime(2026, 8, 5),
            currencyCode: 'USD',
          ),
        ],
        now: DateTime(2026, 8, 5),
      );

      expect(result.spentMinor, 20000);
    });

    test('calculates the current Monday-to-Sunday week', () {
      final BudgetProgress result = calculator.calculate(
        budget: _budget(period: BudgetPeriod.weekly, amountMinor: 100000),
        expenses: <Expense>[
          _expense(
            id: 'monday',
            amountMinor: 10000,
            occurredAt: DateTime(2026, 8, 3),
          ),
          _expense(
            id: 'sunday',
            amountMinor: 20000,
            occurredAt: DateTime(2026, 8, 9, 23),
          ),
          _expense(
            id: 'previous-sunday',
            amountMinor: 30000,
            occurredAt: DateTime(2026, 8, 2),
          ),
        ],
        now: DateTime(2026, 8, 5),
      );

      expect(result.spentMinor, 30000);
    });
  });
}

Budget _budget({
  BudgetPeriod period = BudgetPeriod.monthly,
  required int amountMinor,
}) {
  final DateTime timestamp = DateTime.utc(2026, 8, 5);

  return Budget(
    id: period == BudgetPeriod.weekly ? 'budget-weekly' : 'budget-monthly',
    period: period,
    amountMinor: amountMinor,
    currencyCode: 'PKR',
    currencyScale: 2,
    isActive: true,
    revision: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

Expense _expense({
  String id = 'expense-1',
  required int amountMinor,
  required DateTime occurredAt,
  String currencyCode = 'PKR',
  ExpenseEntryType entryType = ExpenseEntryType.expense,
}) {
  final DateTime timestamp = DateTime.utc(2026, 8, 5);

  return Expense(
    id: id,
    title: 'Test expense',
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    currencyScale: 2,
    categoryId: 'food',
    occurredAt: occurredAt,
    entryType: entryType,
    revision: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

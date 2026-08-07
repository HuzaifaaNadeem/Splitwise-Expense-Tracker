import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/analytics/domain/entities/analytics_snapshot.dart';
import 'package:splitwise_expense_tracker/features/analytics/domain/services/analytics_calculator.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';

void main() {
  const AnalyticsCalculator calculator = AnalyticsCalculator();

  group('AnalyticsCalculator', () {
    test('calculates monthly spending by category', () {
      final AnalyticsSnapshot result = calculator.calculate(
        entries: <Expense>[
          _entry(
            id: 'food-1',
            amountMinor: 100000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 5),
          ),
          _entry(
            id: 'food-2',
            amountMinor: 50000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 6),
          ),
          _entry(
            id: 'travel',
            amountMinor: 200000,
            categoryId: 'travel',
            occurredAt: DateTime(2026, 8, 7),
          ),
        ],
        now: DateTime(2026, 8, 7),
      );

      expect(result.categorySpending.length, 2);

      expect(result.categorySpending[0].categoryId, 'travel');

      expect(result.categorySpending[0].amountMinor, 200000);

      expect(result.categorySpending[1].categoryId, 'food');

      expect(result.categorySpending[1].amountMinor, 150000);
    });

    test('calculates weekly expense and income totals', () {
      final AnalyticsSnapshot result = calculator.calculate(
        entries: <Expense>[
          _entry(
            id: 'expense',
            amountMinor: 200000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 5),
          ),
          _entry(
            id: 'income',
            amountMinor: 500000,
            categoryId: 'income',
            occurredAt: DateTime(2026, 8, 6),
            entryType: ExpenseEntryType.income,
          ),
        ],
        now: DateTime(2026, 8, 7),
      );

      expect(result.weekly.expenseMinor, 200000);

      expect(result.weekly.incomeMinor, 500000);

      expect(result.weekly.netMinor, 300000);
    });

    test('excludes entries outside the current month', () {
      final AnalyticsSnapshot result = calculator.calculate(
        entries: <Expense>[
          _entry(
            id: 'current',
            amountMinor: 100000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 5),
          ),
          _entry(
            id: 'previous-month',
            amountMinor: 900000,
            categoryId: 'travel',
            occurredAt: DateTime(2026, 7, 31),
          ),
        ],
        now: DateTime(2026, 8, 7),
      );

      expect(result.monthly.expenseMinor, 100000);

      expect(result.categorySpending.length, 1);
    });

    test('excludes deleted entries', () {
      final AnalyticsSnapshot result = calculator.calculate(
        entries: <Expense>[
          _entry(
            id: 'active',
            amountMinor: 100000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 5),
          ),
          _entry(
            id: 'deleted',
            amountMinor: 500000,
            categoryId: 'travel',
            occurredAt: DateTime(2026, 8, 5),
            deletedAt: DateTime.utc(2026, 8, 6),
          ),
        ],
        now: DateTime(2026, 8, 7),
      );

      expect(result.monthly.expenseMinor, 100000);
    });

    test('excludes another currency', () {
      final AnalyticsSnapshot result = calculator.calculate(
        entries: <Expense>[
          _entry(
            id: 'pkr',
            amountMinor: 100000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 5),
          ),
          _entry(
            id: 'usd',
            amountMinor: 900000,
            categoryId: 'travel',
            occurredAt: DateTime(2026, 8, 5),
            currencyCode: 'USD',
          ),
        ],
        now: DateTime(2026, 8, 7),
      );

      expect(result.monthly.expenseMinor, 100000);
    });

    test('uses Monday through Sunday for weekly totals', () {
      final AnalyticsSnapshot result = calculator.calculate(
        entries: <Expense>[
          _entry(
            id: 'monday',
            amountMinor: 10000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 3),
          ),
          _entry(
            id: 'sunday',
            amountMinor: 20000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 9, 23),
          ),
          _entry(
            id: 'old-sunday',
            amountMinor: 50000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 2),
          ),
        ],
        now: DateTime(2026, 8, 7),
      );

      expect(result.weekly.expenseMinor, 30000);
    });
  });
}

Expense _entry({
  required String id,
  required int amountMinor,
  required String categoryId,
  required DateTime occurredAt,
  String currencyCode = 'PKR',
  ExpenseEntryType entryType = ExpenseEntryType.expense,
  DateTime? deletedAt,
}) {
  final DateTime timestamp = DateTime.utc(2026, 8, 5);

  return Expense(
    id: id,
    title: id,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    currencyScale: 2,
    categoryId: categoryId,
    occurredAt: occurredAt,
    entryType: entryType,
    revision: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
    deletedAt: deletedAt,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:splitwise_expense_tracker/features/reports/domain/entities/financial_statement.dart';
import 'package:splitwise_expense_tracker/features/reports/domain/services/financial_statement_builder.dart';

void main() {
  const FinancialStatementBuilder builder = FinancialStatementBuilder();

  test('monthly statement filters by period and currency', () {
    final List<Expense> expenses = <Expense>[
      _expense(
        id: 'july-food',
        amountMinor: 250000,
        occurredAt: DateTime(2026, 7, 10),
        categoryId: 'food',
      ),
      _expense(
        id: 'aug-food',
        amountMinor: 50000,
        occurredAt: DateTime(2026, 8, 2),
        categoryId: 'food',
      ),
      _expense(
        id: 'july-usd',
        amountMinor: 1000,
        occurredAt: DateTime(2026, 7, 11),
        categoryId: 'food',
        currencyCode: 'USD',
      ),
    ];

    final FinancialStatement statement = builder.build(
      expenses: expenses,
      categoryNames: const <String, String>{'food': 'Food'},
      period: FinancialStatementPeriod.monthly,
      year: 2026,
      month: 7,
      currencyCode: 'PKR',
      currencyScale: 2,
    );

    expect(statement.transactionCount, 1);
    expect(statement.totalExpenseMinor, 250000);
    expect(statement.totalIncomeMinor, 0);
    expect(statement.transactions.single.title, 'july-food');
  });

  test('statement separates income and expenses and calculates net', () {
    final List<Expense> expenses = <Expense>[
      _expense(
        id: 'salary',
        amountMinor: 10000000,
        occurredAt: DateTime(2026, 7, 1),
        categoryId: 'income',
        entryType: ExpenseEntryType.income,
      ),
      _expense(
        id: 'food',
        amountMinor: 3000000,
        occurredAt: DateTime(2026, 7, 5),
        categoryId: 'food',
      ),
    ];

    final FinancialStatement statement = builder.build(
      expenses: expenses,
      categoryNames: const <String, String>{'income': 'Income', 'food': 'Food'},
      period: FinancialStatementPeriod.monthly,
      year: 2026,
      month: 7,
      currencyCode: 'PKR',
      currencyScale: 2,
    );

    expect(statement.totalIncomeMinor, 10000000);
    expect(statement.totalExpenseMinor, 3000000);
    expect(statement.netPositionMinor, 7000000);
  });

  test('deleted records are excluded', () {
    final Expense deleted = _expense(
      id: 'deleted',
      amountMinor: 100000,
      occurredAt: DateTime(2026, 7, 8),
      categoryId: 'food',
      deletedAt: DateTime(2026, 7, 9),
    );

    final FinancialStatement statement = builder.build(
      expenses: <Expense>[deleted],
      categoryNames: const <String, String>{'food': 'Food'},
      period: FinancialStatementPeriod.monthly,
      year: 2026,
      month: 7,
      currencyCode: 'PKR',
      currencyScale: 2,
    );

    expect(statement.transactionCount, 0);
    expect(statement.totalExpenseMinor, 0);
  });

  test('yearly statement builds month summaries', () {
    final List<Expense> expenses = <Expense>[
      _expense(
        id: 'jan-expense',
        amountMinor: 200000,
        occurredAt: DateTime(2025, 1, 10),
        categoryId: 'food',
      ),
      _expense(
        id: 'jan-income',
        amountMinor: 500000,
        occurredAt: DateTime(2025, 1, 2),
        categoryId: 'income',
        entryType: ExpenseEntryType.income,
      ),
      _expense(
        id: 'feb-expense',
        amountMinor: 100000,
        occurredAt: DateTime(2025, 2, 5),
        categoryId: 'travel',
      ),
    ];

    final FinancialStatement statement = builder.build(
      expenses: expenses,
      categoryNames: const <String, String>{
        'food': 'Food',
        'income': 'Income',
        'travel': 'Travel',
      },
      period: FinancialStatementPeriod.yearly,
      year: 2025,
      month: null,
      currencyCode: 'PKR',
      currencyScale: 2,
    );

    expect(statement.transactionCount, 3);
    expect(statement.monthSummaries[0].incomeMinor, 500000);
    expect(statement.monthSummaries[0].expenseMinor, 200000);
    expect(statement.monthSummaries[0].netMinor, 300000);
    expect(statement.monthSummaries[1].expenseMinor, 100000);
  });
}

Expense _expense({
  required String id,
  required int amountMinor,
  required DateTime occurredAt,
  required String categoryId,
  String currencyCode = 'PKR',
  ExpenseEntryType entryType = ExpenseEntryType.expense,
  DateTime? deletedAt,
}) {
  final DateTime now = DateTime(2026, 1, 1).toUtc();

  return Expense(
    id: id,
    title: id,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    currencyScale: 2,
    categoryId: categoryId,
    occurredAt: occurredAt.toUtc(),
    entryType: entryType,
    revision: 1,
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt?.toUtc(),
  );
}

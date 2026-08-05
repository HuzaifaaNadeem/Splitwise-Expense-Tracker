import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/expenses/data/mappers/expense_mapper.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';

void main() {
  test('Expense mapper preserves domain values', () {
    final DateTime occurredAt = DateTime.utc(2026, 8, 5, 12, 30);

    final DateTime createdAt = DateTime.utc(2026, 8, 5, 12);

    final Expense expense = Expense(
      id: 'expense-1',
      title: 'Lunch',
      amountMinor: 125050,
      currencyCode: 'PKR',
      currencyScale: 2,
      categoryId: 'food',
      occurredAt: occurredAt,
      notes: 'Team lunch',
      entryType: ExpenseEntryType.expense,
      revision: 1,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final model = ExpenseMapper.toModel(expense);
    final Expense result = ExpenseMapper.toDomain(model);

    expect(result, expense);
  });
}

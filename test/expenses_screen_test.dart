import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:splitwise_expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splitwise_expense_tracker/features/expenses/presentation/screens/expenses_screen.dart';

import 'helpers/fake_expense_repository.dart';

void main() {
  testWidgets('ExpensesScreen displays persisted expenses', (
    WidgetTester tester,
  ) async {
    final DateTime timestamp = DateTime.utc(2026, 8, 5, 12);

    final Expense expense = Expense(
      id: 'expense-1',
      title: 'Groceries',
      amountMinor: 250000,
      currencyCode: 'PKR',
      currencyScale: 2,
      categoryId: 'food',
      occurredAt: timestamp,
      entryType: ExpenseEntryType.expense,
      revision: 1,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    final FakeExpenseRepository repository = FakeExpenseRepository(<Expense>[
      expense,
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          expenseRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ExpensesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);

    expect(find.text('PKR 2,500.00'), findsOneWidget);
  });
}

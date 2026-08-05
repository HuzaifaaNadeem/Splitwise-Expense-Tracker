import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/core/errors/result.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:splitwise_expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:splitwise_expense_tracker/features/expenses/presentation/providers/expense_providers.dart';

import 'helpers/fake_expense_repository.dart';

void main() {
  test('ExpenseController creates and refreshes expenses', () async {
    final FakeExpenseRepository repository = FakeExpenseRepository();

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        expenseRepositoryProvider.overrideWithValue(repository),
      ],
    );

    addTearDown(container.dispose);

    final List<Expense> initial = await container.read(
      expenseControllerProvider.future,
    );

    expect(initial, isEmpty);

    final Result<Expense> result = await container
        .read(expenseControllerProvider.notifier)
        .createExpense(
          title: 'Lunch',
          amountMinor: 120000,
          currencyCode: 'PKR',
          currencyScale: 2,
          categoryId: 'food',
          occurredAt: DateTime.utc(2026, 8, 5, 13),
        );

    expect(result, isA<Success<Expense>>());

    expect(repository.storedExpenses.length, 1);

    final AsyncValue<List<Expense>> state = container.read(
      expenseControllerProvider,
    );

    expect(state.hasValue, isTrue);
    expect(state.value?.length, 1);
    expect(state.value?.single.title, 'Lunch');
  });
}

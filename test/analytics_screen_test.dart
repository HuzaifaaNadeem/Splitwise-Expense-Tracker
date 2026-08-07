import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:splitwise_expense_tracker/features/expenses/presentation/providers/category_budget_providers.dart';
import 'package:splitwise_expense_tracker/features/expenses/presentation/providers/expense_providers.dart';

import 'helpers/fake_category_repository.dart';
import 'helpers/fake_expense_repository.dart';

void main() {
  testWidgets('AnalyticsScreen displays summary and charts', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final DateTime now = DateTime.now();

    final Expense expense = Expense(
      id: 'analytics-expense',
      title: 'Groceries',
      amountMinor: 250000,
      currencyCode: 'PKR',
      currencyScale: 2,
      categoryId: 'food',
      occurredAt: now,
      entryType: ExpenseEntryType.expense,
      revision: 1,
      createdAt: now.toUtc(),
      updatedAt: now.toUtc(),
    );

    final FakeExpenseRepository expenseRepository = FakeExpenseRepository(
      <Expense>[expense],
    );

    final FakeCategoryRepository categoryRepository = FakeCategoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          expenseRepositoryProvider.overrideWithValue(expenseRepository),
          categoryRepositoryProvider.overrideWithValue(categoryRepository),
        ],
        child: const MaterialApp(home: Scaffold(body: AnalyticsScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Financial Analytics'), findsOneWidget);

    expect(find.text('Weekly Expenses'), findsOneWidget);

    expect(find.text('Weekly Income'), findsOneWidget);

    expect(find.text('Monthly Expenses'), findsOneWidget);

    expect(find.text('Monthly Income'), findsOneWidget);

    expect(find.text('Spending by Category'), findsOneWidget);

    expect(find.text('Income vs Expenses'), findsOneWidget);

    expect(find.text('PKR 2,500.00'), findsWidgets);

    expect(find.byType(PieChart), findsOneWidget);

    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('AnalyticsScreen shows empty category state with no expenses', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final FakeExpenseRepository expenseRepository = FakeExpenseRepository();

    final FakeCategoryRepository categoryRepository = FakeCategoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          expenseRepositoryProvider.overrideWithValue(expenseRepository),
          categoryRepositoryProvider.overrideWithValue(categoryRepository),
        ],
        child: const MaterialApp(home: Scaffold(body: AnalyticsScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Financial Analytics'), findsOneWidget);

    expect(
      find.text('Add expenses this month to see your category breakdown.'),
      findsOneWidget,
    );

    expect(find.byType(PieChart), findsNothing);

    expect(find.byType(BarChart), findsOneWidget);
  });
}

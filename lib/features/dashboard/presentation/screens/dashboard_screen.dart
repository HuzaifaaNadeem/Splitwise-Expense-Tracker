import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../../../core/db/database_provider.dart';
import '../../../../core/db/database_service.dart';

final dashboardExpensesProvider = StreamProvider<List<ExpenseModel>>((
  ref,
) async* {
  final DatabaseService databaseService = ref.watch(databaseServiceProvider);

  Future<List<ExpenseModel>> loadExpenses() async {
    final List<ExpenseModel> expenses = await databaseService.isar.expenseModels
        .where()
        .findAll();

    return expenses
        .where((ExpenseModel expense) => expense.deletedAt == null)
        .toList(growable: false);
  }

  yield await loadExpenses();

  await for (final void _ in databaseService.isar.expenseModels.watchLazy()) {
    yield await loadExpenses();
  }
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ExpenseModel>> expensesAsync = ref.watch(
      dashboardExpensesProvider,
    );

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) {
        return _DashboardErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(dashboardExpensesProvider);
          },
        );
      },
      data: (List<ExpenseModel> expenses) {
        return _DashboardContent(expenses: expenses);
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.expenses});

  final List<ExpenseModel> expenses;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final DateTime now = DateTime.now();

    final List<ExpenseModel> monthlyExpenses = expenses.where((
      ExpenseModel expense,
    ) {
      final DateTime localDate = expense.occurredAt.toLocal();

      return localDate.year == now.year && localDate.month == now.month;
    }).toList();

    monthlyExpenses.sort((ExpenseModel first, ExpenseModel second) {
      return second.occurredAt.compareTo(first.occurredAt);
    });

    int monthlyTotalMinor = 0;

    for (final ExpenseModel expense in monthlyExpenses) {
      monthlyTotalMinor += expense.amountMinor;
    }

    final List<ExpenseModel> recentExpenses = monthlyExpenses
        .take(3)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text(
          'Financial overview',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your spending, budgets, group balances, '
          'and financial activity in one place.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: <Widget>[
            _SummaryCard(
              icon: Icons.payments_outlined,
              label: 'This month',
              value: 'PKR ${_formatMoney(monthlyTotalMinor)}',
            ),
            const _SummaryCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Remaining budget',
              value: 'PKR 0.00',
            ),
            const _SummaryCard(
              icon: Icons.groups_outlined,
              label: 'You are owed',
              value: 'PKR 0.00',
            ),
            _SummaryCard(
              icon: Icons.receipt_long_outlined,
              label: 'Transactions',
              value: '${monthlyExpenses.length}',
            ),
          ],
        ),

        const SizedBox(height: 32),

        if (monthlyExpenses.isEmpty)
          const _EmptyState()
        else ...<Widget>[
          _MonthlyActivityCard(
            transactionCount: monthlyExpenses.length,
            totalMinor: monthlyTotalMinor,
          ),
          const SizedBox(height: 24),
          Text(
            'Recent expenses',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < recentExpenses.length;
                  index++
                ) ...<Widget>[
                  _RecentExpenseTile(expense: recentExpenses[index]),
                  if (index < recentExpenses.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthlyActivityCard extends StatelessWidget {
  const _MonthlyActivityCard({
    required this.transactionCount,
    required this.totalMinor,
  });

  final int transactionCount;
  final int totalMinor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.insights_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Monthly activity',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$transactionCount '
                    '${transactionCount == 1 ? 'transaction' : 'transactions'} '
                    'recorded this month.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Total spending',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PKR ${_formatMoney(totalMinor)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentExpenseTile extends StatelessWidget {
  const _RecentExpenseTile({required this.expense});

  final ExpenseModel expense;

  @override
  Widget build(BuildContext context) {
    final DateTime date = expense.occurredAt.toLocal();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
      title: Text(
        expense.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(_formatDate(date)),
      trailing: Text(
        'PKR ${_formatMoney(expense.amountMinor)}',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'No expenses recorded this month',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first expense to start '
                    'tracking spending and analytics.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load dashboard',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _formatMoney(int amountMinor) {
  final bool negative = amountMinor < 0;
  final int absolute = amountMinor.abs();

  final int whole = absolute ~/ 100;
  final int fraction = absolute % 100;

  final String wholeFormatted = _addThousandsSeparators(whole.toString());

  return '${negative ? '-' : ''}'
      '$wholeFormatted.'
      '${fraction.toString().padLeft(2, '0')}';
}

String _addThousandsSeparators(String digits) {
  final StringBuffer buffer = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    buffer.write(digits[index]);

    final int remaining = digits.length - index - 1;

    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}

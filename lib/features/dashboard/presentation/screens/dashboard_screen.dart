import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/currency/default_currency_controller.dart';
import '../../../../core/db/database_provider.dart';
import '../../../../core/db/database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../group_splits/domain/entities/group.dart';
import '../../../group_splits/domain/entities/group_member.dart';
import '../../../group_splits/domain/entities/group_split.dart';
import '../../../group_splits/domain/entities/member_balance.dart';
import '../../../group_splits/domain/services/group_balance_calculator.dart';
import '../../../group_splits/presentation/providers/group_providers.dart';
import '../../../group_splits/presentation/providers/group_split_providers.dart';

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

final dashboardBudgetsProvider = StreamProvider<List<BudgetModel>>((
  ref,
) async* {
  final DatabaseService databaseService = ref.watch(databaseServiceProvider);

  Future<List<BudgetModel>> loadBudgets() async {
    final List<BudgetModel> budgets = await databaseService.isar.budgetModels
        .where()
        .findAll();

    return budgets
        .where(
          (BudgetModel budget) => budget.deletedAt == null && budget.isActive,
        )
        .toList(growable: false);
  }

  yield await loadBudgets();

  await for (final void _ in databaseService.isar.budgetModels.watchLazy()) {
    yield await loadBudgets();
  }
});

final dashboardYouAreOwedProvider = FutureProvider<int>((ref) async {
  final AppCurrency currency = ref.watch(defaultCurrencyControllerProvider);

  final List<Group> groups = await ref.watch(groupsProvider.future);

  const GroupBalanceCalculator calculator = GroupBalanceCalculator();

  int totalOwedMinor = 0;

  for (final Group group in groups) {
    if (group.defaultCurrencyCode.toUpperCase() != currency.code ||
        group.defaultCurrencyScale != currency.scale) {
      continue;
    }

    final GroupMember? currentUser = group.currentUser;

    if (currentUser == null) {
      continue;
    }

    final List<GroupSplit> splits = await ref.watch(
      groupSplitsProvider(group.id).future,
    );

    final List<String> memberIds = group.members
        .map((GroupMember member) => member.id)
        .toList(growable: false);

    final List<MemberBalance> balances = calculator.calculate(
      memberIds: memberIds,
      splits: splits,
    );

    for (final MemberBalance balance in balances) {
      if (balance.memberId != currentUser.id) {
        continue;
      }

      if (balance.balanceMinor > 0) {
        totalOwedMinor += balance.balanceMinor;
      }

      break;
    }
  }

  return totalOwedMinor;
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency currency = ref.watch(defaultCurrencyControllerProvider);

    final AsyncValue<List<ExpenseModel>> expensesAsync = ref.watch(
      dashboardExpensesProvider,
    );

    final AsyncValue<List<BudgetModel>> budgetsAsync = ref.watch(
      dashboardBudgetsProvider,
    );

    final AsyncValue<int> owedAsync = ref.watch(dashboardYouAreOwedProvider);

    return expensesAsync.when(
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (Object error, StackTrace stackTrace) {
        return _DashboardErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(dashboardExpensesProvider);
            ref.invalidate(dashboardBudgetsProvider);
            ref.invalidate(dashboardYouAreOwedProvider);
          },
        );
      },
      data: (List<ExpenseModel> expenses) {
        return _DashboardContent(
          expenses: expenses,
          budgetsAsync: budgetsAsync,
          owedAsync: owedAsync,
          currency: currency,
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.expenses,
    required this.budgetsAsync,
    required this.owedAsync,
    required this.currency,
  });

  final List<ExpenseModel> expenses;
  final AsyncValue<List<BudgetModel>> budgetsAsync;
  final AsyncValue<int> owedAsync;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final DateTime monthStart = DateTime(now.year, now.month);

    final DateTime nextMonth = DateTime(now.year, now.month + 1);

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime weekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    final DateTime nextWeek = weekStart.add(const Duration(days: 7));

    final List<ExpenseModel> selectedCurrencyExpenses = expenses
        .where(
          (ExpenseModel expense) =>
              expense.currencyCode.toUpperCase() == currency.code &&
              expense.currencyScale == currency.scale,
        )
        .toList(growable: false);

    final List<ExpenseModel> monthlyExpenses = _expensesInRange(
      selectedCurrencyExpenses,
      monthStart,
      nextMonth,
    );

    final List<ExpenseModel> weeklyExpenses = _expensesInRange(
      selectedCurrencyExpenses,
      weekStart,
      nextWeek,
    );

    monthlyExpenses.sort((ExpenseModel first, ExpenseModel second) {
      return second.occurredAt.compareTo(first.occurredAt);
    });

    final int monthlySpentMinor = _sumExpenses(monthlyExpenses);

    final int weeklySpentMinor = _sumExpenses(weeklyExpenses);

    final _BudgetSnapshot? weeklyBudget = budgetsAsync.when(
      loading: () => null,
      error: (Object error, StackTrace stackTrace) => null,
      data: (List<BudgetModel> budgets) {
        return _createBudgetSnapshot(
          budgets: budgets,
          period: BudgetPeriodType.weekly,
          spentMinor: weeklySpentMinor,
          currency: currency,
        );
      },
    );

    final _BudgetSnapshot? monthlyBudget = budgetsAsync.when(
      loading: () => null,
      error: (Object error, StackTrace stackTrace) => null,
      data: (List<BudgetModel> budgets) {
        return _createBudgetSnapshot(
          budgets: budgets,
          period: BudgetPeriodType.monthly,
          spentMinor: monthlySpentMinor,
          currency: currency,
        );
      },
    );

    final String owedValue = owedAsync.when(
      loading: () => 'Loading...',
      error: (Object error, StackTrace stackTrace) => 'Unavailable',
      data: (int amountMinor) {
        return '${currency.code} ${_formatMoney(amountMinor)}';
      },
    );

    final List<ExpenseModel> recentExpenses = monthlyExpenses
        .take(5)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(28),
      children: <Widget>[
        _DashboardHeader(monthName: _monthName(now.month), year: now.year),
        const SizedBox(height: 26),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: <Widget>[
            _KpiCard(
              icon: Icons.payments_outlined,
              label: 'Spent this month',
              value: '${currency.code} ${_formatMoney(monthlySpentMinor)}',
              caption:
                  '${monthlyExpenses.length} ${monthlyExpenses.length == 1 ? 'transaction' : 'transactions'}',
            ),
            _KpiCard(
              icon: Icons.calendar_month_outlined,
              label: 'Monthly remaining',
              value: _budgetRemainingValue(monthlyBudget, currency.code),
              caption: monthlyBudget == null
                  ? 'No monthly budget'
                  : _budgetStatusText(monthlyBudget),
            ),
            _KpiCard(
              icon: Icons.date_range_outlined,
              label: 'Weekly remaining',
              value: _budgetRemainingValue(weeklyBudget, currency.code),
              caption: weeklyBudget == null
                  ? 'No weekly budget'
                  : _budgetStatusText(weeklyBudget),
            ),
            _KpiCard(
              icon: Icons.groups_outlined,
              label: 'You are owed',
              value: owedValue,
              caption: 'Across active ${currency.code} groups',
            ),
            _KpiCard(
              icon: Icons.receipt_long_outlined,
              label: 'Transactions',
              value: '${monthlyExpenses.length}',
              caption: 'Current month',
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          'Budget health',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'See how your current spending compares with your limits.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 900;

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _BudgetProgressCard(
                      title: 'Weekly budget',
                      periodLabel: _weekRangeLabel(
                        weekStart,
                        nextWeek.subtract(const Duration(days: 1)),
                      ),
                      snapshot: weeklyBudget,
                      currency: currency,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BudgetProgressCard(
                      title: 'Monthly budget',
                      periodLabel: '${_monthName(now.month)} ${now.year}',
                      snapshot: monthlyBudget,
                      currency: currency,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: <Widget>[
                _BudgetProgressCard(
                  title: 'Weekly budget',
                  periodLabel: _weekRangeLabel(
                    weekStart,
                    nextWeek.subtract(const Duration(days: 1)),
                  ),
                  snapshot: weeklyBudget,
                  currency: currency,
                ),
                const SizedBox(height: 16),
                _BudgetProgressCard(
                  title: 'Monthly budget',
                  periodLabel: '${_monthName(now.month)} ${now.year}',
                  snapshot: monthlyBudget,
                  currency: currency,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Recent expenses',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'This month',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (recentExpenses.isEmpty)
          const _EmptyRecentExpenses()
        else
          Card(
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < recentExpenses.length;
                  index++
                ) ...<Widget>[
                  _RecentExpenseTile(
                    expense: recentExpenses[index],
                    currency: currency,
                  ),
                  if (index < recentExpenses.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.monthName, required this.year});

  final String monthName;
  final int year;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Financial overview',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'A clear view of spending, budgets and shared balances.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(10),
            color: colors.surface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '$monthName $year',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 236,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: colors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({
    required this.title,
    required this.periodLabel,
    required this.snapshot,
    required this.currency,
  });

  final String title;
  final String periodLabel;
  final _BudgetSnapshot? snapshot;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final _BudgetSnapshot? current = snapshot;

    if (current == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$periodLabel â€¢ No budget configured',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
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

    final Color statusColor = _budgetStatusColor(current);

    final double progressValue = current.ratio.clamp(0.0, 1.0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        periodLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _budgetStatusText(current),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 9,
              color: statusColor,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: _BudgetMetric(
                    label: 'Spent',
                    value:
                        '${currency.code} ${_formatMoney(current.spentMinor)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BudgetMetric(
                    label: 'Budget',
                    value:
                        '${currency.code} ${_formatMoney(current.budgetMinor)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BudgetMetric(
                    label: current.remainingMinor >= 0
                        ? 'Remaining'
                        : 'Over budget',
                    value:
                        '${currency.code} ${_formatMoney(current.remainingMinor.abs())}',
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

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _RecentExpenseTile extends StatelessWidget {
  const _RecentExpenseTile({required this.expense, required this.currency});

  final ExpenseModel expense;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final DateTime localDate = expense.occurredAt.toLocal();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          Icons.receipt_long_outlined,
          size: 20,
          color: colors.primary,
        ),
      ),
      title: Text(
        expense.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(_formatDate(localDate)),
      trailing: Text(
        '${currency.code} ${_formatMoney(expense.amountMinor)}',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyRecentExpenses extends StatelessWidget {
  const _EmptyRecentExpenses();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.receipt_long_outlined,
              size: 38,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'No expenses this month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'New personal expenses will appear here automatically.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
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

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 46),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetSnapshot {
  const _BudgetSnapshot({required this.budgetMinor, required this.spentMinor});

  final int budgetMinor;
  final int spentMinor;

  int get remainingMinor {
    return budgetMinor - spentMinor;
  }

  double get ratio {
    if (budgetMinor <= 0) {
      return 0;
    }

    return spentMinor / budgetMinor;
  }
}

_BudgetSnapshot? _createBudgetSnapshot({
  required List<BudgetModel> budgets,
  required BudgetPeriodType period,
  required int spentMinor,
  required AppCurrency currency,
}) {
  for (final BudgetModel budget in budgets) {
    if (budget.periodType == period &&
        budget.deletedAt == null &&
        budget.isActive &&
        budget.currencyCode.toUpperCase() == currency.code &&
        budget.currencyScale == currency.scale) {
      return _BudgetSnapshot(
        budgetMinor: budget.amountMinor,
        spentMinor: spentMinor,
      );
    }
  }

  return null;
}

List<ExpenseModel> _expensesInRange(
  List<ExpenseModel> expenses,
  DateTime start,
  DateTime endExclusive,
) {
  return expenses.where((ExpenseModel expense) {
    final DateTime occurredAt = expense.occurredAt.toLocal();

    return !occurredAt.isBefore(start) && occurredAt.isBefore(endExclusive);
  }).toList();
}

int _sumExpenses(List<ExpenseModel> expenses) {
  int total = 0;

  for (final ExpenseModel expense in expenses) {
    total += expense.amountMinor;
  }

  return total;
}

String _budgetRemainingValue(_BudgetSnapshot? snapshot, String currencyCode) {
  if (snapshot == null) {
    return 'Not set';
  }

  if (snapshot.remainingMinor < 0) {
    return '$currencyCode ${_formatMoney(snapshot.remainingMinor.abs())} over';
  }

  return '$currencyCode ${_formatMoney(snapshot.remainingMinor)}';
}

String _budgetStatusText(_BudgetSnapshot snapshot) {
  if (snapshot.ratio >= 1.0) {
    return 'Over budget';
  }

  if (snapshot.ratio >= 0.90) {
    return 'Almost used';
  }

  if (snapshot.ratio >= 0.70) {
    return 'Watch spending';
  }

  return 'On track';
}

Color _budgetStatusColor(_BudgetSnapshot snapshot) {
  if (snapshot.ratio >= 0.90) {
    return AppColors.danger;
  }

  if (snapshot.ratio >= 0.70) {
    return AppColors.warning;
  }

  return AppColors.positive;
}

String _weekRangeLabel(DateTime start, DateTime end) {
  return '${start.day} ${_shortMonthName(start.month)} â€“ '
      '${end.day} ${_shortMonthName(end.month)} ${end.year}';
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

String _monthName(int month) {
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months[month - 1];
}

String _shortMonthName(int month) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[month - 1];
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/utils/money_utils.dart';
import '../../domain/entities/expense.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_category_option.dart';
import 'expense_form_screen.dart';
import 'expense_settings_screen.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Expense>> expenses = ref.watch(
      expenseControllerProvider,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          unawaited(_openExpenseForm(context));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: expenses.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (Object error, StackTrace stackTrace) {
          return _ErrorState(
            message: error.toString(),
            onRetry: () {
              unawaited(ref.read(expenseControllerProvider.notifier).refresh());
            },
          );
        },
        data: (List<Expense> values) {
          if (values.isEmpty) {
            return _EmptyExpenses(
              onAddExpense: () {
                unawaited(_openExpenseForm(context));
              },
              onManageSettings: () {
                unawaited(_openExpenseSettings(context));
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.read(expenseControllerProvider.notifier).refresh();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              children: <Widget>[
                _ExpensesHeader(
                  expenseCount: values.length,
                  onManageSettings: () {
                    unawaited(_openExpenseSettings(context));
                  },
                ),
                const SizedBox(height: 20),
                for (final Expense expense in values)
                  _ExpenseCard(
                    expense: expense,
                    onEdit: () {
                      unawaited(_openExpenseForm(context, expense: expense));
                    },
                    onDelete: () {
                      unawaited(_confirmDelete(context, ref, expense));
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openExpenseForm(
    BuildContext context, {
    Expense? expense,
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return ExpenseFormScreen(expense: expense);
        },
      ),
    );
  }

  Future<void> _openExpenseSettings(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const ExpenseSettingsScreen();
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: Text(
            'Delete "${expense.title}"? '
            'This expense will be removed from your active records.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final Result<bool> result = await ref
        .read(expenseControllerProvider.notifier)
        .deleteExpense(expense.id);

    if (!context.mounted) {
      return;
    }

    result.fold(
      onSuccess: (bool deleted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense deleted.')));
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }
}

class _ExpensesHeader extends StatelessWidget {
  const _ExpensesHeader({
    required this.expenseCount,
    required this.onManageSettings,
  });

  final int expenseCount;
  final VoidCallback onManageSettings;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        Text(
          '$expenseCount '
          '${expenseCount == 1 ? 'expense' : 'expenses'}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        OutlinedButton.icon(
          onPressed: onManageSettings,
          icon: const Icon(Icons.tune_outlined),
          label: const Text('Budgets & Categories'),
        ),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ExpenseCategoryOption category = expenseCategoryById(
      expense.categoryId,
    );

    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Icon(category.icon),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${category.label} • '
            '${DateFormat('dd MMM yyyy, h:mm a').format(expense.occurredAt.toLocal())}',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                MoneyUtils.formatMinorUnits(
                  expense.amountMinor,
                  currencyCode: expense.currencyCode,
                  scale: expense.currencyScale,
                ),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.error,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String action) {
                if (action == 'edit') {
                  onEdit();
                } else if (action == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) {
                return const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses({
    required this.onAddExpense,
    required this.onManageSettings,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onManageSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.receipt_long_outlined, size: 72),
              const SizedBox(height: 20),
              Text(
                'No expenses yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your first expense and it will be saved locally '
                'on this device.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: onAddExpense,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onManageSettings,
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Budgets & Categories'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Could not load expenses',
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

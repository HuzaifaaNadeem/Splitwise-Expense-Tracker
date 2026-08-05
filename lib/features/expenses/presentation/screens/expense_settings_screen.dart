import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_utils.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/services/budget_progress_calculator.dart';
import '../controllers/budget_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/expense_controller.dart';
import '../models/category_visuals.dart';

class ExpenseSettingsScreen extends ConsumerWidget {
  const ExpenseSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Budget>> budgets = ref.watch(
      budgetControllerProvider,
    );

    final AsyncValue<List<ExpenseCategory>> categories = ref.watch(
      categoryControllerProvider,
    );

    final List<Expense> expenses =
        ref.watch(expenseControllerProvider).value ?? const <Expense>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets & Categories')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(
            'Budgets',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Set spending caps for the current week and month.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          budgets.when(
            loading: () => const LinearProgressIndicator(),
            error: (Object error, StackTrace stackTrace) {
              return _LoadError(
                message: 'Could not load budgets.',
                onRetry: () {
                  unawaited(
                    ref.read(budgetControllerProvider.notifier).refresh(),
                  );
                },
              );
            },
            data: (List<Budget> values) {
              final Budget? weekly = _budgetFor(values, BudgetPeriod.weekly);

              final Budget? monthly = _budgetFor(values, BudgetPeriod.monthly);

              return Column(
                children: <Widget>[
                  _BudgetCard(
                    title: 'Weekly budget',
                    budget: weekly,
                    expenses: expenses,
                    onEdit: () {
                      unawaited(
                        _showBudgetDialog(
                          context,
                          ref,
                          BudgetPeriod.weekly,
                          weekly,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _BudgetCard(
                    title: 'Monthly budget',
                    budget: monthly,
                    expenses: expenses,
                    onEdit: () {
                      unawaited(
                        _showBudgetDialog(
                          context,
                          ref,
                          BudgetPeriod.monthly,
                          monthly,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 36),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  unawaited(_showCategoryDialog(context, ref));
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Default categories are protected. Custom categories can be '
            'edited or deleted.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          categories.when(
            loading: () => const LinearProgressIndicator(),
            error: (Object error, StackTrace stackTrace) {
              return _LoadError(
                message: 'Could not load categories.',
                onRetry: () {
                  unawaited(
                    ref.read(categoryControllerProvider.notifier).refresh(),
                  );
                },
              );
            },
            data: (List<ExpenseCategory> values) {
              return Column(
                children: <Widget>[
                  for (final ExpenseCategory category in values)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(category.colorValue),
                          foregroundColor: Colors.white,
                          child: Icon(
                            categoryIconFromCodePoint(category.iconCodePoint),
                          ),
                        ),
                        title: Text(category.name),
                        subtitle: Text(
                          category.isDefault
                              ? 'Default category'
                              : 'Custom category',
                        ),
                        trailing: category.isDefault
                            ? const Icon(Icons.lock_outline)
                            : PopupMenuButton<String>(
                                onSelected: (String action) {
                                  if (action == 'edit') {
                                    unawaited(
                                      _showCategoryDialog(
                                        context,
                                        ref,
                                        category: category,
                                      ),
                                    );
                                  } else if (action == 'delete') {
                                    unawaited(
                                      _deleteCategory(context, ref, category),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return const <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ];
                                },
                              ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Budget? _budgetFor(List<Budget> budgets, BudgetPeriod period) {
    for (final Budget budget in budgets) {
      if (budget.period == period) {
        return budget;
      }
    }

    return null;
  }

  Future<void> _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetPeriod period,
    Budget? existing,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: existing == null
          ? ''
          : _editableAmount(existing.amountMinor, existing.currencyScale),
    );

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            period == BudgetPeriod.weekly ? 'Weekly Budget' : 'Monthly Budget',
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Budget amount',
                prefixText: 'PKR ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              validator: (String? value) {
                final int? amount = MoneyUtils.parseToMinorUnits(
                  value ?? '',
                  scale: 2,
                );

                if (amount == null || amount <= 0) {
                  return 'Enter a valid budget.';
                }

                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final int amountMinor = MoneyUtils.parseToMinorUnits(
                  controller.text,
                  scale: 2,
                )!;

                final Result<Budget> result = await ref
                    .read(budgetControllerProvider.notifier)
                    .saveBudget(period: period, amountMinor: amountMinor);

                if (!dialogContext.mounted) {
                  return;
                }

                result.fold<void>(
                  onSuccess: (Budget budget) {
                    Navigator.of(dialogContext).pop();
                  },
                  onFailure: (Failure failure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(failure.message)));
                  },
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    ExpenseCategory? category,
  }) async {
    final TextEditingController nameController = TextEditingController(
      text: category?.name ?? '',
    );

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    int iconCodePoint =
        category?.iconCodePoint ?? Icons.category_outlined.codePoint;

    int colorValue = category?.colorValue ?? categoryColorChoices.first;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder:
              (BuildContext dialogBodyContext, StateSetter setDialogState) {
                return AlertDialog(
                  title: Text(
                    category == null ? 'Add Category' : 'Edit Category',
                  ),
                  content: SizedBox(
                    width: 420,
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: nameController,
                              autofocus: true,
                              maxLength: 40,
                              decoration: const InputDecoration(
                                labelText: 'Category name',
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter a category name.';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Icon',
                              style: Theme.of(
                                dialogBodyContext,
                              ).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                for (final CategoryIconChoice choice
                                    in categoryIconChoices)
                                  IconButton.filledTonal(
                                    isSelected:
                                        iconCodePoint == choice.icon.codePoint,
                                    tooltip: choice.label,
                                    onPressed: () {
                                      setDialogState(() {
                                        iconCodePoint = choice.icon.codePoint;
                                      });
                                    },
                                    icon: Icon(choice.icon),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Color',
                              style: Theme.of(
                                dialogBodyContext,
                              ).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: <Widget>[
                                for (final int color in categoryColorChoices)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {
                                      setDialogState(() {
                                        colorValue = color;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Color(color),
                                        shape: BoxShape.circle,
                                        border: colorValue == color
                                            ? Border.all(
                                                color: Theme.of(
                                                  dialogBodyContext,
                                                ).colorScheme.onSurface,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        final Result<ExpenseCategory> result;

                        if (category == null) {
                          result = await ref
                              .read(categoryControllerProvider.notifier)
                              .createCategory(
                                name: nameController.text,
                                iconCodePoint: iconCodePoint,
                                colorValue: colorValue,
                              );
                        } else {
                          result = await ref
                              .read(categoryControllerProvider.notifier)
                              .updateCategory(
                                existing: category,
                                name: nameController.text,
                                iconCodePoint: iconCodePoint,
                                colorValue: colorValue,
                              );
                        }

                        if (!dialogContext.mounted) {
                          return;
                        }

                        result.fold<void>(
                          onSuccess: (ExpenseCategory savedCategory) {
                            Navigator.of(dialogContext).pop();
                          },
                          onFailure: (Failure failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message)),
                            );
                          },
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
        );
      },
    );

    nameController.dispose();
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    ExpenseCategory category,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete category?'),
          content: Text('Delete "${category.name}"?'),
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
        .read(categoryControllerProvider.notifier)
        .deleteCategory(category.id);

    if (!context.mounted) {
      return;
    }

    result.fold<void>(
      onSuccess: (bool deleted) {},
      onFailure: (Failure failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  String _editableAmount(int amountMinor, int scale) {
    int divisor = 1;

    for (int index = 0; index < scale; index++) {
      divisor *= 10;
    }

    final int whole = amountMinor ~/ divisor;

    if (scale == 0) {
      return whole.toString();
    }

    final int fraction = amountMinor % divisor;

    return '$whole.'
        '${fraction.toString().padLeft(scale, '0')}';
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.title,
    required this.budget,
    required this.expenses,
    required this.onEdit,
  });

  final String title;
  final Budget? budget;
  final List<Expense> expenses;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final Budget? currentBudget = budget;

    if (currentBudget == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: Text(title),
          subtitle: const Text('No budget set'),
          trailing: FilledButton(onPressed: onEdit, child: const Text('Set')),
        ),
      );
    }

    final BudgetProgress progress = const BudgetProgressCalculator().calculate(
      budget: currentBudget,
      expenses: expenses,
    );

    final Color color = switch (progress.warningLevel) {
      BudgetWarningLevel.safe => AppColors.positive,
      BudgetWarningLevel.warning => AppColors.warning,
      BudgetWarningLevel.danger => AppColors.danger,
    };

    final int percentage = (progress.ratio * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit budget',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clampedRatio,
              minHeight: 10,
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text(
              '$percentage% used',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${MoneyUtils.formatMinorUnits(progress.spentMinor, currencyCode: currentBudget.currencyCode, scale: currentBudget.currencyScale)} of ${MoneyUtils.formatMinorUnits(progress.budgetMinor, currencyCode: currentBudget.currencyCode, scale: currentBudget.currencyScale)}',
            ),
            const SizedBox(height: 4),
            Text(
              'Remaining: ${MoneyUtils.formatMinorUnits(progress.remainingMinor, currencyCode: currentBudget.currencyCode, scale: currentBudget.currencyScale)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text(message),
        trailing: IconButton(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

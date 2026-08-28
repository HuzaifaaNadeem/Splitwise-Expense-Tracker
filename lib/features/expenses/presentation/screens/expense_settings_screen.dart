import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/currency/default_currency_controller.dart';
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
            'Set weekly and monthly spending limits. '
            'Your spending progress automatically resets when a new '
            'week or month begins.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          const _BudgetResetInfoCard(),
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
                    period: BudgetPeriod.weekly,
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
                    onDelete: weekly == null
                        ? null
                        : () {
                            unawaited(
                              _deleteBudget(context, ref, BudgetPeriod.weekly),
                            );
                          },
                  ),
                  const SizedBox(height: 16),
                  _BudgetCard(
                    title: 'Monthly budget',
                    period: BudgetPeriod.monthly,
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
                    onDelete: monthly == null
                        ? null
                        : () {
                            unawaited(
                              _deleteBudget(context, ref, BudgetPeriod.monthly),
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

    final AppCurrency defaultCurrency = ref.read(
      defaultCurrencyControllerProvider,
    );

    final AppCurrency budgetCurrency = existing == null
        ? defaultCurrency
        : AppCurrency.fromCode(existing.currencyCode);

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final _PeriodInfo periodInfo = _periodInfo(period, DateTime.now());

        return AlertDialog(
          title: Text(
            period == BudgetPeriod.weekly
                ? existing == null
                      ? 'Set Weekly Budget'
                      : 'Edit Weekly Budget'
                : existing == null
                ? 'Set Monthly Budget'
                : 'Edit Monthly Budget',
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          period == BudgetPeriod.weekly
                              ? Icons.date_range_outlined
                              : Icons.calendar_month_outlined,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                periodInfo.currentLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                period == BudgetPeriod.weekly
                                    ? 'Spending resets next Monday.'
                                    : 'Spending resets on the 1st of '
                                          'next month.',
                                style: Theme.of(
                                  dialogContext,
                                ).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Budget amount',
                      prefixText: '${budgetCurrency.code} ',
                      prefixIcon: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final int? amount = MoneyUtils.parseToMinorUnits(
                        value ?? '',
                        scale: budgetCurrency.scale,
                      );

                      if (amount == null || amount <= 0) {
                        return 'Enter a valid budget.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    existing == null
                        ? 'New budgets use your default currency '
                              '(${budgetCurrency.code}).'
                        : 'This existing budget remains in '
                              '${budgetCurrency.code}. Delete it first if you '
                              'want to recreate it in your current default '
                              'currency.',
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'The budget amount will carry forward automatically '
                    'into each new ${period == BudgetPeriod.weekly ? 'week' : 'month'}.',
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ],
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

                final int amountMinor = MoneyUtils.parseToMinorUnits(
                  controller.text,
                  scale: budgetCurrency.scale,
                )!;

                final Result<Budget> result = await ref
                    .read(budgetControllerProvider.notifier)
                    .saveBudget(
                      period: period,
                      amountMinor: amountMinor,
                      currencyCode: budgetCurrency.code,
                      currencyScale: budgetCurrency.scale,
                    );

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

  Future<void> _deleteBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetPeriod period,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete budget?'),
          content: Text(
            'Delete the ${period == BudgetPeriod.weekly ? 'weekly' : 'monthly'} '
            'budget? You can create a new one afterward using your current '
            'default currency.',
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
        .read(budgetControllerProvider.notifier)
        .deleteBudget(period);

    if (!context.mounted) {
      return;
    }

    result.fold<void>(
      onSuccess: (bool deleted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Budget deleted.')));
      },
      onFailure: (Failure failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
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

class _BudgetResetInfoCard extends StatelessWidget {
  const _BudgetResetInfoCard();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.autorenew_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Weekly spending starts fresh every Monday and '
                'monthly spending starts fresh on the 1st. '
                'Your configured budget amounts remain saved.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.title,
    required this.period,
    required this.budget,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final BudgetPeriod period;
  final Budget? budget;
  final List<Expense> expenses;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme colorScheme = theme.colorScheme;

    final _PeriodInfo periodInfo = _periodInfo(period, DateTime.now());

    final Budget? currentBudget = budget;

    if (currentBudget == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    period == BudgetPeriod.weekly
                        ? Icons.date_range_outlined
                        : Icons.calendar_month_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          periodInfo.currentLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'No budget set for this period.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.add),
                label: Text(
                  period == BudgetPeriod.weekly
                      ? 'Set weekly budget'
                      : 'Set monthly budget',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final BudgetProgress progress = const BudgetProgressCalculator().calculate(
      budget: currentBudget,
      expenses: expenses,
    );

    final Color progressColor = switch (progress.warningLevel) {
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    period == BudgetPeriod.weekly
                        ? Icons.date_range_outlined
                        : Icons.calendar_month_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        periodInfo.currentLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Delete budget',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                IconButton(
                  tooltip: 'Edit budget',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _BudgetAmountSummary(budget: currentBudget, progress: progress),
            const SizedBox(height: 18),
            LinearProgressIndicator(
              value: progress.clampedRatio,
              minHeight: 10,
              color: progressColor,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Text(
                  '$percentage% used',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  periodInfo.resetLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _BudgetAmountSummary extends StatelessWidget {
  const _BudgetAmountSummary({required this.budget, required this.progress});

  final Budget budget;
  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _BudgetMetric(
            label: 'Budget',
            value: MoneyUtils.formatMinorUnits(
              progress.budgetMinor,
              currencyCode: budget.currencyCode,
              scale: budget.currencyScale,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BudgetMetric(
            label: 'Spent',
            value: MoneyUtils.formatMinorUnits(
              progress.spentMinor,
              currencyCode: budget.currencyCode,
              scale: budget.currencyScale,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BudgetMetric(
            label: 'Remaining',
            value: MoneyUtils.formatMinorUnits(
              progress.remainingMinor,
              currencyCode: budget.currencyCode,
              scale: budget.currencyScale,
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

class _PeriodInfo {
  const _PeriodInfo({required this.currentLabel, required this.resetLabel});

  final String currentLabel;
  final String resetLabel;
}

_PeriodInfo _periodInfo(BudgetPeriod period, DateTime date) {
  final DateTime localDate = date.toLocal();

  return switch (period) {
    BudgetPeriod.weekly => _weeklyPeriodInfo(localDate),
    BudgetPeriod.monthly => _monthlyPeriodInfo(localDate),
  };
}

_PeriodInfo _weeklyPeriodInfo(DateTime date) {
  final DateTime day = DateTime(date.year, date.month, date.day);

  final DateTime start = day.subtract(
    Duration(days: day.weekday - DateTime.monday),
  );

  final DateTime end = start.add(const Duration(days: 6));

  final DateTime nextStart = start.add(const Duration(days: 7));

  return _PeriodInfo(
    currentLabel:
        '${_shortDate(start)} â€“ '
        '${_shortDateWithYear(end)}',
    resetLabel: 'Resets ${_shortDateWithYear(nextStart)}',
  );
}

_PeriodInfo _monthlyPeriodInfo(DateTime date) {
  final DateTime nextMonth = DateTime(date.year, date.month + 1);

  return _PeriodInfo(
    currentLabel:
        '${_monthName(date.month)} '
        '${date.year}',
    resetLabel: 'Resets ${_shortDateWithYear(nextMonth)}',
  );
}

String _shortDate(DateTime date) {
  return '${date.day} '
      '${_shortMonthName(date.month)}';
}

String _shortDateWithYear(DateTime date) {
  return '${date.day} '
      '${_shortMonthName(date.month)} '
      '${date.year}';
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

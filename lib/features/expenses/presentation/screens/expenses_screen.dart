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

enum _ExpenseSort { newest, oldest, highestAmount, lowestAmount }

enum _ExpensePeriodFilter { all, thisWeek, thisMonth }

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  static const String _allCategories = '__all__';

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategoryId = _allCategories;
  _ExpenseSort _sort = _ExpenseSort.newest;
  _ExpensePeriodFilter _period = _ExpensePeriodFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Expense>> expensesAsync = ref.watch(
      expenseControllerProvider,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          unawaited(_openExpenseForm(context));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: expensesAsync.when(
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
        data: (List<Expense> expenses) {
          if (expenses.isEmpty) {
            return _EmptyExpenses(
              onAddExpense: () {
                unawaited(_openExpenseForm(context));
              },
              onManageSettings: () {
                unawaited(_openExpenseSettings(context));
              },
            );
          }

          final List<MapEntry<String, String>> categories =
              _availableCategories(expenses);

          final List<Expense> visibleExpenses = _filterAndSort(expenses);

          final int totalVisibleMinor = _sumExpenses(visibleExpenses);

          return RefreshIndicator(
            onRefresh: () {
              return ref.read(expenseControllerProvider.notifier).refresh();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 110),
              children: <Widget>[
                _ExpensesHeader(
                  visibleCount: visibleExpenses.length,
                  totalCount: expenses.length,
                  totalVisibleMinor: totalVisibleMinor,
                  onManageSettings: () {
                    unawaited(_openExpenseSettings(context));
                  },
                ),
                const SizedBox(height: 22),
                _ExpenseToolbar(
                  searchController: _searchController,
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  selectedPeriod: _period,
                  selectedSort: _sort,
                  onCategoryChanged: (String categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                  onPeriodChanged: (_ExpensePeriodFilter value) {
                    setState(() {
                      _period = value;
                    });
                  },
                  onSortChanged: (_ExpenseSort value) {
                    setState(() {
                      _sort = value;
                    });
                  },
                  onClearFilters: _clearFilters,
                ),
                const SizedBox(height: 22),
                if (visibleExpenses.isEmpty)
                  _NoFilteredExpenses(onClearFilters: _clearFilters)
                else
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          if (constraints.maxWidth >= 900) {
                            return _DesktopExpenseTable(
                              expenses: visibleExpenses,
                              onEdit: (Expense expense) {
                                unawaited(
                                  _openExpenseForm(context, expense: expense),
                                );
                              },
                              onDelete: (Expense expense) {
                                unawaited(
                                  _confirmDelete(context, ref, expense),
                                );
                              },
                            );
                          }

                          return Column(
                            children: <Widget>[
                              for (final Expense expense in visibleExpenses)
                                _ExpenseCard(
                                  expense: expense,
                                  onEdit: () {
                                    unawaited(
                                      _openExpenseForm(
                                        context,
                                        expense: expense,
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    unawaited(
                                      _confirmDelete(context, ref, expense),
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Expense> _filterAndSort(List<Expense> expenses) {
    final String query = _searchController.text.trim().toLowerCase();

    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime weekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    final DateTime nextWeek = weekStart.add(const Duration(days: 7));

    final DateTime monthStart = DateTime(now.year, now.month);

    final DateTime nextMonth = DateTime(now.year, now.month + 1);

    final List<Expense> filtered = expenses.where((Expense expense) {
      final ExpenseCategoryOption category = expenseCategoryById(
        expense.categoryId,
      );

      if (query.isNotEmpty) {
        final bool searchMatches =
            expense.title.toLowerCase().contains(query) ||
            category.label.toLowerCase().contains(query);

        if (!searchMatches) {
          return false;
        }
      }

      if (_selectedCategoryId != _allCategories &&
          expense.categoryId != _selectedCategoryId) {
        return false;
      }

      final DateTime occurredAt = expense.occurredAt.toLocal();

      switch (_period) {
        case _ExpensePeriodFilter.all:
          break;

        case _ExpensePeriodFilter.thisWeek:
          if (occurredAt.isBefore(weekStart) ||
              !occurredAt.isBefore(nextWeek)) {
            return false;
          }

        case _ExpensePeriodFilter.thisMonth:
          if (occurredAt.isBefore(monthStart) ||
              !occurredAt.isBefore(nextMonth)) {
            return false;
          }
      }

      return true;
    }).toList();

    switch (_sort) {
      case _ExpenseSort.newest:
        filtered.sort((Expense first, Expense second) {
          return second.occurredAt.compareTo(first.occurredAt);
        });

      case _ExpenseSort.oldest:
        filtered.sort((Expense first, Expense second) {
          return first.occurredAt.compareTo(second.occurredAt);
        });

      case _ExpenseSort.highestAmount:
        filtered.sort((Expense first, Expense second) {
          return second.amountMinor.compareTo(first.amountMinor);
        });

      case _ExpenseSort.lowestAmount:
        filtered.sort((Expense first, Expense second) {
          return first.amountMinor.compareTo(second.amountMinor);
        });
    }

    return filtered;
  }

  List<MapEntry<String, String>> _availableCategories(List<Expense> expenses) {
    final Map<String, String> categories = <String, String>{};

    for (final Expense expense in expenses) {
      final ExpenseCategoryOption option = expenseCategoryById(
        expense.categoryId,
      );

      categories[expense.categoryId] = option.label;
    }

    final List<MapEntry<String, String>> values = categories.entries.toList();

    values.sort((
      MapEntry<String, String> first,
      MapEntry<String, String> second,
    ) {
      return first.value.compareTo(second.value);
    });

    return values;
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedCategoryId = _allCategories;
      _period = _ExpensePeriodFilter.all;
      _sort = _ExpenseSort.newest;
    });
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

    result.fold<void>(
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
    required this.visibleCount,
    required this.totalCount,
    required this.totalVisibleMinor,
    required this.onManageSettings,
  });

  final int visibleCount;
  final int totalCount;
  final int totalVisibleMinor;
  final VoidCallback onManageSettings;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String visibleTotal = MoneyUtils.formatMinorUnits(
      totalVisibleMinor,
      currencyCode: 'PKR',
      scale: 2,
    );

    return Wrap(
      spacing: 18,
      runSpacing: 18,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Personal expenses',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Search, review and manage your day-to-day spending.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _HeaderMetric(
              label: 'Showing',
              value: '$visibleCount / $totalCount',
            ),
            _HeaderMetric(label: 'Visible total', value: '$visibleTotal total'),
            OutlinedButton.icon(
              onPressed: onManageSettings,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Budgets'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ExpenseToolbar extends StatelessWidget {
  const _ExpenseToolbar({
    required this.searchController,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedPeriod,
    required this.selectedSort,
    required this.onCategoryChanged,
    required this.onPeriodChanged,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  final TextEditingController searchController;
  final List<MapEntry<String, String>> categories;
  final String selectedCategoryId;
  final _ExpensePeriodFilter selectedPeriod;
  final _ExpenseSort selectedSort;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<_ExpensePeriodFilter> onPeriodChanged;
  final ValueChanged<_ExpenseSort> onSortChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 310,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search expenses',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: searchController.clear,
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            SizedBox(
              width: 230,
              child: DropdownButtonFormField<String>(
                key: ValueKey<String>(selectedCategoryId),
                initialValue: selectedCategoryId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(
                    value: _ExpensesScreenState._allCategories,
                    child: Text(
                      'All categories',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  for (final MapEntry<String, String> category in categories)
                    DropdownMenuItem<String>(
                      value: category.key,
                      child: Text(
                        category.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    onCategoryChanged(value);
                  }
                },
              ),
            ),
            SizedBox(
              width: 210,
              child: DropdownButtonFormField<_ExpensePeriodFilter>(
                key: ValueKey<_ExpensePeriodFilter>(selectedPeriod),
                initialValue: selectedPeriod,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Period',
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                items: const <DropdownMenuItem<_ExpensePeriodFilter>>[
                  DropdownMenuItem<_ExpensePeriodFilter>(
                    value: _ExpensePeriodFilter.all,
                    child: Text(
                      'All time',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_ExpensePeriodFilter>(
                    value: _ExpensePeriodFilter.thisWeek,
                    child: Text(
                      'This week',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_ExpensePeriodFilter>(
                    value: _ExpensePeriodFilter.thisMonth,
                    child: Text(
                      'This month',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (_ExpensePeriodFilter? value) {
                  if (value != null) {
                    onPeriodChanged(value);
                  }
                },
              ),
            ),
            SizedBox(
              width: 230,
              child: DropdownButtonFormField<_ExpenseSort>(
                key: ValueKey<_ExpenseSort>(selectedSort),
                initialValue: selectedSort,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Sort',
                  prefixIcon: Icon(Icons.swap_vert),
                ),
                items: const <DropdownMenuItem<_ExpenseSort>>[
                  DropdownMenuItem<_ExpenseSort>(
                    value: _ExpenseSort.newest,
                    child: Text(
                      'Newest first',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_ExpenseSort>(
                    value: _ExpenseSort.oldest,
                    child: Text(
                      'Oldest first',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_ExpenseSort>(
                    value: _ExpenseSort.highestAmount,
                    child: Text(
                      'Highest amount',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_ExpenseSort>(
                    value: _ExpenseSort.lowestAmount,
                    child: Text(
                      'Lowest amount',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (_ExpenseSort? value) {
                  if (value != null) {
                    onSortChanged(value);
                  }
                },
              ),
            ),
            TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopExpenseTable extends StatelessWidget {
  const _DesktopExpenseTable({
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Expense> expenses;
  final ValueChanged<Expense> onEdit;
  final ValueChanged<Expense> onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 54,
          dataRowMinHeight: 62,
          dataRowMaxHeight: 70,
          headingTextStyle: TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          columns: const <DataColumn>[
            DataColumn(label: Text('Expense')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Date')),
            DataColumn(numeric: true, label: Text('Amount')),
            DataColumn(label: Text('')),
          ],
          rows: <DataRow>[
            for (final Expense expense in expenses) _buildRow(context, expense),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, Expense expense) {
    final ExpenseCategoryOption category = expenseCategoryById(
      expense.categoryId,
    );

    final ColorScheme colors = Theme.of(context).colorScheme;

    return DataRow(
      cells: <DataCell>[
        DataCell(
          SizedBox(
            width: 260,
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, size: 19, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 140,
            child: Text(category.label, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(
          SizedBox(
            width: 170,
            child: Text(
              DateFormat(
                'dd MMM yyyy, h:mm a',
              ).format(expense.occurredAt.toLocal()),
            ),
          ),
        ),
        DataCell(
          Text(
            MoneyUtils.formatMinorUnits(
              expense.amountMinor,
              currencyCode: expense.currencyCode,
              scale: expense.currencyScale,
            ),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        DataCell(
          PopupMenuButton<String>(
            tooltip: 'Expense actions',
            onSelected: (String action) {
              if (action == 'edit') {
                onEdit(expense);
              } else if (action == 'delete') {
                onDelete(expense);
              }
            },
            itemBuilder: (BuildContext context) {
              return const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_outline),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ];
            },
          ),
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
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(category.icon, color: colors.primary),
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
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                MoneyUtils.formatMinorUnits(
                  expense.amountMinor,
                  currencyCode: expense.currencyCode,
                  scale: expense.currencyScale,
                ),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Expense actions',
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
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
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

class _NoFilteredExpenses extends StatelessWidget {
  const _NoFilteredExpenses({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.search_off_outlined,
              size: 46,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              'No matching expenses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing the search term, category, or period filter.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear filters'),
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 34,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Start tracking expenses',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record your first expense to begin building your '
                    'financial history, budgets and analytics.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
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
                        label: const Text('Add expense'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onManageSettings,
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('Set budgets'),
                      ),
                    ],
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
                    'Could not load expenses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 18),
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

int _sumExpenses(List<Expense> expenses) {
  int totalMinor = 0;

  for (final Expense expense in expenses) {
    totalMinor += expense.amountMinor;
  }

  return totalMinor;
}

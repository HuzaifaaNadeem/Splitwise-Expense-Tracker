import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/currency/default_currency_controller.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/presentation/controllers/category_controller.dart';
import '../../../expenses/presentation/controllers/expense_controller.dart';
import '../../domain/entities/financial_statement.dart';
import '../../domain/services/financial_statement_builder.dart';
import '../services/financial_statement_pdf_service.dart';

class FinancialStatementScreen extends ConsumerStatefulWidget {
  const FinancialStatementScreen({super.key});

  @override
  ConsumerState<FinancialStatementScreen> createState() =>
      _FinancialStatementScreenState();
}

class _FinancialStatementScreenState
    extends ConsumerState<FinancialStatementScreen> {
  static const FinancialStatementBuilder _builder = FinancialStatementBuilder();
  static const FinancialStatementPdfService _pdfService =
      FinancialStatementPdfService();

  FinancialStatementPeriod _period = FinancialStatementPeriod.monthly;
  late int _selectedYear;
  late int _selectedMonth;
  String? _currencyCode;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();

    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Expense>> expensesAsync = ref.watch(
      expenseControllerProvider,
    );
    final AsyncValue<List<ExpenseCategory>> categoriesAsync = ref.watch(
      categoryControllerProvider,
    );
    final AppCurrency defaultCurrency = ref.watch(
      defaultCurrencyControllerProvider,
    );

    final AppCurrency selectedCurrency = AppCurrency.fromCode(
      _currencyCode ?? defaultCurrency.code,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Statement')),
      body: SafeArea(
        child: expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) {
            return _LoadError(
              onRetry: () {
                unawaited(
                  ref.read(expenseControllerProvider.notifier).refresh(),
                );
              },
            );
          },
          data: (List<Expense> expenses) {
            final List<ExpenseCategory> categories =
                categoriesAsync.value ?? const <ExpenseCategory>[];

            final Map<String, String> categoryNames = <String, String>{
              for (final ExpenseCategory category in categories)
                category.id: category.name,
            };

            final FinancialStatement statement = _builder.build(
              expenses: expenses,
              categoryNames: categoryNames,
              period: _period,
              year: _selectedYear,
              month: _period == FinancialStatementPeriod.monthly
                  ? _selectedMonth
                  : null,
              currencyCode: selectedCurrency.code,
              currencyScale: selectedCurrency.scale,
            );

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double contentWidth = constraints.maxWidth > 900
                    ? 860
                    : constraints.maxWidth;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _Header(statement: statement),
                            const SizedBox(height: 22),
                            _StatementOptions(
                              period: _period,
                              selectedYear: _selectedYear,
                              selectedMonth: _selectedMonth,
                              currency: selectedCurrency,
                              onPeriodChanged: _changePeriod,
                              onYearChanged: (int value) {
                                setState(() {
                                  _selectedYear = value;
                                  _normalizeMonthForYear();
                                });
                              },
                              onMonthChanged: (int value) {
                                setState(() {
                                  _selectedMonth = value;
                                });
                              },
                              onCurrencyChanged: (String code) {
                                setState(() {
                                  _currencyCode = code;
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            _StatementPreview(statement: statement),
                            const SizedBox(height: 18),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.info_outline,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'The PDF uses only records stored in '
                                        'the selected currency. Existing '
                                        'transactions are never converted or '
                                        'relabeled.',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              key: const Key(
                                'generate_financial_statement_button',
                              ),
                              onPressed: _isGenerating
                                  ? null
                                  : () {
                                      unawaited(_generate(statement));
                                    },
                              icon: _isGenerating
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf_outlined),
                              label: Text(
                                _isGenerating
                                    ? 'Preparing statement...'
                                    : 'Generate PDF Statement',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _changePeriod(FinancialStatementPeriod period) {
    final DateTime now = DateTime.now();

    setState(() {
      _period = period;
      _selectedYear = now.year;

      if (period == FinancialStatementPeriod.monthly) {
        _selectedMonth = now.month;
      }
    });
  }

  void _normalizeMonthForYear() {
    final DateTime now = DateTime.now();

    if (_selectedYear == now.year && _selectedMonth > now.month) {
      _selectedMonth = now.month;
    }
  }

  Future<void> _generate(FinancialStatement statement) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await _pdfService.generate(statement);
    } on Object {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to generate the financial statement.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.statement});

  final FinancialStatement statement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Personal Financial Statement',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Generate a professional PDF statement for any current or previous month or year.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatementOptions extends StatelessWidget {
  const _StatementOptions({
    required this.period,
    required this.selectedYear,
    required this.selectedMonth,
    required this.currency,
    required this.onPeriodChanged,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onCurrencyChanged,
  });

  final FinancialStatementPeriod period;
  final int selectedYear;
  final int selectedMonth;
  final AppCurrency currency;
  final ValueChanged<FinancialStatementPeriod> onPeriodChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final List<int> years = List<int>.generate(
      10,
      (int index) => now.year - index,
      growable: false,
    );

    final int maxMonth = selectedYear == now.year ? now.month : 12;

    final List<int> months = List<int>.generate(
      maxMonth,
      (int index) => index + 1,
      growable: false,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Statement options',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            SegmentedButton<FinancialStatementPeriod>(
              segments: const <ButtonSegment<FinancialStatementPeriod>>[
                ButtonSegment<FinancialStatementPeriod>(
                  value: FinancialStatementPeriod.monthly,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Monthly'),
                ),
                ButtonSegment<FinancialStatementPeriod>(
                  value: FinancialStatementPeriod.yearly,
                  icon: Icon(Icons.calendar_today_outlined),
                  label: Text('Yearly'),
                ),
              ],
              selected: <FinancialStatementPeriod>{period},
              onSelectionChanged: (Set<FinancialStatementPeriod> selected) {
                onPeriodChanged(selected.first);
              },
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: <Widget>[
                if (period == FinancialStatementPeriod.monthly)
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<int>(
                      key: ValueKey<String>(
                        'statement-month-$selectedYear-$selectedMonth',
                      ),
                      initialValue: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        prefixIcon: Icon(Icons.date_range_outlined),
                      ),
                      items: months
                          .map(
                            (int month) => DropdownMenuItem<int>(
                              value: month,
                              child: Text(financialStatementMonthName(month)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (int? value) {
                        if (value != null) {
                          onMonthChanged(value);
                        }
                      },
                    ),
                  ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<int>(
                    key: ValueKey<String>(
                      'statement-year-$period-$selectedYear',
                    ),
                    initialValue: selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    items: years
                        .map(
                          (int year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (int? value) {
                      if (value != null) {
                        onYearChanged(value);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey<String>(
                      'statement-currency-${currency.code}',
                    ),
                    initialValue: currency.code,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    items: AppCurrency.supported
                        .map(
                          (AppCurrency value) => DropdownMenuItem<String>(
                            value: value.code,
                            child: Text(
                              value.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    selectedItemBuilder: (BuildContext context) {
                      return AppCurrency.supported
                          .map(
                            (AppCurrency value) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false);
                    },
                    onChanged: (String? value) {
                      if (value != null) {
                        onCurrencyChanged(value);
                      }
                    },
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

class _StatementPreview extends StatelessWidget {
  const _StatementPreview({required this.statement});

  final FinancialStatement statement;

  @override
  Widget build(BuildContext context) {
    final String income = _money(statement.totalIncomeMinor);
    final String expenses = _money(statement.totalExpenseMinor);
    final String net = _money(statement.netPositionMinor);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Statement preview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${statement.periodLabel} | ${statement.currencyCode}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: Text(
                    '${statement.transactionCount} '
                    '${statement.transactionCount == 1 ? 'transaction' : 'transactions'}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth >= 650) {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: _Metric(
                          label: 'Income',
                          value: income,
                          icon: Icons.south_west,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: 'Expenses',
                          value: expenses,
                          icon: Icons.north_east,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: 'Net position',
                          value: net,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    _Metric(
                      label: 'Income',
                      value: income,
                      icon: Icons.south_west,
                    ),
                    const SizedBox(height: 10),
                    _Metric(
                      label: 'Expenses',
                      value: expenses,
                      icon: Icons.north_east,
                    ),
                    const SizedBox(height: 10),
                    _Metric(
                      label: 'Net position',
                      value: net,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ],
                );
              },
            ),
            if (statement.transactionCount == 0) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'No transactions were found for this period and currency. '
                  'Choose another month, year, or currency if your saved '
                  'transactions were recorded elsewhere.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _money(int amountMinor) {
    return MoneyUtils.formatMinorUnits(
      amountMinor,
      currencyCode: statement.currencyCode,
      scale: statement.currencyScale,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 14),
            const Text(
              'Unable to load transactions for the statement.',
              textAlign: TextAlign.center,
            ),
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

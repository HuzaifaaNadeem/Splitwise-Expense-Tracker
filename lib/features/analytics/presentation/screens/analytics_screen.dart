import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/currency/default_currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/presentation/controllers/category_controller.dart';
import '../../../expenses/presentation/controllers/expense_controller.dart';
import '../../../expenses/presentation/models/category_visuals.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/entities/category_spending.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Expense>> expensesState = ref.watch(
      expenseControllerProvider,
    );

    final AsyncValue<List<ExpenseCategory>> categoriesState = ref.watch(
      categoryControllerProvider,
    );

    if (expensesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expensesState.hasError) {
      return _AnalyticsError(
        message: 'Could not load expense analytics.',
        onRetry: () {
          unawaited(ref.read(expenseControllerProvider.notifier).refresh());
        },
      );
    }

    final AppCurrency currency = ref.watch(defaultCurrencyControllerProvider);

    final AnalyticsSnapshot snapshot = ref.watch(analyticsSnapshotProvider);

    final List<ExpenseCategory> categories =
        categoriesState.value ?? const <ExpenseCategory>[];

    final Map<String, ExpenseCategory> categoryMap = <String, ExpenseCategory>{
      for (final ExpenseCategory category in categories) category.id: category,
    };

    final DateTime now = DateTime.now();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 950;

        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
          children: <Widget>[
            _AnalyticsHeader(
              month: DateFormat('MMMM yyyy').format(now),
              currency: currency,
            ),
            const SizedBox(height: 26),
            _SummaryCards(snapshot: snapshot, currency: currency),
            const SizedBox(height: 28),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _CategoryChartCard(
                      snapshot: snapshot,
                      categoryMap: categoryMap,
                      currency: currency,
                      touchedIndex: _touchedPieIndex,
                      onTouchedIndexChanged: (int value) {
                        setState(() {
                          _touchedPieIndex = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _ComparisonChartCard(
                      snapshot: snapshot,
                      currency: currency,
                    ),
                  ),
                ],
              )
            else ...<Widget>[
              _CategoryChartCard(
                snapshot: snapshot,
                categoryMap: categoryMap,
                currency: currency,
                touchedIndex: _touchedPieIndex,
                onTouchedIndexChanged: (int value) {
                  setState(() {
                    _touchedPieIndex = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              _ComparisonChartCard(snapshot: snapshot, currency: currency),
            ],
          ],
        );
      },
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.month, required this.currency});

  final String month;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Financial Analytics',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Understand spending patterns, income and financial performance.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '$month â€¢ ${currency.code}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.snapshot, required this.currency});

  final AnalyticsSnapshot snapshot;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        _SummaryCard(
          icon: Icons.calendar_view_week_outlined,
          title: 'Weekly Expenses',
          value: MoneyUtils.formatMinorUnits(
            snapshot.weekly.expenseMinor,
            currencyCode: currency.code,
            scale: currency.scale,
          ),
          tone: _SummaryTone.neutral,
        ),
        _SummaryCard(
          icon: Icons.savings_outlined,
          title: 'Weekly Income',
          value: MoneyUtils.formatMinorUnits(
            snapshot.weekly.incomeMinor,
            currencyCode: currency.code,
            scale: currency.scale,
          ),
          tone: _SummaryTone.positive,
        ),
        _SummaryCard(
          icon: Icons.calendar_month_outlined,
          title: 'Monthly Expenses',
          value: MoneyUtils.formatMinorUnits(
            snapshot.monthly.expenseMinor,
            currencyCode: currency.code,
            scale: currency.scale,
          ),
          tone: _SummaryTone.neutral,
        ),
        _SummaryCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Monthly Income',
          value: MoneyUtils.formatMinorUnits(
            snapshot.monthly.incomeMinor,
            currencyCode: currency.code,
            scale: currency.scale,
          ),
          tone: _SummaryTone.positive,
        ),
        _SummaryCard(
          icon: Icons.trending_up_outlined,
          title: 'Monthly Net',
          value: MoneyUtils.formatMinorUnits(
            snapshot.monthly.netMinor,
            currencyCode: currency.code,
            scale: currency.scale,
          ),
          tone: snapshot.monthly.netMinor >= 0
              ? _SummaryTone.positive
              : _SummaryTone.negative,
        ),
      ],
    );
  }
}

enum _SummaryTone { neutral, positive, negative }

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final _SummaryTone tone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color accent = switch (tone) {
      _SummaryTone.neutral => colors.primary,
      _SummaryTone.positive => AppColors.positive,
      _SummaryTone.negative => AppColors.danger,
    };

    return SizedBox(
      width: 230,
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
                  color: accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: accent),
              ),
              const SizedBox(height: 18),
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
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChartCard extends StatelessWidget {
  const _CategoryChartCard({
    required this.snapshot,
    required this.categoryMap,
    required this.currency,
    required this.touchedIndex,
    required this.onTouchedIndexChanged,
  });

  final AnalyticsSnapshot snapshot;
  final Map<String, ExpenseCategory> categoryMap;
  final AppCurrency currency;
  final int touchedIndex;
  final ValueChanged<int> onTouchedIndexChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<CategorySpending> spending = snapshot.categorySpending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.donut_large_outlined,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Spending by Category',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Current month',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (spending.isEmpty)
              const SizedBox(
                height: 310,
                child: _ChartEmptyState(
                  icon: Icons.donut_large_outlined,
                  message:
                      'Add expenses this month to see your category breakdown.',
                ),
              )
            else ...<Widget>[
              SizedBox(
                height: 310,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 72,
                        sectionsSpace: 3,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, PieTouchResponse? response) {
                                if (!event.isInterestedForInteractions ||
                                    response?.touchedSection == null) {
                                  onTouchedIndexChanged(-1);
                                  return;
                                }

                                onTouchedIndexChanged(
                                  response!.touchedSection!.touchedSectionIndex,
                                );
                              },
                        ),
                        sections: _buildPieSections(context, spending),
                      ),
                      duration: const Duration(milliseconds: 250),
                    ),
                    IgnorePointer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Total spent',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            MoneyUtils.formatMinorUnits(
                              snapshot.monthly.expenseMinor,
                              currencyCode: currency.code,
                              scale: currency.scale,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              for (int index = 0; index < spending.length; index++)
                _CategoryLegendItem(
                  spending: spending[index],
                  category: categoryMap[spending[index].categoryId],
                  color: _categoryColor(context, spending[index].categoryId),
                  isSelected: index == touchedIndex,
                  totalMinor: snapshot.monthly.expenseMinor,
                  currency: currency,
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    BuildContext context,
    List<CategorySpending> spending,
  ) {
    final int total = spending.fold<int>(0, (
      int current,
      CategorySpending item,
    ) {
      return current + item.amountMinor;
    });

    return List<PieChartSectionData>.generate(spending.length, (int index) {
      final CategorySpending item = spending[index];

      final bool touched = touchedIndex == index;

      final double percentage = total == 0 ? 0 : item.amountMinor / total * 100;

      return PieChartSectionData(
        value: item.amountMinor.toDouble(),
        color: _categoryColor(context, item.categoryId),
        radius: touched ? 72 : 62,
        showTitle: percentage >= 7,
        title: '${percentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        titlePositionPercentageOffset: 0.58,
        cornerRadius: 3,
      );
    }, growable: false);
  }

  Color _categoryColor(BuildContext context, String categoryId) {
    final ExpenseCategory? category = categoryMap[categoryId];

    if (category != null) {
      return Color(category.colorValue);
    }

    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<Color> fallbackColors = <Color>[
      colors.primary,
      colors.secondary,
      colors.tertiary,
      AppColors.information,
      AppColors.positive,
      AppColors.warning,
    ];

    final int index = categoryId.hashCode.abs() % fallbackColors.length;

    return fallbackColors[index];
  }
}

class _CategoryLegendItem extends StatelessWidget {
  const _CategoryLegendItem({
    required this.spending,
    required this.category,
    required this.color,
    required this.isSelected,
    required this.totalMinor,
    required this.currency,
  });

  final CategorySpending spending;
  final ExpenseCategory? category;
  final Color color;
  final bool isSelected;
  final int totalMinor;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double percentage = totalMinor == 0
        ? 0
        : spending.amountMinor / totalMinor * 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Icon(
            categoryIconFromCodePoint(
              category?.iconCodePoint ?? Icons.category_outlined.codePoint,
            ),
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category?.name ?? _readableCategoryId(spending.categoryId),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Text(
            MoneyUtils.formatMinorUnits(
              spending.amountMinor,
              currencyCode: currency.code,
              scale: currency.scale,
            ),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _readableCategoryId(String value) {
    if (value.isEmpty) {
      return 'Other';
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _ComparisonChartCard extends StatelessWidget {
  const _ComparisonChartCard({required this.snapshot, required this.currency});

  final AnalyticsSnapshot snapshot;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double weeklyExpense = _toMajor(snapshot.weekly.expenseMinor);

    final double weeklyIncome = _toMajor(snapshot.weekly.incomeMinor);

    final double monthlyExpense = _toMajor(snapshot.monthly.expenseMinor);

    final double monthlyIncome = _toMajor(snapshot.monthly.incomeMinor);

    final double highest = _highest(<double>[
      weeklyExpense,
      weeklyIncome,
      monthlyExpense,
      monthlyIncome,
    ]);

    final double maxY = highest <= 0 ? 100 : highest * 1.25;

    final Color expenseColor = colors.primary;
    const Color incomeColor = AppColors.positive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.bar_chart_outlined, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Income vs Expenses',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Weekly and monthly comparison',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                _BarLegend(color: expenseColor, label: 'Expenses'),
                const SizedBox(width: 20),
                _BarLegend(color: incomeColor, label: 'Income'),
              ],
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 320,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (double value) {
                      return FlLine(
                        color: colors.outlineVariant.withValues(alpha: 0.55),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final String text = switch (value.toInt()) {
                            0 => 'Week',
                            1 => 'Month',
                            _ => '',
                          };

                          return SideTitleWidget(
                            meta: meta,
                            space: 10,
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 55,
                        interval: maxY / 4,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              NumberFormat.compact().format(value),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem:
                          (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            final String period = group.x == 0
                                ? 'Week'
                                : 'Month';

                            final String type = rodIndex == 0
                                ? 'Expenses'
                                : 'Income';

                            final int amountMinor = _toMinorUnits(rod.toY);

                            return BarTooltipItem(
                              '$period $type\n'
                              '${MoneyUtils.formatMinorUnits(amountMinor, currencyCode: currency.code, scale: currency.scale)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                    ),
                  ),
                  barGroups: <BarChartGroupData>[
                    _barGroup(
                      x: 0,
                      expense: weeklyExpense,
                      income: weeklyIncome,
                      expenseColor: expenseColor,
                    ),
                    _barGroup(
                      x: 1,
                      expense: monthlyExpense,
                      income: monthlyIncome,
                      expenseColor: expenseColor,
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),
            _NetSummary(
              label: 'Weekly net',
              amountMinor: snapshot.weekly.netMinor,
              currency: currency,
            ),
            const SizedBox(height: 10),
            _NetSummary(
              label: 'Monthly net',
              amountMinor: snapshot.monthly.netMinor,
              currency: currency,
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup({
    required int x,
    required double expense,
    required double income,
    required Color expenseColor,
  }) {
    return BarChartGroupData(
      x: x,
      barsSpace: 8,
      barRods: <BarChartRodData>[
        BarChartRodData(
          toY: expense,
          width: 23,
          color: expenseColor,
          borderRadius: BorderRadius.circular(6),
        ),
        BarChartRodData(
          toY: income,
          width: 23,
          color: AppColors.positive,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  double _toMajor(int amountMinor) {
    return amountMinor / _minorUnitDivisor();
  }

  int _toMinorUnits(double majorAmount) {
    return (majorAmount * _minorUnitDivisor()).round();
  }

  int _minorUnitDivisor() {
    int divisor = 1;

    for (int index = 0; index < currency.scale; index++) {
      divisor *= 10;
    }

    return divisor;
  }

  double _highest(List<double> values) {
    double highest = 0;

    for (final double value in values) {
      if (value > highest) {
        highest = value;
      }
    }

    return highest;
  }
}

class _BarLegend extends StatelessWidget {
  const _BarLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        Text(label),
      ],
    );
  }
}

class _NetSummary extends StatelessWidget {
  const _NetSummary({
    required this.label,
    required this.amountMinor,
    required this.currency,
  });

  final String label;
  final int amountMinor;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final Color color = amountMinor >= 0
        ? AppColors.positive
        : AppColors.danger;

    return Row(
      children: <Widget>[
        Expanded(child: Text(label)),
        Text(
          MoneyUtils.formatMinorUnits(
            amountMinor,
            currencyCode: currency.code,
            scale: currency.scale,
          ),
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, size: 30, color: colors.primary),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsError extends StatelessWidget {
  const _AnalyticsError({required this.message, required this.onRetry});

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
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.analytics_outlined, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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

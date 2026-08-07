import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

    final AnalyticsSnapshot snapshot = ref.watch(analyticsSnapshotProvider);

    final List<ExpenseCategory> categories =
        categoriesState.value ?? const <ExpenseCategory>[];

    final Map<String, ExpenseCategory> categoryMap = <String, ExpenseCategory>{
      for (final ExpenseCategory category in categories) category.id: category,
    };

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useWideLayout = constraints.maxWidth >= 950;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: <Widget>[
            Text(
              'Financial Analytics',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Current week and month • PKR',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _SummaryCards(snapshot: snapshot),
            const SizedBox(height: 24),
            if (useWideLayout)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _CategoryChartCard(
                      snapshot: snapshot,
                      categoryMap: categoryMap,
                      touchedIndex: _touchedPieIndex,
                      onTouchedIndexChanged: (int value) {
                        setState(() {
                          _touchedPieIndex = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(child: _ComparisonChartCard(snapshot: snapshot)),
                ],
              )
            else ...<Widget>[
              _CategoryChartCard(
                snapshot: snapshot,
                categoryMap: categoryMap,
                touchedIndex: _touchedPieIndex,
                onTouchedIndexChanged: (int value) {
                  setState(() {
                    _touchedPieIndex = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _ComparisonChartCard(snapshot: snapshot),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.snapshot});

  final AnalyticsSnapshot snapshot;

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
            currencyCode: 'PKR',
            scale: 2,
          ),
        ),
        _SummaryCard(
          icon: Icons.savings_outlined,
          title: 'Weekly Income',
          value: MoneyUtils.formatMinorUnits(
            snapshot.weekly.incomeMinor,
            currencyCode: 'PKR',
            scale: 2,
          ),
        ),
        _SummaryCard(
          icon: Icons.calendar_month_outlined,
          title: 'Monthly Expenses',
          value: MoneyUtils.formatMinorUnits(
            snapshot.monthly.expenseMinor,
            currencyCode: 'PKR',
            scale: 2,
          ),
        ),
        _SummaryCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Monthly Income',
          value: MoneyUtils.formatMinorUnits(
            snapshot.monthly.incomeMinor,
            currencyCode: 'PKR',
            scale: 2,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 225,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: colors.primary),
              const SizedBox(height: 18),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
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
    required this.touchedIndex,
    required this.onTouchedIndexChanged,
  });

  final AnalyticsSnapshot snapshot;
  final Map<String, ExpenseCategory> categoryMap;
  final int touchedIndex;
  final ValueChanged<int> onTouchedIndexChanged;

  @override
  Widget build(BuildContext context) {
    final List<CategorySpending> spending = snapshot.categorySpending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Spending by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Current month',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (spending.isEmpty)
              const SizedBox(
                height: 300,
                child: _ChartEmptyState(
                  icon: Icons.donut_large_outlined,
                  message:
                      'Add expenses this month to see your category breakdown.',
                ),
              )
            else ...<Widget>[
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 70,
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
                            'Total',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            MoneyUtils.formatMinorUnits(
                              snapshot.monthly.expenseMinor,
                              currencyCode: 'PKR',
                              scale: 2,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (int index = 0; index < spending.length; index++)
                _CategoryLegendItem(
                  spending: spending[index],
                  category: categoryMap[spending[index].categoryId],
                  color: _categoryColor(context, spending[index].categoryId),
                  isSelected: index == touchedIndex,
                  totalMinor: snapshot.monthly.expenseMinor,
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

      final bool isTouched = touchedIndex == index;

      final double percentage = total == 0
          ? 0
          : (item.amountMinor / total) * 100;

      return PieChartSectionData(
        value: item.amountMinor.toDouble(),
        color: _categoryColor(context, item.categoryId),
        radius: isTouched ? 72 : 62,
        showTitle: percentage >= 7,
        title: '${percentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
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

    final List<Color> fallbacks = <Color>[
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    final int index = categoryId.hashCode.abs() % fallbacks.length;

    return fallbacks[index];
  }
}

class _CategoryLegendItem extends StatelessWidget {
  const _CategoryLegendItem({
    required this.spending,
    required this.category,
    required this.color,
    required this.isSelected,
    required this.totalMinor,
  });

  final CategorySpending spending;
  final ExpenseCategory? category;
  final Color color;
  final bool isSelected;
  final int totalMinor;

  @override
  Widget build(BuildContext context) {
    final double percentage = totalMinor == 0
        ? 0
        : spending.amountMinor / totalMinor * 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 13,
            height: 13,
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text('${percentage.toStringAsFixed(1)}%'),
          const SizedBox(width: 12),
          Text(
            MoneyUtils.formatMinorUnits(
              spending.amountMinor,
              currencyCode: 'PKR',
              scale: 2,
            ),
            style: const TextStyle(fontWeight: FontWeight.w600),
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
  const _ComparisonChartCard({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Income vs Expenses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly and monthly comparison',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: <Widget>[
                _BarLegend(color: Colors.redAccent, label: 'Expenses'),
                SizedBox(width: 20),
                _BarLegend(color: Colors.green, label: 'Income'),
              ],
            ),
            const SizedBox(height: 24),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
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

                            final int amountMinor = (rod.toY * 100).round();

                            return BarTooltipItem(
                              '$period $type\n'
                              '${MoneyUtils.formatMinorUnits(amountMinor, currencyCode: 'PKR', scale: 2)}',
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
                    ),
                    _barGroup(
                      x: 1,
                      expense: monthlyExpense,
                      income: monthlyIncome,
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 16),
            _NetSummary(
              label: 'Weekly net',
              amountMinor: snapshot.weekly.netMinor,
            ),
            const SizedBox(height: 8),
            _NetSummary(
              label: 'Monthly net',
              amountMinor: snapshot.monthly.netMinor,
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
  }) {
    return BarChartGroupData(
      x: x,
      barsSpace: 8,
      barRods: <BarChartRodData>[
        BarChartRodData(
          toY: expense,
          width: 24,
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(6),
        ),
        BarChartRodData(
          toY: income,
          width: 24,
          color: Colors.green,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  double _toMajor(int amountMinor) {
    return amountMinor / 100;
  }

  double _highest(List<double> values) {
    double result = 0;

    for (final double value in values) {
      if (value > result) {
        result = value;
      }
    }

    return result;
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
          width: 12,
          height: 12,
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
  const _NetSummary({required this.label, required this.amountMinor});

  final String label;
  final int amountMinor;

  @override
  Widget build(BuildContext context) {
    final Color color = amountMinor >= 0
        ? Colors.green
        : Theme.of(context).colorScheme.error;

    return Row(
      children: <Widget>[
        Expanded(child: Text(label)),
        Text(
          MoneyUtils.formatMinorUnits(
            amountMinor,
            currencyCode: 'PKR',
            scale: 2,
          ),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 54,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.analytics_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
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

import 'package:equatable/equatable.dart';

import 'category_spending.dart';
import 'period_financial_summary.dart';

final class AnalyticsSnapshot extends Equatable {
  const AnalyticsSnapshot({
    required this.categorySpending,
    required this.weekly,
    required this.monthly,
  });

  final List<CategorySpending> categorySpending;
  final PeriodFinancialSummary weekly;
  final PeriodFinancialSummary monthly;

  int get monthlyExpenseMinor => monthly.expenseMinor;

  int get monthlyIncomeMinor => monthly.incomeMinor;

  @override
  List<Object> get props => <Object>[categorySpending, weekly, monthly];
}

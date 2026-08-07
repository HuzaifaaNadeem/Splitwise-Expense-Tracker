import 'package:equatable/equatable.dart';

final class PeriodFinancialSummary extends Equatable {
  const PeriodFinancialSummary({
    required this.expenseMinor,
    required this.incomeMinor,
  });

  final int expenseMinor;
  final int incomeMinor;

  int get netMinor => incomeMinor - expenseMinor;

  @override
  List<Object> get props => <Object>[expenseMinor, incomeMinor];
}

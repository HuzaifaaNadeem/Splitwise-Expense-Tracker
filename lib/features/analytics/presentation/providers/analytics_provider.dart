import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/currency/default_currency_controller.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/controllers/expense_controller.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/services/analytics_calculator.dart';

part 'analytics_provider.g.dart';

@riverpod
AnalyticsSnapshot analyticsSnapshot(AnalyticsSnapshotRef ref) {
  final AppCurrency currency = ref.watch(defaultCurrencyControllerProvider);

  final List<Expense> entries =
      ref.watch(expenseControllerProvider).value ?? const <Expense>[];

  final List<Expense> selectedCurrencyEntries = entries
      .where(
        (Expense expense) =>
            expense.currencyCode.toUpperCase() == currency.code &&
            expense.currencyScale == currency.scale,
      )
      .toList(growable: false);

  return const AnalyticsCalculator().calculate(
    entries: selectedCurrencyEntries,
  );
}

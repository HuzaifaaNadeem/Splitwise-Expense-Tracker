import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/controllers/expense_controller.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/services/analytics_calculator.dart';

part 'analytics_provider.g.dart';

@riverpod
AnalyticsSnapshot analyticsSnapshot(AnalyticsSnapshotRef ref) {
  final List<Expense> entries =
      ref.watch(expenseControllerProvider).value ?? const <Expense>[];

  return const AnalyticsCalculator().calculate(entries: entries);
}

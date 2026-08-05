import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/budget.dart';
import '../providers/category_budget_providers.dart';

part 'budget_controller.g.dart';

@riverpod
class BudgetController extends _$BudgetController {
  @override
  Future<List<Budget>> build() {
    return _loadBudgets();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Budget>>();

    state = await AsyncValue.guard(_loadBudgets);
  }

  Future<Result<Budget>> saveBudget({
    required BudgetPeriod period,
    required int amountMinor,
    String currencyCode = 'PKR',
    int currencyScale = 2,
  }) async {
    final DateTime now = DateTime.now().toUtc();

    final Budget budget = Budget(
      id: period == BudgetPeriod.weekly ? 'budget-weekly' : 'budget-monthly',
      period: period,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      currencyScale: currencyScale,
      isActive: true,
      revision: 1,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(budgetRepositoryProvider).save(budget);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<Result<bool>> deleteBudget(BudgetPeriod period) async {
    final result = await ref.read(budgetRepositoryProvider).delete(period);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<List<Budget>> _loadBudgets() async {
    final result = await ref.read(budgetRepositoryProvider).getAllActive();

    return result.fold(
      onSuccess: (List<Budget> budgets) => budgets,
      onFailure: (failure) {
        throw StateError(failure.message);
      },
    );
  }
}

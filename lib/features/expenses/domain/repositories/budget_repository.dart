import '../../../../core/errors/result.dart';
import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Future<Result<List<Budget>>> getAllActive();

  Future<Result<Budget?>> getByPeriod(BudgetPeriod period);

  Future<Result<Budget>> save(Budget budget);

  Future<Result<bool>> delete(BudgetPeriod period);
}

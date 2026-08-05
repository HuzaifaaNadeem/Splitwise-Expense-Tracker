import '../../../../core/errors/result.dart';
import '../entities/expense_category.dart';

abstract interface class CategoryRepository {
  Future<Result<List<ExpenseCategory>>> getAllActive();

  Future<Result<ExpenseCategory>> create(ExpenseCategory category);

  Future<Result<ExpenseCategory>> update(ExpenseCategory category);

  Future<Result<bool>> delete(String id);

  Future<Result<void>> ensureDefaults(List<ExpenseCategory> categories);
}

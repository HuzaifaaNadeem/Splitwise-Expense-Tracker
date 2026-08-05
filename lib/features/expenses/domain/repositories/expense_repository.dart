import '../../../../core/errors/result.dart';
import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  Future<Result<Expense>> create(Expense expense);

  Future<Result<Expense?>> getById(String id);

  Future<Result<List<Expense>>> getAllActive();

  Future<Result<Expense>> update(Expense expense);

  Future<Result<bool>> delete(String id);
}

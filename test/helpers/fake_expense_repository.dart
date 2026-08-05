import 'package:splitwise_expense_tracker/core/errors/failure.dart';
import 'package:splitwise_expense_tracker/core/errors/result.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

final class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository([Iterable<Expense> expenses = const <Expense>[]])
    : _expenses = List<Expense>.from(expenses);

  final List<Expense> _expenses;

  List<Expense> get storedExpenses => List<Expense>.unmodifiable(_expenses);

  @override
  Future<Result<Expense>> create(Expense expense) async {
    if (_expenses.any((Expense item) => item.id == expense.id)) {
      return const FailureResult<Expense>(
        ValidationFailure(message: 'Expense already exists.'),
      );
    }

    _expenses.add(expense);

    return Success<Expense>(expense);
  }

  @override
  Future<Result<bool>> delete(String id) async {
    final int index = _expenses.indexWhere((Expense item) => item.id == id);

    if (index == -1) {
      return const FailureResult<bool>(
        ValidationFailure(message: 'Expense does not exist.'),
      );
    }

    _expenses.removeAt(index);

    return const Success<bool>(true);
  }

  @override
  Future<Result<List<Expense>>> getAllActive() async {
    final List<Expense> result = List<Expense>.from(_expenses)
      ..sort((Expense first, Expense second) {
        return second.occurredAt.compareTo(first.occurredAt);
      });

    return Success<List<Expense>>(result);
  }

  @override
  Future<Result<Expense?>> getById(String id) async {
    for (final Expense expense in _expenses) {
      if (expense.id == id) {
        return Success<Expense?>(expense);
      }
    }

    return const Success<Expense?>(null);
  }

  @override
  Future<Result<Expense>> update(Expense expense) async {
    final int index = _expenses.indexWhere(
      (Expense item) => item.id == expense.id,
    );

    if (index == -1) {
      return const FailureResult<Expense>(
        ValidationFailure(message: 'Expense does not exist.'),
      );
    }

    _expenses[index] = expense;

    return Success<Expense>(expense);
  }
}

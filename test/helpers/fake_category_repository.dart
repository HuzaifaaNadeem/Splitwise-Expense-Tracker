import 'package:splitwise_expense_tracker/core/errors/failure.dart';
import 'package:splitwise_expense_tracker/core/errors/result.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/repositories/category_repository.dart';

final class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository([
    Iterable<ExpenseCategory> categories = const <ExpenseCategory>[],
  ]) : _categories = List<ExpenseCategory>.from(categories);

  final List<ExpenseCategory> _categories;

  @override
  Future<Result<List<ExpenseCategory>>> getAllActive() async {
    final List<ExpenseCategory> result =
        _categories
            .where(
              (ExpenseCategory category) =>
                  category.isActive && category.deletedAt == null,
            )
            .toList(growable: false)
          ..sort((ExpenseCategory first, ExpenseCategory second) {
            return first.sortOrder.compareTo(second.sortOrder);
          });

    return Success<List<ExpenseCategory>>(result);
  }

  @override
  Future<Result<ExpenseCategory>> create(ExpenseCategory category) async {
    if (_categories.any(
      (ExpenseCategory existing) => existing.id == category.id,
    )) {
      return const FailureResult<ExpenseCategory>(
        ValidationFailure(message: 'Category already exists.'),
      );
    }

    _categories.add(category);

    return Success<ExpenseCategory>(category);
  }

  @override
  Future<Result<ExpenseCategory>> update(ExpenseCategory category) async {
    final int index = _categories.indexWhere(
      (ExpenseCategory existing) => existing.id == category.id,
    );

    if (index == -1) {
      return const FailureResult<ExpenseCategory>(
        ValidationFailure(message: 'Category does not exist.'),
      );
    }

    _categories[index] = category;

    return Success<ExpenseCategory>(category);
  }

  @override
  Future<Result<bool>> delete(String id) async {
    final int index = _categories.indexWhere(
      (ExpenseCategory category) => category.id == id,
    );

    if (index == -1) {
      return const FailureResult<bool>(
        ValidationFailure(message: 'Category does not exist.'),
      );
    }

    if (_categories[index].isDefault) {
      return const FailureResult<bool>(
        ValidationFailure(message: 'Default categories cannot be deleted.'),
      );
    }

    _categories.removeAt(index);

    return const Success<bool>(true);
  }

  @override
  Future<Result<void>> ensureDefaults(List<ExpenseCategory> categories) async {
    for (final ExpenseCategory category in categories) {
      final bool exists = _categories.any(
        (ExpenseCategory existing) => existing.id == category.id,
      );

      if (!exists) {
        _categories.add(category);
      }
    }

    return const Success<void>(null);
  }
}

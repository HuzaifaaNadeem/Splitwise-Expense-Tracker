import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../mappers/expense_mapper.dart';

final class IsarExpenseRepository implements ExpenseRepository {
  const IsarExpenseRepository({required this.localDataSource});

  final ExpenseLocalDataSource localDataSource;

  @override
  Future<Result<Expense>> create(Expense expense) async {
    final ValidationFailure? validationFailure = _validate(expense);

    if (validationFailure != null) {
      return FailureResult<Expense>(validationFailure);
    }

    try {
      final existing = await localDataSource.findByLocalId(expense.id);

      if (existing != null) {
        return const FailureResult<Expense>(
          ValidationFailure(message: 'An expense with this id already exists.'),
        );
      }

      final DateTime now = DateTime.now().toUtc();

      final Expense normalized = expense.copyWith(
        title: expense.title.trim(),
        currencyCode: expense.currencyCode.toUpperCase(),
        categoryId: expense.categoryId.trim(),
        occurredAt: expense.occurredAt.toUtc(),
        revision: 1,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );

      final storedModel = await localDataSource.insert(
        ExpenseMapper.toModel(normalized),
      );

      return Success<Expense>(ExpenseMapper.toDomain(storedModel));
    } on Object catch (error) {
      return FailureResult<Expense>(
        DatabaseFailure(message: 'Unable to create expense.', cause: error),
      );
    }
  }

  @override
  Future<Result<Expense?>> getById(String id) async {
    if (id.trim().isEmpty) {
      return const FailureResult<Expense?>(
        ValidationFailure(message: 'Expense id cannot be empty.'),
      );
    }

    try {
      final model = await localDataSource.findByLocalId(id);

      if (model == null || model.deletedAt != null) {
        return const Success<Expense?>(null);
      }

      return Success<Expense?>(ExpenseMapper.toDomain(model));
    } on Object catch (error) {
      return FailureResult<Expense?>(
        DatabaseFailure(message: 'Unable to load expense.', cause: error),
      );
    }
  }

  @override
  Future<Result<List<Expense>>> getAllActive() async {
    try {
      final models = await localDataSource.findAllActive();

      final List<Expense> expenses = models
          .map(ExpenseMapper.toDomain)
          .toList(growable: false);

      return Success<List<Expense>>(expenses);
    } on Object catch (error) {
      return FailureResult<List<Expense>>(
        DatabaseFailure(message: 'Unable to load expenses.', cause: error),
      );
    }
  }

  @override
  Future<Result<Expense>> update(Expense expense) async {
    final ValidationFailure? validationFailure = _validate(expense);

    if (validationFailure != null) {
      return FailureResult<Expense>(validationFailure);
    }

    try {
      final existing = await localDataSource.findByLocalId(expense.id);

      if (existing == null || existing.deletedAt != null) {
        return const FailureResult<Expense>(
          ValidationFailure(message: 'Expense does not exist.'),
        );
      }

      final Expense normalized = expense.copyWith(
        title: expense.title.trim(),
        currencyCode: expense.currencyCode.toUpperCase(),
        categoryId: expense.categoryId.trim(),
        occurredAt: expense.occurredAt.toUtc(),
        revision: existing.revision + 1,
        createdAt: existing.createdAt.toUtc(),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: null,
      );

      final updatedModel = await localDataSource.update(
        ExpenseMapper.toModel(normalized, databaseId: existing.id),
      );

      return Success<Expense>(ExpenseMapper.toDomain(updatedModel));
    } on Object catch (error) {
      return FailureResult<Expense>(
        DatabaseFailure(message: 'Unable to update expense.', cause: error),
      );
    }
  }

  @override
  Future<Result<bool>> delete(String id) async {
    if (id.trim().isEmpty) {
      return const FailureResult<bool>(
        ValidationFailure(message: 'Expense id cannot be empty.'),
      );
    }

    try {
      final bool deleted = await localDataSource.softDelete(id);

      if (!deleted) {
        return const FailureResult<bool>(
          ValidationFailure(message: 'Expense does not exist.'),
        );
      }

      return const Success<bool>(true);
    } on Object catch (error) {
      return FailureResult<bool>(
        DatabaseFailure(message: 'Unable to delete expense.', cause: error),
      );
    }
  }

  ValidationFailure? _validate(Expense expense) {
    if (expense.id.trim().isEmpty) {
      return const ValidationFailure(message: 'Expense id cannot be empty.');
    }

    if (expense.title.trim().isEmpty) {
      return const ValidationFailure(message: 'Expense title cannot be empty.');
    }

    if (expense.amountMinor <= 0) {
      return const ValidationFailure(
        message: 'Amount must be greater than zero.',
      );
    }

    if (!RegExp(r'^[A-Za-z]{3}$').hasMatch(expense.currencyCode)) {
      return const ValidationFailure(
        message: 'Currency code must contain three letters.',
      );
    }

    if (expense.currencyScale < 0 || expense.currencyScale > 3) {
      return const ValidationFailure(
        message: 'Currency scale must be between 0 and 3.',
      );
    }

    if (expense.categoryId.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Expense category cannot be empty.',
      );
    }

    return null;
  }
}

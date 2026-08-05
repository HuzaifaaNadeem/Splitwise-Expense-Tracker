import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../mappers/category_mapper.dart';

final class IsarCategoryRepository implements CategoryRepository {
  const IsarCategoryRepository({required this.localDataSource});

  final CategoryLocalDataSource localDataSource;

  @override
  Future<Result<List<ExpenseCategory>>> getAllActive() async {
    try {
      final models = await localDataSource.findAll();

      final List<ExpenseCategory> categories =
          models
              .where((model) => model.deletedAt == null && model.isActive)
              .map(CategoryMapper.toDomain)
              .toList(growable: false)
            ..sort((ExpenseCategory first, ExpenseCategory second) {
              final int order = first.sortOrder.compareTo(second.sortOrder);

              if (order != 0) {
                return order;
              }

              return first.name.compareTo(second.name);
            });

      return Success<List<ExpenseCategory>>(categories);
    } on Object catch (error) {
      return FailureResult<List<ExpenseCategory>>(
        DatabaseFailure(message: 'Unable to load categories.', cause: error),
      );
    }
  }

  @override
  Future<Result<ExpenseCategory>> create(ExpenseCategory category) async {
    final ValidationFailure? failure = _validate(category);

    if (failure != null) {
      return FailureResult<ExpenseCategory>(failure);
    }

    try {
      final existing = await localDataSource.findByLocalId(category.id);

      if (existing != null) {
        return const FailureResult<ExpenseCategory>(
          ValidationFailure(message: 'Category already exists.'),
        );
      }

      final DateTime now = DateTime.now().toUtc();

      final ExpenseCategory normalized = category.copyWith(
        name: category.name.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final model = await localDataSource.save(
        CategoryMapper.toModel(normalized),
      );

      return Success<ExpenseCategory>(CategoryMapper.toDomain(model));
    } on Object catch (error) {
      return FailureResult<ExpenseCategory>(
        DatabaseFailure(message: 'Unable to create category.', cause: error),
      );
    }
  }

  @override
  Future<Result<ExpenseCategory>> update(ExpenseCategory category) async {
    final ValidationFailure? failure = _validate(category);

    if (failure != null) {
      return FailureResult<ExpenseCategory>(failure);
    }

    try {
      final existing = await localDataSource.findByLocalId(category.id);

      if (existing == null || existing.deletedAt != null) {
        return const FailureResult<ExpenseCategory>(
          ValidationFailure(message: 'Category does not exist.'),
        );
      }

      final ExpenseCategory updated = category.copyWith(
        name: category.name.trim(),
        createdAt: existing.createdAt.toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      final model = await localDataSource.save(
        CategoryMapper.toModel(updated, databaseId: existing.id),
      );

      return Success<ExpenseCategory>(CategoryMapper.toDomain(model));
    } on Object catch (error) {
      return FailureResult<ExpenseCategory>(
        DatabaseFailure(message: 'Unable to update category.', cause: error),
      );
    }
  }

  @override
  Future<Result<bool>> delete(String id) async {
    if (id.trim().isEmpty) {
      return const FailureResult<bool>(
        ValidationFailure(message: 'Category id cannot be empty.'),
      );
    }

    try {
      final existing = await localDataSource.findByLocalId(id);

      if (existing == null || existing.deletedAt != null) {
        return const FailureResult<bool>(
          ValidationFailure(message: 'Category does not exist.'),
        );
      }

      if (existing.isDefault) {
        return const FailureResult<bool>(
          ValidationFailure(message: 'Default categories cannot be deleted.'),
        );
      }

      final DateTime now = DateTime.now().toUtc();

      existing
        ..isActive = false
        ..deletedAt = now
        ..updatedAt = now;

      await localDataSource.save(existing);

      return const Success<bool>(true);
    } on Object catch (error) {
      return FailureResult<bool>(
        DatabaseFailure(message: 'Unable to delete category.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> ensureDefaults(List<ExpenseCategory> categories) async {
    try {
      for (final ExpenseCategory category in categories) {
        final existing = await localDataSource.findByLocalId(category.id);

        if (existing != null) {
          continue;
        }

        await localDataSource.save(CategoryMapper.toModel(category));
      }

      return const Success<void>(null);
    } on Object catch (error) {
      return FailureResult<void>(
        DatabaseFailure(
          message: 'Unable to initialize default categories.',
          cause: error,
        ),
      );
    }
  }

  ValidationFailure? _validate(ExpenseCategory category) {
    if (category.id.trim().isEmpty) {
      return const ValidationFailure(message: 'Category id cannot be empty.');
    }

    if (category.name.trim().isEmpty) {
      return const ValidationFailure(message: 'Category name cannot be empty.');
    }

    if (category.name.trim().length > 40) {
      return const ValidationFailure(
        message: 'Category name cannot exceed 40 characters.',
      );
    }

    return null;
  }
}

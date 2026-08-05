import 'package:local_database/local_database.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';
import '../mappers/budget_mapper.dart';

final class IsarBudgetRepository implements BudgetRepository {
  const IsarBudgetRepository({required this.localDataSource});

  final BudgetLocalDataSource localDataSource;

  @override
  Future<Result<List<Budget>>> getAllActive() async {
    try {
      final models = await localDataSource.findAll();

      final List<Budget> budgets = models
          .where((model) => model.deletedAt == null && model.isActive)
          .map(BudgetMapper.toDomain)
          .toList(growable: false);

      return Success<List<Budget>>(budgets);
    } on Object catch (error) {
      return FailureResult<List<Budget>>(
        DatabaseFailure(message: 'Unable to load budgets.', cause: error),
      );
    }
  }

  @override
  Future<Result<Budget?>> getByPeriod(BudgetPeriod period) async {
    try {
      final model = await localDataSource.findByPeriod(
        _toDatabasePeriod(period),
      );

      return Success<Budget?>(
        model == null ? null : BudgetMapper.toDomain(model),
      );
    } on Object catch (error) {
      return FailureResult<Budget?>(
        DatabaseFailure(message: 'Unable to load budget.', cause: error),
      );
    }
  }

  @override
  Future<Result<Budget>> save(Budget budget) async {
    final ValidationFailure? basicFailure = _validate(budget);

    if (basicFailure != null) {
      return FailureResult<Budget>(basicFailure);
    }

    try {
      final BudgetPeriod oppositePeriod = budget.period == BudgetPeriod.weekly
          ? BudgetPeriod.monthly
          : BudgetPeriod.weekly;

      final oppositeModel = await localDataSource.findByPeriod(
        _toDatabasePeriod(oppositePeriod),
      );

      if (oppositeModel != null) {
        final Budget oppositeBudget = BudgetMapper.toDomain(oppositeModel);

        final ValidationFailure? relationshipFailure =
            _validateBudgetRelationship(
              budget: budget,
              oppositeBudget: oppositeBudget,
            );

        if (relationshipFailure != null) {
          return FailureResult<Budget>(relationshipFailure);
        }
      }

      final existing = await localDataSource.findByPeriod(
        _toDatabasePeriod(budget.period),
      );

      final DateTime now = DateTime.now().toUtc();

      final Budget normalized = budget.copyWith(
        id: _idForPeriod(budget.period),
        currencyCode: budget.currencyCode.toUpperCase(),
        revision: existing == null ? 1 : existing.revision + 1,
        createdAt: existing?.createdAt.toUtc() ?? now,
        updatedAt: now,
        isActive: true,
      );

      final model = await localDataSource.save(
        BudgetMapper.toModel(normalized, databaseId: existing?.id),
      );

      return Success<Budget>(BudgetMapper.toDomain(model));
    } on Object catch (error) {
      return FailureResult<Budget>(
        DatabaseFailure(message: 'Unable to save budget.', cause: error),
      );
    }
  }

  @override
  Future<Result<bool>> delete(BudgetPeriod period) async {
    try {
      final existing = await localDataSource.findByPeriod(
        _toDatabasePeriod(period),
      );

      if (existing == null) {
        return const FailureResult<bool>(
          ValidationFailure(message: 'Budget does not exist.'),
        );
      }

      final DateTime now = DateTime.now().toUtc();

      existing
        ..isActive = false
        ..deletedAt = now
        ..updatedAt = now
        ..revision += 1;

      await localDataSource.save(existing);

      return const Success<bool>(true);
    } on Object catch (error) {
      return FailureResult<bool>(
        DatabaseFailure(message: 'Unable to delete budget.', cause: error),
      );
    }
  }

  ValidationFailure? _validate(Budget budget) {
    if (budget.amountMinor <= 0) {
      return const ValidationFailure(
        message: 'Budget amount must be greater than zero.',
      );
    }

    if (!RegExp(r'^[A-Za-z]{3}$').hasMatch(budget.currencyCode)) {
      return const ValidationFailure(
        message: 'Currency code must contain three letters.',
      );
    }

    if (budget.currencyScale < 0 || budget.currencyScale > 3) {
      return const ValidationFailure(
        message: 'Currency scale must be between 0 and 3.',
      );
    }

    return null;
  }

  ValidationFailure? _validateBudgetRelationship({
    required Budget budget,
    required Budget oppositeBudget,
  }) {
    final String budgetCurrency = budget.currencyCode.toUpperCase();

    final String oppositeCurrency = oppositeBudget.currencyCode.toUpperCase();

    if (budgetCurrency != oppositeCurrency ||
        budget.currencyScale != oppositeBudget.currencyScale) {
      return const ValidationFailure(
        message: 'Weekly and monthly budgets must use the same currency.',
      );
    }

    if (budget.period == BudgetPeriod.weekly &&
        budget.amountMinor > oppositeBudget.amountMinor) {
      return const ValidationFailure(
        message: 'Weekly budget cannot exceed the monthly budget.',
      );
    }

    if (budget.period == BudgetPeriod.monthly &&
        budget.amountMinor < oppositeBudget.amountMinor) {
      return const ValidationFailure(
        message: 'Monthly budget cannot be lower than the weekly budget.',
      );
    }

    return null;
  }

  String _idForPeriod(BudgetPeriod period) {
    return switch (period) {
      BudgetPeriod.weekly => 'budget-weekly',
      BudgetPeriod.monthly => 'budget-monthly',
    };
  }

  BudgetPeriodType _toDatabasePeriod(BudgetPeriod period) {
    return switch (period) {
      BudgetPeriod.weekly => BudgetPeriodType.weekly,
      BudgetPeriod.monthly => BudgetPeriodType.monthly,
    };
  }
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';
import 'package:splitwise_expense_tracker/core/db/database_service.dart';
import 'package:splitwise_expense_tracker/core/errors/failure.dart';
import 'package:splitwise_expense_tracker/core/errors/result.dart';
import 'package:splitwise_expense_tracker/features/expenses/data/datasources/budget_local_data_source.dart';
import 'package:splitwise_expense_tracker/features/expenses/data/repositories/isar_budget_repository.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/budget.dart';

void main() {
  late Directory temporaryDirectory;
  late Isar isar;
  late IsarBudgetRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'splitwise_budget_test_',
    );

    isar = await Isar.open(
      applicationSchemas,
      directory: temporaryDirectory.path,
      name: 'budget_repository_test',
      inspector: false,
    );

    final DatabaseService databaseService = DatabaseService.forTesting(isar);

    repository = IsarBudgetRepository(
      localDataSource: BudgetLocalDataSource(databaseService: databaseService),
    );
  });

  tearDown(() async {
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }

    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('IsarBudgetRepository', () {
    test('allows weekly budget below monthly budget', () async {
      final Result<Budget> monthlyResult = await repository.save(
        _budget(period: BudgetPeriod.monthly, amountMinor: 10000000),
      );

      expect(monthlyResult, isA<Success<Budget>>());

      final Result<Budget> weeklyResult = await repository.save(
        _budget(period: BudgetPeriod.weekly, amountMinor: 2500000),
      );

      expect(weeklyResult, isA<Success<Budget>>());
    });

    test('allows weekly budget equal to monthly budget', () async {
      await repository.save(
        _budget(period: BudgetPeriod.monthly, amountMinor: 5000000),
      );

      final Result<Budget> weeklyResult = await repository.save(
        _budget(period: BudgetPeriod.weekly, amountMinor: 5000000),
      );

      expect(weeklyResult, isA<Success<Budget>>());
    });

    test('rejects weekly budget greater than monthly budget', () async {
      await repository.save(
        _budget(period: BudgetPeriod.monthly, amountMinor: 5000000),
      );

      final Result<Budget> weeklyResult = await repository.save(
        _budget(period: BudgetPeriod.weekly, amountMinor: 6000000),
      );

      expect(weeklyResult, isA<FailureResult<Budget>>());

      final FailureResult<Budget> failureResult =
          weeklyResult as FailureResult<Budget>;

      expect(failureResult.failure, isA<ValidationFailure>());

      expect(
        failureResult.failure.message,
        'Weekly budget cannot exceed the monthly budget.',
      );
    });

    test('rejects monthly budget lower than weekly budget', () async {
      await repository.save(
        _budget(period: BudgetPeriod.weekly, amountMinor: 4000000),
      );

      final Result<Budget> monthlyResult = await repository.save(
        _budget(period: BudgetPeriod.monthly, amountMinor: 3000000),
      );

      expect(monthlyResult, isA<FailureResult<Budget>>());

      final FailureResult<Budget> failureResult =
          monthlyResult as FailureResult<Budget>;

      expect(
        failureResult.failure.message,
        'Monthly budget cannot be lower than the weekly budget.',
      );
    });

    test('rejects budgets using different currencies', () async {
      await repository.save(
        _budget(
          period: BudgetPeriod.monthly,
          amountMinor: 5000000,
          currencyCode: 'PKR',
        ),
      );

      final Result<Budget> weeklyResult = await repository.save(
        _budget(
          period: BudgetPeriod.weekly,
          amountMinor: 100000,
          currencyCode: 'USD',
        ),
      );

      expect(weeklyResult, isA<FailureResult<Budget>>());

      final FailureResult<Budget> failureResult =
          weeklyResult as FailureResult<Budget>;

      expect(
        failureResult.failure.message,
        'Weekly and monthly budgets must use the same currency.',
      );
    });

    test('updates an existing budget instead of creating duplicates', () async {
      final Result<Budget> firstResult = await repository.save(
        _budget(period: BudgetPeriod.monthly, amountMinor: 5000000),
      );

      final Success<Budget> first = firstResult as Success<Budget>;

      expect(first.value.revision, 1);

      final Result<Budget> secondResult = await repository.save(
        _budget(period: BudgetPeriod.monthly, amountMinor: 7500000),
      );

      final Success<Budget> second = secondResult as Success<Budget>;

      expect(second.value.amountMinor, 7500000);
      expect(second.value.revision, 2);

      final Result<List<Budget>> allResult = await repository.getAllActive();

      final Success<List<Budget>> all = allResult as Success<List<Budget>>;

      expect(all.value.length, 1);
    });
  });
}

Budget _budget({
  required BudgetPeriod period,
  required int amountMinor,
  String currencyCode = 'PKR',
}) {
  final DateTime timestamp = DateTime.utc(2026, 8, 5);

  return Budget(
    id: period == BudgetPeriod.weekly ? 'budget-weekly' : 'budget-monthly',
    period: period,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    currencyScale: 2,
    isActive: true,
    revision: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

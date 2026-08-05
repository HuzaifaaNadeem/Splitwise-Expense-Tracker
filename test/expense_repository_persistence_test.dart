import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';
import 'package:splitwise_expense_tracker/core/db/database_service.dart';
import 'package:splitwise_expense_tracker/core/errors/result.dart';
import 'package:splitwise_expense_tracker/features/expenses/data/datasources/expense_local_data_source.dart';
import 'package:splitwise_expense_tracker/features/expenses/data/repositories/isar_expense_repository.dart';
import 'package:splitwise_expense_tracker/features/expenses/domain/entities/expense.dart';

void main() {
  late Directory temporaryDirectory;
  late Isar isar;
  late IsarExpenseRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'splitwise_expense_test_',
    );

    isar = await Isar.open(
      applicationSchemas,
      directory: temporaryDirectory.path,
      name: 'expense_repository_test',
      inspector: false,
    );

    final DatabaseService databaseService = DatabaseService.forTesting(isar);

    final ExpenseLocalDataSource localDataSource = ExpenseLocalDataSource(
      databaseService: databaseService,
    );

    repository = IsarExpenseRepository(localDataSource: localDataSource);
  });

  tearDown(() async {
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }

    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('IsarExpenseRepository persistence', () {
    test('creates and retrieves an expense', () async {
      final Expense expense = _buildExpense();

      final Result<Expense> createResult = await repository.create(expense);

      expect(createResult, isA<Success<Expense>>());

      final Success<Expense> created = createResult as Success<Expense>;

      expect(created.value.id, expense.id);

      expect(created.value.title, 'Lunch');

      expect(created.value.amountMinor, 125000);

      final Result<Expense?> readResult = await repository.getById(expense.id);

      expect(readResult, isA<Success<Expense?>>());

      final Success<Expense?> loaded = readResult as Success<Expense?>;

      expect(loaded.value, isNotNull);

      expect(loaded.value!.id, expense.id);

      expect(loaded.value!.title, 'Lunch');
    });

    test('updates an existing expense', () async {
      final Expense expense = _buildExpense();

      final Result<Expense> createResult = await repository.create(expense);

      final Success<Expense> created = createResult as Success<Expense>;

      final Expense changed = created.value.copyWith(
        title: 'Dinner',
        amountMinor: 250000,
        notes: 'Dinner with friends',
      );

      final Result<Expense> updateResult = await repository.update(changed);

      expect(updateResult, isA<Success<Expense>>());

      final Success<Expense> updated = updateResult as Success<Expense>;

      expect(updated.value.title, 'Dinner');

      expect(updated.value.amountMinor, 250000);

      expect(updated.value.notes, 'Dinner with friends');

      expect(updated.value.revision, 2);

      expect(updated.value.createdAt, created.value.createdAt);

      expect(
        updated.value.updatedAt.isBefore(created.value.updatedAt),
        isFalse,
      );
    });

    test('returns active expenses newest first', () async {
      final Expense older = _buildExpense(
        id: 'expense-old',
        title: 'Breakfast',
        occurredAt: DateTime.utc(2026, 8, 4, 9),
      );

      final Expense newer = _buildExpense(
        id: 'expense-new',
        title: 'Dinner',
        occurredAt: DateTime.utc(2026, 8, 5, 20),
      );

      await repository.create(older);
      await repository.create(newer);

      final Result<List<Expense>> result = await repository.getAllActive();

      expect(result, isA<Success<List<Expense>>>());

      final Success<List<Expense>> loaded = result as Success<List<Expense>>;

      expect(loaded.value.length, 2);

      expect(loaded.value[0].id, 'expense-new');

      expect(loaded.value[1].id, 'expense-old');
    });

    test('soft deletes an expense', () async {
      final Expense expense = _buildExpense();

      await repository.create(expense);

      final Result<bool> deleteResult = await repository.delete(expense.id);

      expect(deleteResult, isA<Success<bool>>());

      final Success<bool> deleted = deleteResult as Success<bool>;

      expect(deleted.value, isTrue);

      final Result<Expense?> readResult = await repository.getById(expense.id);

      final Success<Expense?> loaded = readResult as Success<Expense?>;

      expect(loaded.value, isNull);
    });

    test('soft deleted expense is excluded from active list', () async {
      final Expense active = _buildExpense(
        id: 'active-expense',
        title: 'Groceries',
      );

      final Expense deleted = _buildExpense(
        id: 'deleted-expense',
        title: 'Taxi',
      );

      await repository.create(active);
      await repository.create(deleted);

      await repository.delete(deleted.id);

      final Result<List<Expense>> result = await repository.getAllActive();

      final Success<List<Expense>> loaded = result as Success<List<Expense>>;

      expect(loaded.value.length, 1);

      expect(loaded.value.single.id, active.id);
    });

    test('rejects duplicate expense ids', () async {
      final Expense expense = _buildExpense();

      final Result<Expense> first = await repository.create(expense);

      expect(first, isA<Success<Expense>>());

      final Result<Expense> second = await repository.create(expense);

      expect(second, isA<FailureResult<Expense>>());
    });

    test('rejects invalid expense amount', () async {
      final Expense expense = _buildExpense(amountMinor: 0);

      final Result<Expense> result = await repository.create(expense);

      expect(result, isA<FailureResult<Expense>>());

      final Result<List<Expense>> activeResult = await repository
          .getAllActive();

      final Success<List<Expense>> active =
          activeResult as Success<List<Expense>>;

      expect(active.value, isEmpty);
    });
  });
}

Expense _buildExpense({
  String id = 'expense-1',
  String title = 'Lunch',
  int amountMinor = 125000,
  DateTime? occurredAt,
}) {
  final DateTime timestamp = DateTime.utc(2026, 8, 5, 12);

  return Expense(
    id: id,
    title: title,
    amountMinor: amountMinor,
    currencyCode: 'PKR',
    currencyScale: 2,
    categoryId: 'food',
    occurredAt: occurredAt ?? timestamp,
    notes: 'Test expense',
    entryType: ExpenseEntryType.expense,
    revision: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

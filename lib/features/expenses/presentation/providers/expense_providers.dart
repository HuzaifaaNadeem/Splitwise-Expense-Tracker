import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/db/database_provider.dart';
import '../../data/datasources/expense_local_data_source.dart';
import '../../data/repositories/isar_expense_repository.dart';
import '../../domain/repositories/expense_repository.dart';

part 'expense_providers.g.dart';

@Riverpod(keepAlive: true)
ExpenseLocalDataSource expenseLocalDataSource(ExpenseLocalDataSourceRef ref) {
  return ExpenseLocalDataSource(
    databaseService: ref.watch(databaseServiceProvider),
  );
}

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(ExpenseRepositoryRef ref) {
  return IsarExpenseRepository(
    localDataSource: ref.watch(expenseLocalDataSourceProvider),
  );
}

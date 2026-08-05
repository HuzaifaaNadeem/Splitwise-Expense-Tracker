import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/db/database_provider.dart';
import '../../data/datasources/budget_local_data_source.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../../data/repositories/isar_budget_repository.dart';
import '../../data/repositories/isar_category_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/category_repository.dart';

part 'category_budget_providers.g.dart';

@Riverpod(keepAlive: true)
CategoryLocalDataSource categoryLocalDataSource(
  CategoryLocalDataSourceRef ref,
) {
  return CategoryLocalDataSource(
    databaseService: ref.watch(databaseServiceProvider),
  );
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return IsarCategoryRepository(
    localDataSource: ref.watch(categoryLocalDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
BudgetLocalDataSource budgetLocalDataSource(BudgetLocalDataSourceRef ref) {
  return BudgetLocalDataSource(
    databaseService: ref.watch(databaseServiceProvider),
  );
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(BudgetRepositoryRef ref) {
  return IsarBudgetRepository(
    localDataSource: ref.watch(budgetLocalDataSourceProvider),
  );
}

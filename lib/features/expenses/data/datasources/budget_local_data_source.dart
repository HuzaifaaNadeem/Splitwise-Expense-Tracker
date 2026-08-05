import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../../../core/db/database_service.dart';

final class BudgetLocalDataSource {
  const BudgetLocalDataSource({required this.databaseService});

  final DatabaseService databaseService;

  IsarCollection<BudgetModel> get _collection =>
      databaseService.isar.budgetModels;

  Future<List<BudgetModel>> findAll() {
    return _collection.where().findAll();
  }

  Future<BudgetModel?> findByPeriod(BudgetPeriodType period) async {
    final List<BudgetModel> models = await _collection.where().findAll();

    for (final BudgetModel model in models) {
      if (model.periodType == period &&
          model.deletedAt == null &&
          model.isActive) {
        return model;
      }
    }

    return null;
  }

  Future<BudgetModel> save(BudgetModel model) async {
    await databaseService.write<void>(() async {
      await _collection.put(model);
    });

    return model;
  }
}

import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../../../core/db/database_service.dart';

final class ExpenseLocalDataSource {
  const ExpenseLocalDataSource({required this.databaseService});

  final DatabaseService databaseService;

  IsarCollection<ExpenseModel> get _collection =>
      databaseService.isar.expenseModels;

  Future<ExpenseModel> insert(ExpenseModel model) async {
    await databaseService.write<void>(() async {
      await _collection.put(model);
    });

    return model;
  }

  Future<ExpenseModel?> findByLocalId(String localId) {
    return _collection.filter().localIdEqualTo(localId).findFirst();
  }

  Future<List<ExpenseModel>> findAllActive() {
    return _collection
        .filter()
        .deletedAtIsNull()
        .sortByOccurredAtDesc()
        .findAll();
  }

  Future<ExpenseModel> update(ExpenseModel model) async {
    await databaseService.write<void>(() async {
      await _collection.put(model);
    });

    return model;
  }

  Future<bool> softDelete(String localId) {
    return databaseService.write<bool>(() async {
      final ExpenseModel? existing = await _collection
          .filter()
          .localIdEqualTo(localId)
          .findFirst();

      if (existing == null || existing.deletedAt != null) {
        return false;
      }

      final DateTime now = DateTime.now().toUtc();

      existing
        ..deletedAt = now
        ..updatedAt = now
        ..revision += 1;

      await _collection.put(existing);

      return true;
    });
  }
}

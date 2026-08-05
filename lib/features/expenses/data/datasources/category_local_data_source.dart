import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../../../core/db/database_service.dart';

final class CategoryLocalDataSource {
  const CategoryLocalDataSource({required this.databaseService});

  final DatabaseService databaseService;

  IsarCollection<CategoryModel> get _collection =>
      databaseService.isar.categoryModels;

  Future<CategoryModel?> findByLocalId(String localId) {
    return _collection.filter().localIdEqualTo(localId).findFirst();
  }

  Future<List<CategoryModel>> findAll() {
    return _collection.where().findAll();
  }

  Future<CategoryModel> save(CategoryModel model) async {
    await databaseService.write<void>(() async {
      await _collection.put(model);
    });

    return model;
  }
}

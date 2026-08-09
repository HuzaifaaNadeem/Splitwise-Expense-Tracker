import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../../../core/db/database_service.dart';

final class GroupLocalDataSource {
  const GroupLocalDataSource({required this.databaseService});

  final DatabaseService databaseService;

  IsarCollection<GroupModel> get _collection =>
      databaseService.isar.groupModels;

  Future<GroupModel> insert(GroupModel model) async {
    await databaseService.write(() async {
      await _collection.put(model);
    });

    return model;
  }

  Future<GroupModel?> findByLocalId(String localId) {
    return _collection.filter().localIdEqualTo(localId).findFirst();
  }

  Future<List<GroupModel>> findAllActive() {
    return _collection
        .filter()
        .deletedAtIsNull()
        .isArchivedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<GroupModel> update(GroupModel model) async {
    await databaseService.write(() async {
      await _collection.put(model);
    });

    return model;
  }

  Future<bool> archive(String localId) {
    return databaseService.write(() async {
      final GroupModel? existing = await _collection
          .filter()
          .localIdEqualTo(localId)
          .findFirst();

      if (existing == null ||
          existing.deletedAt != null ||
          existing.isArchived) {
        return false;
      }

      final DateTime now = DateTime.now().toUtc();

      existing
        ..isArchived = true
        ..updatedAt = now
        ..revision += 1;

      await _collection.put(existing);

      return true;
    });
  }

  Future<bool> softDelete(String localId) {
    return databaseService.write(() async {
      final GroupModel? existing = await _collection
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

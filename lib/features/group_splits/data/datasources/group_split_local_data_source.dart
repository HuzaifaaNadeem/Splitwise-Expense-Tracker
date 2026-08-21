import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../../../core/db/database_service.dart';

final class GroupSplitLocalDataSource {
  const GroupSplitLocalDataSource({required this.databaseService});

  final DatabaseService databaseService;

  IsarCollection<GroupSplitModel> get _collection =>
      databaseService.isar.groupSplitModels;

  Future<List<GroupSplitModel>> findByGroupId(String groupId) {
    return _collection
        .filter()
        .groupIdEqualTo(groupId)
        .deletedAtIsNull()
        .sortByOccurredAtDesc()
        .findAll();
  }

  Future<GroupSplitModel?> findByLocalId(String localId) {
    return _collection.filter().localIdEqualTo(localId).findFirst();
  }

  Future<GroupSplitModel> insert(GroupSplitModel model) async {
    await databaseService.write(() async {
      await _collection.put(model);
    });

    return model;
  }

  Future<GroupSplitModel> update(GroupSplitModel model) async {
    await databaseService.write(() async {
      await _collection.put(model);
    });

    return model;
  }

  Future<bool> softDelete(String localId) {
    return databaseService.write(() async {
      final GroupSplitModel? existing = await findByLocalId(localId);

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

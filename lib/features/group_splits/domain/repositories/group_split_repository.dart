import '../../../../core/errors/result.dart';
import '../entities/group_split.dart';

abstract interface class GroupSplitRepository {
  Future<Result<List<GroupSplit>>> getByGroupId(String groupId);

  Future<Result<GroupSplit?>> getById(String id);

  Future<Result<GroupSplit>> create(GroupSplit split);

  Future<Result<GroupSplit>> update(GroupSplit split);

  Future<Result<void>> delete(String id);
}

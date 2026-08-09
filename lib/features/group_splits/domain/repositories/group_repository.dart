import '../../../../core/errors/result.dart';
import '../entities/group.dart';
import '../entities/group_member.dart';

abstract interface class GroupRepository {
  Future<Result<List<Group>>> getAllActive();

  Future<Result<Group?>> getById(String id);

  Future<Result<Group>> create(Group group);

  Future<Result<Group>> update(Group group);

  Future<Result<void>> archive(String id);

  Future<Result<void>> delete(String id);

  Future<Result<Group>> addMember(String groupId, GroupMember member);

  Future<Result<Group>> updateMember(String groupId, GroupMember member);

  Future<Result<Group>> removeMember(String groupId, String memberId);
}

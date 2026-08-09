import 'package:local_database/local_database.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_local_data_source.dart';
import '../mappers/group_mapper.dart';

final class IsarGroupRepository implements GroupRepository {
  const IsarGroupRepository({required this.localDataSource});

  final GroupLocalDataSource localDataSource;

  @override
  Future<Result<List<Group>>> getAllActive() async {
    try {
      final List<GroupModel> models = await localDataSource.findAllActive();

      final List<Group> groups = models
          .map<Group>(GroupMapper.toDomain)
          .toList(growable: false);

      return Success<List<Group>>(groups);
    } catch (error) {
      return FailureResult<List<Group>>(
        DatabaseFailure(message: 'Failed to load groups.', cause: error),
      );
    }
  }

  @override
  Future<Result<Group?>> getById(String id) async {
    try {
      final GroupModel? model = await localDataSource.findByLocalId(id);

      if (model == null || model.deletedAt != null) {
        return const Success<Group?>(null);
      }

      return Success<Group?>(GroupMapper.toDomain(model));
    } catch (error) {
      return FailureResult<Group?>(
        DatabaseFailure(message: 'Failed to load the group.', cause: error),
      );
    }
  }

  @override
  Future<Result<Group>> create(Group group) async {
    try {
      final GroupModel? existing = await localDataSource.findByLocalId(
        group.id,
      );

      if (existing != null && existing.deletedAt == null) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'A group with this ID already exists.'),
        );
      }

      final GroupModel model = GroupMapper.toModel(group);

      await localDataSource.insert(model);

      return Success<Group>(group);
    } catch (error) {
      return FailureResult<Group>(
        DatabaseFailure(message: 'Failed to create the group.', cause: error),
      );
    }
  }

  @override
  Future<Result<Group>> update(Group group) async {
    try {
      final GroupModel? existing = await localDataSource.findByLocalId(
        group.id,
      );

      if (existing == null || existing.deletedAt != null) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'Group not found.'),
        );
      }

      final Group updated = group.copyWith(
        revision: existing.revision + 1,
        updatedAt: DateTime.now().toUtc(),
      );

      await localDataSource.update(GroupMapper.toModel(updated));

      return Success<Group>(updated);
    } catch (error) {
      return FailureResult<Group>(
        DatabaseFailure(message: 'Failed to update the group.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> archive(String id) async {
    try {
      final bool archived = await localDataSource.archive(id);

      if (!archived) {
        return const FailureResult<void>(
          ValidationFailure(message: 'Group not found or already archived.'),
        );
      }

      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(
        DatabaseFailure(message: 'Failed to archive the group.', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final bool deleted = await localDataSource.softDelete(id);

      if (!deleted) {
        return const FailureResult<void>(
          ValidationFailure(message: 'Group not found or already deleted.'),
        );
      }

      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(
        DatabaseFailure(message: 'Failed to delete the group.', cause: error),
      );
    }
  }

  @override
  Future<Result<Group>> addMember(String groupId, GroupMember member) async {
    try {
      final GroupModel? existing = await localDataSource.findByLocalId(groupId);

      if (existing == null ||
          existing.deletedAt != null ||
          existing.isArchived) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'Group not found or is no longer active.'),
        );
      }

      final Group group = GroupMapper.toDomain(existing);

      final bool alreadyExists = group.members.any(
        (GroupMember existingMember) => existingMember.id == member.id,
      );

      if (alreadyExists) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'A member with this ID already exists.'),
        );
      }

      final Group updated = group.copyWith(
        members: <GroupMember>[...group.members, member],
        revision: existing.revision + 1,
        updatedAt: DateTime.now().toUtc(),
      );

      await localDataSource.update(GroupMapper.toModel(updated));

      return Success<Group>(updated);
    } catch (error) {
      return FailureResult<Group>(
        DatabaseFailure(
          message: 'Failed to add the group member.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<Group>> updateMember(String groupId, GroupMember member) async {
    try {
      final GroupModel? existing = await localDataSource.findByLocalId(groupId);

      if (existing == null ||
          existing.deletedAt != null ||
          existing.isArchived) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'Group not found or is no longer active.'),
        );
      }

      final Group group = GroupMapper.toDomain(existing);

      final int memberIndex = group.members.indexWhere(
        (GroupMember existingMember) => existingMember.id == member.id,
      );

      if (memberIndex == -1) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'Member not found in this group.'),
        );
      }

      final List<GroupMember> updatedMembers = List<GroupMember>.of(
        group.members,
      );

      updatedMembers[memberIndex] = member;

      final Group updated = group.copyWith(
        members: updatedMembers,
        revision: existing.revision + 1,
        updatedAt: DateTime.now().toUtc(),
      );

      await localDataSource.update(GroupMapper.toModel(updated));

      return Success<Group>(updated);
    } catch (error) {
      return FailureResult<Group>(
        DatabaseFailure(
          message: 'Failed to update the group member.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<Group>> removeMember(String groupId, String memberId) async {
    try {
      final GroupModel? existing = await localDataSource.findByLocalId(groupId);

      if (existing == null ||
          existing.deletedAt != null ||
          existing.isArchived) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'Group not found or is no longer active.'),
        );
      }

      final Group group = GroupMapper.toDomain(existing);

      final int memberIndex = group.members.indexWhere(
        (GroupMember member) => member.id == memberId,
      );

      if (memberIndex == -1) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'Member not found in this group.'),
        );
      }

      final GroupMember member = group.members[memberIndex];

      if (!member.isActive) {
        return const FailureResult<Group>(
          ValidationFailure(message: 'Member is already inactive.'),
        );
      }

      final List<GroupMember> updatedMembers = List<GroupMember>.of(
        group.members,
      );

      updatedMembers[memberIndex] = member.copyWith(isActive: false);

      final Group updated = group.copyWith(
        members: updatedMembers,
        revision: existing.revision + 1,
        updatedAt: DateTime.now().toUtc(),
      );

      await localDataSource.update(GroupMapper.toModel(updated));

      return Success<Group>(updated);
    } catch (error) {
      return FailureResult<Group>(
        DatabaseFailure(
          message: 'Failed to remove the group member.',
          cause: error,
        ),
      );
    }
  }
}

import 'package:local_database/local_database.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/group_split.dart';
import '../../domain/repositories/group_split_repository.dart';
import '../datasources/group_split_local_data_source.dart';
import '../mappers/group_split_mapper.dart';

final class IsarGroupSplitRepository implements GroupSplitRepository {
  const IsarGroupSplitRepository({required this.localDataSource});

  final GroupSplitLocalDataSource localDataSource;

  @override
  Future<Result<List<GroupSplit>>> getByGroupId(String groupId) async {
    try {
      final List<GroupSplitModel> models = await localDataSource.findByGroupId(
        groupId,
      );

      final List<GroupSplit> splits = models
          .map<GroupSplit>(GroupSplitMapper.toDomain)
          .toList(growable: false);

      return Success<List<GroupSplit>>(splits);
    } catch (error) {
      return FailureResult<List<GroupSplit>>(
        DatabaseFailure(
          message: 'Failed to load group expenses.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<GroupSplit?>> getById(String id) async {
    try {
      final GroupSplitModel? model = await localDataSource.findByLocalId(id);

      if (model == null || model.deletedAt != null) {
        return const Success<GroupSplit?>(null);
      }

      return Success<GroupSplit?>(GroupSplitMapper.toDomain(model));
    } catch (error) {
      return FailureResult<GroupSplit?>(
        DatabaseFailure(
          message: 'Failed to load the group expense.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<GroupSplit>> create(GroupSplit split) async {
    try {
      final GroupSplitModel? existing = await localDataSource.findByLocalId(
        split.id,
      );

      if (existing != null && existing.deletedAt == null) {
        return const FailureResult<GroupSplit>(
          ValidationFailure(
            message: 'A group expense with this ID already exists.',
          ),
        );
      }

      final ValidationFailure? validationFailure = _validate(split);

      if (validationFailure != null) {
        return FailureResult<GroupSplit>(validationFailure);
      }

      await localDataSource.insert(GroupSplitMapper.toModel(split));

      return Success<GroupSplit>(split);
    } catch (error) {
      return FailureResult<GroupSplit>(
        DatabaseFailure(
          message: 'Failed to create the group expense.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<GroupSplit>> update(GroupSplit split) async {
    try {
      final GroupSplitModel? existing = await localDataSource.findByLocalId(
        split.id,
      );

      if (existing == null || existing.deletedAt != null) {
        return const FailureResult<GroupSplit>(
          ValidationFailure(message: 'Group expense not found.'),
        );
      }

      final ValidationFailure? validationFailure = _validate(split);

      if (validationFailure != null) {
        return FailureResult<GroupSplit>(validationFailure);
      }

      final GroupSplit updated = split.copyWith(
        revision: existing.revision + 1,
        updatedAt: DateTime.now().toUtc(),
      );

      await localDataSource.update(GroupSplitMapper.toModel(updated));

      return Success<GroupSplit>(updated);
    } catch (error) {
      return FailureResult<GroupSplit>(
        DatabaseFailure(
          message: 'Failed to update the group expense.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final bool deleted = await localDataSource.softDelete(id);

      if (!deleted) {
        return const FailureResult<void>(
          ValidationFailure(
            message: 'Group expense not found or already deleted.',
          ),
        );
      }

      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(
        DatabaseFailure(
          message: 'Failed to delete the group expense.',
          cause: error,
        ),
      );
    }
  }

  ValidationFailure? _validate(GroupSplit split) {
    if (split.groupId.trim().isEmpty) {
      return const ValidationFailure(message: 'Group ID cannot be empty.');
    }

    if (split.title.trim().isEmpty) {
      return const ValidationFailure(message: 'Expense title cannot be empty.');
    }

    if (split.totalAmountMinor <= 0) {
      return const ValidationFailure(
        message: 'Expense amount must be greater than zero.',
      );
    }

    if (split.paidByMemberId.trim().isEmpty) {
      return const ValidationFailure(message: 'A payer must be selected.');
    }

    if (split.shares.isEmpty) {
      return const ValidationFailure(
        message: 'At least one member must participate.',
      );
    }

    final Set<String> memberIds = <String>{};
    int totalOwedMinor = 0;

    for (final GroupSplitShare share in split.shares) {
      if (share.memberId.trim().isEmpty) {
        return const ValidationFailure(
          message: 'Split member ID cannot be empty.',
        );
      }

      if (!memberIds.add(share.memberId)) {
        return const ValidationFailure(
          message: 'A member cannot appear more than once in a split.',
        );
      }

      if (share.owedAmountMinor < 0) {
        return const ValidationFailure(
          message: 'A member share cannot be negative.',
        );
      }

      totalOwedMinor += share.owedAmountMinor;
    }

    if (totalOwedMinor != split.totalAmountMinor) {
      return ValidationFailure(
        message:
            'Split amounts must equal the total expense. '
            'Expected ${split.totalAmountMinor}, '
            'received $totalOwedMinor.',
      );
    }

    return null;
  }
}

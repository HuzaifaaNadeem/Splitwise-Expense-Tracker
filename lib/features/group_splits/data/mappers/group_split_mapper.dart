import 'package:local_database/local_database.dart';

import '../../domain/entities/group_split.dart';

final class GroupSplitMapper {
  const GroupSplitMapper._();

  static GroupSplit toDomain(GroupSplitModel model) {
    return GroupSplit(
      id: model.localId,
      groupId: model.groupId,
      title: model.title,
      notes: model.notes,
      totalAmountMinor: model.totalAmountMinor,
      currencyCode: model.currencyCode,
      currencyScale: model.currencyScale,
      paidByMemberId: model.paidByMemberId,
      occurredAt: model.occurredAt,
      splitMethod: _toDomainMethod(model.splitMethod),
      shares: model.shares
          .map<GroupSplitShare>(GroupSplitShareMapper.toDomain)
          .toList(growable: false),
      linkedExpenseId: model.linkedExpenseId,
      revision: model.revision,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
    );
  }

  static GroupSplitModel toModel(GroupSplit entity) {
    return GroupSplitModel()
      ..localId = entity.id
      ..groupId = entity.groupId
      ..title = entity.title
      ..notes = entity.notes
      ..totalAmountMinor = entity.totalAmountMinor
      ..currencyCode = entity.currencyCode
      ..currencyScale = entity.currencyScale
      ..paidByMemberId = entity.paidByMemberId
      ..occurredAt = entity.occurredAt.toUtc()
      ..splitMethod = _toModelMethod(entity.splitMethod)
      ..shares = entity.shares
          .map<GroupSplitShareModel>(GroupSplitShareMapper.toModel)
          .toList(growable: false)
      ..linkedExpenseId = entity.linkedExpenseId
      ..revision = entity.revision
      ..createdAt = entity.createdAt.toUtc()
      ..updatedAt = entity.updatedAt.toUtc()
      ..deletedAt = entity.deletedAt?.toUtc();
  }

  static GroupSplitMethod _toDomainMethod(SplitMethod method) {
    return switch (method) {
      SplitMethod.equal => GroupSplitMethod.equal,
      SplitMethod.exact => GroupSplitMethod.exact,
      SplitMethod.percentage => GroupSplitMethod.percentage,
      SplitMethod.shares => GroupSplitMethod.shares,
    };
  }

  static SplitMethod _toModelMethod(GroupSplitMethod method) {
    return switch (method) {
      GroupSplitMethod.equal => SplitMethod.equal,
      GroupSplitMethod.exact => SplitMethod.exact,
      GroupSplitMethod.percentage => SplitMethod.percentage,
      GroupSplitMethod.shares => SplitMethod.shares,
    };
  }
}

final class GroupSplitShareMapper {
  const GroupSplitShareMapper._();

  static GroupSplitShare toDomain(GroupSplitShareModel model) {
    return GroupSplitShare(
      memberId: model.memberId,
      owedAmountMinor: model.owedAmountMinor,
      percentageBasisPoints: model.percentageBasisPoints,
      shareWeight: model.shareWeight,
    );
  }

  static GroupSplitShareModel toModel(GroupSplitShare entity) {
    return GroupSplitShareModel()
      ..memberId = entity.memberId
      ..owedAmountMinor = entity.owedAmountMinor
      ..percentageBasisPoints = entity.percentageBasisPoints
      ..shareWeight = entity.shareWeight;
  }
}

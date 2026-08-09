import 'package:local_database/local_database.dart';

import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';

final class GroupMapper {
  const GroupMapper._();

  static Group toDomain(GroupModel model) {
    return Group(
      id: model.localId,
      name: model.name,
      description: model.description,
      ownerMemberId: model.ownerMemberId,
      defaultCurrencyCode: model.defaultCurrencyCode,
      defaultCurrencyScale: model.defaultCurrencyScale,
      members: model.members
          .whereType<GroupMemberModel>()
          .map(GroupMemberMapper.toDomain)
          .toList(growable: false),
      isArchived: model.isArchived,
      revision: model.revision,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
    );
  }

  static GroupModel toModel(Group entity) {
    return GroupModel()
      ..localId = entity.id
      ..name = entity.name
      ..description = entity.description
      ..ownerMemberId = entity.ownerMemberId
      ..defaultCurrencyCode = entity.defaultCurrencyCode
      ..defaultCurrencyScale = entity.defaultCurrencyScale
      ..members = entity.members
          .map(GroupMemberMapper.toModel)
          .toList(growable: false)
      ..isArchived = entity.isArchived
      ..revision = entity.revision
      ..createdAt = entity.createdAt.toUtc()
      ..updatedAt = entity.updatedAt.toUtc()
      ..deletedAt = entity.deletedAt?.toUtc();
  }
}

final class GroupMemberMapper {
  const GroupMemberMapper._();

  static GroupMember toDomain(GroupMemberModel model) {
    return GroupMember(
      id: model.memberId,
      displayName: model.displayName,
      email: model.email,
      avatarColorValue: model.avatarColorValue,
      isCurrentUser: model.isCurrentUser,
      isActive: model.isActive,
      joinedAt: model.joinedAt,
    );
  }

  static GroupMemberModel toModel(GroupMember entity) {
    return GroupMemberModel()
      ..memberId = entity.id
      ..displayName = entity.displayName
      ..email = entity.email
      ..avatarColorValue = entity.avatarColorValue
      ..isCurrentUser = entity.isCurrentUser
      ..isActive = entity.isActive
      ..joinedAt = entity.joinedAt.toUtc();
  }
}

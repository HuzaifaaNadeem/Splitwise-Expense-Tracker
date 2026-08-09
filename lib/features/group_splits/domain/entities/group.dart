import 'package:equatable/equatable.dart';

import 'group_member.dart';

final class Group extends Equatable {
  const Group({
    required this.id,
    required this.name,
    required this.ownerMemberId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.defaultCurrencyCode = 'PKR',
    this.defaultCurrencyScale = 2,
    this.isArchived = false,
    this.revision = 1,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String ownerMemberId;
  final String defaultCurrencyCode;
  final int defaultCurrencyScale;
  final List<GroupMember> members;
  final bool isArchived;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  List<GroupMember> get activeMembers {
    return members
        .where((GroupMember member) => member.isActive)
        .toList(growable: false);
  }

  GroupMember? get currentUser {
    for (final GroupMember member in members) {
      if (member.isCurrentUser) {
        return member;
      }
    }

    return null;
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerMemberId,
    String? defaultCurrencyCode,
    int? defaultCurrencyScale,
    List<GroupMember>? members,
    bool? isArchived,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerMemberId: ownerMemberId ?? this.ownerMemberId,
      defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
      defaultCurrencyScale: defaultCurrencyScale ?? this.defaultCurrencyScale,
      members: members ?? this.members,
      isArchived: isArchived ?? this.isArchived,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    description,
    ownerMemberId,
    defaultCurrencyCode,
    defaultCurrencyScale,
    members,
    isArchived,
    revision,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

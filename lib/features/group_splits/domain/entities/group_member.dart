import 'package:equatable/equatable.dart';

final class GroupMember extends Equatable {
  const GroupMember({
    required this.id,
    required this.displayName,
    required this.joinedAt,
    this.email,
    this.avatarColorValue = 0xFF2563EB,
    this.isCurrentUser = false,
    this.isActive = true,
  });

  final String id;
  final String displayName;
  final String? email;
  final int avatarColorValue;
  final bool isCurrentUser;
  final bool isActive;
  final DateTime joinedAt;

  GroupMember copyWith({
    String? id,
    String? displayName,
    String? email,
    int? avatarColorValue,
    bool? isCurrentUser,
    bool? isActive,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    displayName,
    email,
    avatarColorValue,
    isCurrentUser,
    isActive,
    joinedAt,
  ];
}

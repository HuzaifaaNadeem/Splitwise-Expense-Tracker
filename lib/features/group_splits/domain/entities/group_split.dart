import 'package:equatable/equatable.dart';

enum GroupSplitMethod { equal, exact, percentage, shares }

final class GroupSplitShare extends Equatable {
  const GroupSplitShare({
    required this.memberId,
    required this.owedAmountMinor,
    this.percentageBasisPoints,
    this.shareWeight,
  });

  final String memberId;
  final int owedAmountMinor;
  final int? percentageBasisPoints;
  final int? shareWeight;

  GroupSplitShare copyWith({
    String? memberId,
    int? owedAmountMinor,
    int? percentageBasisPoints,
    int? shareWeight,
  }) {
    return GroupSplitShare(
      memberId: memberId ?? this.memberId,
      owedAmountMinor: owedAmountMinor ?? this.owedAmountMinor,
      percentageBasisPoints:
          percentageBasisPoints ?? this.percentageBasisPoints,
      shareWeight: shareWeight ?? this.shareWeight,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    memberId,
    owedAmountMinor,
    percentageBasisPoints,
    shareWeight,
  ];
}

final class GroupSplit extends Equatable {
  const GroupSplit({
    required this.id,
    required this.groupId,
    required this.title,
    required this.totalAmountMinor,
    required this.currencyCode,
    required this.currencyScale,
    required this.paidByMemberId,
    required this.occurredAt,
    required this.splitMethod,
    required this.shares,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.linkedExpenseId,
    this.revision = 1,
    this.deletedAt,
  });

  final String id;
  final String groupId;
  final String title;
  final String? notes;
  final int totalAmountMinor;
  final String currencyCode;
  final int currencyScale;
  final String paidByMemberId;
  final DateTime occurredAt;
  final GroupSplitMethod splitMethod;
  final List<GroupSplitShare> shares;
  final String? linkedExpenseId;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  GroupSplit copyWith({
    String? id,
    String? groupId,
    String? title,
    String? notes,
    int? totalAmountMinor,
    String? currencyCode,
    int? currencyScale,
    String? paidByMemberId,
    DateTime? occurredAt,
    GroupSplitMethod? splitMethod,
    List<GroupSplitShare>? shares,
    String? linkedExpenseId,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return GroupSplit(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyScale: currencyScale ?? this.currencyScale,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      occurredAt: occurredAt ?? this.occurredAt,
      splitMethod: splitMethod ?? this.splitMethod,
      shares: shares ?? this.shares,
      linkedExpenseId: linkedExpenseId ?? this.linkedExpenseId,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    groupId,
    title,
    notes,
    totalAmountMinor,
    currencyCode,
    currencyScale,
    paidByMemberId,
    occurredAt,
    splitMethod,
    shares,
    linkedExpenseId,
    revision,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

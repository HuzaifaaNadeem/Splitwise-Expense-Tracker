import 'package:equatable/equatable.dart';

enum ExpenseEntryType { expense, income }

final class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    required this.currencyScale,
    required this.categoryId,
    required this.occurredAt,
    required this.entryType,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.groupId,
    this.groupSplitId,
    this.deletedAt,
  });

  static const Object _notProvided = Object();

  /// Stable UUID used by the application.
  final String id;

  final String title;

  /// Monetary value stored in the currency's smallest unit.
  ///
  /// PKR 1,250.50 = 125050.
  final int amountMinor;

  final String currencyCode;

  final int currencyScale;

  final String categoryId;

  final DateTime occurredAt;

  final String? notes;

  final String? groupId;

  final String? groupSplitId;

  final ExpenseEntryType entryType;

  final int revision;

  final DateTime createdAt;

  final DateTime updatedAt;

  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Expense copyWith({
    String? id,
    String? title,
    int? amountMinor,
    String? currencyCode,
    int? currencyScale,
    String? categoryId,
    DateTime? occurredAt,
    Object? notes = _notProvided,
    Object? groupId = _notProvided,
    Object? groupSplitId = _notProvided,
    ExpenseEntryType? entryType,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _notProvided,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyScale: currencyScale ?? this.currencyScale,
      categoryId: categoryId ?? this.categoryId,
      occurredAt: occurredAt ?? this.occurredAt,
      notes: identical(notes, _notProvided) ? this.notes : notes as String?,
      groupId: identical(groupId, _notProvided)
          ? this.groupId
          : groupId as String?,
      groupSplitId: identical(groupSplitId, _notProvided)
          ? this.groupSplitId
          : groupSplitId as String?,
      entryType: entryType ?? this.entryType,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _notProvided)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    amountMinor,
    currencyCode,
    currencyScale,
    categoryId,
    occurredAt,
    notes,
    groupId,
    groupSplitId,
    entryType,
    revision,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

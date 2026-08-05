import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../domain/entities/expense.dart';

abstract final class ExpenseMapper {
  static Expense toDomain(ExpenseModel model) {
    return Expense(
      id: model.localId,
      title: model.title,
      amountMinor: model.amountMinor,
      currencyCode: model.currencyCode,
      currencyScale: model.currencyScale,
      categoryId: model.categoryId,
      occurredAt: model.occurredAt.toUtc(),
      notes: model.notes,
      groupId: model.groupId,
      groupSplitId: model.groupSplitId,
      entryType: _toDomainEntryType(model.entryType),
      revision: model.revision,
      createdAt: model.createdAt.toUtc(),
      updatedAt: model.updatedAt.toUtc(),
      deletedAt: model.deletedAt?.toUtc(),
    );
  }

  static ExpenseModel toModel(Expense expense, {int? databaseId}) {
    return ExpenseModel()
      ..id = databaseId ?? Isar.autoIncrement
      ..localId = expense.id
      ..title = expense.title
      ..amountMinor = expense.amountMinor
      ..currencyCode = expense.currencyCode
      ..currencyScale = expense.currencyScale
      ..categoryId = expense.categoryId
      ..occurredAt = expense.occurredAt.toUtc()
      ..notes = expense.notes
      ..groupId = expense.groupId
      ..groupSplitId = expense.groupSplitId
      ..entryType = _toDatabaseEntryType(expense.entryType)
      ..revision = expense.revision
      ..createdAt = expense.createdAt.toUtc()
      ..updatedAt = expense.updatedAt.toUtc()
      ..deletedAt = expense.deletedAt?.toUtc();
  }

  static ExpenseEntryType _toDomainEntryType(LedgerEntryType type) {
    return switch (type) {
      LedgerEntryType.expense => ExpenseEntryType.expense,
      LedgerEntryType.income => ExpenseEntryType.income,
    };
  }

  static LedgerEntryType _toDatabaseEntryType(ExpenseEntryType type) {
    return switch (type) {
      ExpenseEntryType.expense => LedgerEntryType.expense,
      ExpenseEntryType.income => LedgerEntryType.income,
    };
  }
}

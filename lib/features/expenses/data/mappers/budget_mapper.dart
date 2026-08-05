import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../domain/entities/budget.dart';

abstract final class BudgetMapper {
  static Budget toDomain(BudgetModel model) {
    return Budget(
      id: model.localId,
      period: _toDomainPeriod(model.periodType),
      amountMinor: model.amountMinor,
      currencyCode: model.currencyCode,
      currencyScale: model.currencyScale,
      isActive: model.isActive,
      revision: model.revision,
      createdAt: model.createdAt.toUtc(),
      updatedAt: model.updatedAt.toUtc(),
      deletedAt: model.deletedAt?.toUtc(),
    );
  }

  static BudgetModel toModel(Budget budget, {int? databaseId}) {
    return BudgetModel()
      ..id = databaseId ?? Isar.autoIncrement
      ..localId = budget.id
      ..periodType = _toDatabasePeriod(budget.period)
      ..amountMinor = budget.amountMinor
      ..currencyCode = budget.currencyCode
      ..currencyScale = budget.currencyScale
      ..isActive = budget.isActive
      ..revision = budget.revision
      ..createdAt = budget.createdAt.toUtc()
      ..updatedAt = budget.updatedAt.toUtc()
      ..deletedAt = budget.deletedAt?.toUtc();
  }

  static BudgetPeriod _toDomainPeriod(BudgetPeriodType type) {
    return switch (type) {
      BudgetPeriodType.weekly => BudgetPeriod.weekly,
      BudgetPeriodType.monthly => BudgetPeriod.monthly,
    };
  }

  static BudgetPeriodType _toDatabasePeriod(BudgetPeriod period) {
    return switch (period) {
      BudgetPeriod.weekly => BudgetPeriodType.weekly,
      BudgetPeriod.monthly => BudgetPeriodType.monthly,
    };
  }
}

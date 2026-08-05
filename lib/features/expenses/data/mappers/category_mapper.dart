import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import '../../domain/entities/expense_category.dart';

abstract final class CategoryMapper {
  static ExpenseCategory toDomain(CategoryModel model) {
    return ExpenseCategory(
      id: model.localId,
      name: model.name,
      iconCodePoint: model.iconCodePoint,
      colorValue: model.colorValue,
      isDefault: model.isDefault,
      isActive: model.isActive,
      sortOrder: model.sortOrder,
      createdAt: model.createdAt.toUtc(),
      updatedAt: model.updatedAt.toUtc(),
      deletedAt: model.deletedAt?.toUtc(),
    );
  }

  static CategoryModel toModel(ExpenseCategory category, {int? databaseId}) {
    return CategoryModel()
      ..id = databaseId ?? Isar.autoIncrement
      ..localId = category.id
      ..name = category.name
      ..iconCodePoint = category.iconCodePoint
      ..colorValue = category.colorValue
      ..isDefault = category.isDefault
      ..isActive = category.isActive
      ..sortOrder = category.sortOrder
      ..createdAt = category.createdAt.toUtc()
      ..updatedAt = category.updatedAt.toUtc()
      ..deletedAt = category.deletedAt?.toUtc();
  }
}

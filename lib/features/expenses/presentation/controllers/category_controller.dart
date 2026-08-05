import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/expense_category.dart';
import '../providers/category_budget_providers.dart';

part 'category_controller.g.dart';

@riverpod
class CategoryController extends _$CategoryController {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<ExpenseCategory>> build() async {
    await _ensureDefaults();

    return _loadCategories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<ExpenseCategory>>();

    state = await AsyncValue.guard(_loadCategories);
  }

  Future<Result<ExpenseCategory>> createCategory({
    required String name,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    final DateTime now = DateTime.now().toUtc();

    final ExpenseCategory category = ExpenseCategory(
      id: _uuid.v4(),
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      isDefault: false,
      isActive: true,
      sortOrder: 100,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(categoryRepositoryProvider).create(category);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<Result<ExpenseCategory>> updateCategory({
    required ExpenseCategory existing,
    required String name,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    final ExpenseCategory updated = existing.copyWith(
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
    );

    final result = await ref.read(categoryRepositoryProvider).update(updated);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<Result<bool>> deleteCategory(String id) async {
    final result = await ref.read(categoryRepositoryProvider).delete(id);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<void> _ensureDefaults() async {
    final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    final List<ExpenseCategory> defaults = <ExpenseCategory>[
      ExpenseCategory(
        id: 'food',
        name: 'Food',
        iconCodePoint: Icons.restaurant_outlined.codePoint,
        colorValue: 0xFFEF4444,
        isDefault: true,
        isActive: true,
        sortOrder: 0,
        createdAt: epoch,
        updatedAt: epoch,
      ),
      ExpenseCategory(
        id: 'travel',
        name: 'Travel',
        iconCodePoint: Icons.directions_car_outlined.codePoint,
        colorValue: 0xFF3B82F6,
        isDefault: true,
        isActive: true,
        sortOrder: 1,
        createdAt: epoch,
        updatedAt: epoch,
      ),
      ExpenseCategory(
        id: 'bills',
        name: 'Bills',
        iconCodePoint: Icons.receipt_outlined.codePoint,
        colorValue: 0xFFF59E0B,
        isDefault: true,
        isActive: true,
        sortOrder: 2,
        createdAt: epoch,
        updatedAt: epoch,
      ),
      ExpenseCategory(
        id: 'entertainment',
        name: 'Entertainment',
        iconCodePoint: Icons.movie_outlined.codePoint,
        colorValue: 0xFF8B5CF6,
        isDefault: true,
        isActive: true,
        sortOrder: 3,
        createdAt: epoch,
        updatedAt: epoch,
      ),
      ExpenseCategory(
        id: 'health',
        name: 'Health',
        iconCodePoint: Icons.medical_services_outlined.codePoint,
        colorValue: 0xFF10B981,
        isDefault: true,
        isActive: true,
        sortOrder: 4,
        createdAt: epoch,
        updatedAt: epoch,
      ),
    ];

    final Result<void> result = await ref
        .read(categoryRepositoryProvider)
        .ensureDefaults(defaults);

    result.fold(
      onSuccess: (void value) {},
      onFailure: (failure) {
        throw StateError(failure.message);
      },
    );
  }

  Future<List<ExpenseCategory>> _loadCategories() async {
    final result = await ref.read(categoryRepositoryProvider).getAllActive();

    return result.fold(
      onSuccess: (List<ExpenseCategory> categories) {
        return categories;
      },
      onFailure: (failure) {
        throw StateError(failure.message);
      },
    );
  }
}

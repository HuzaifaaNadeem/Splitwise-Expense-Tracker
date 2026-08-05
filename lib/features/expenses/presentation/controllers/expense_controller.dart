import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';

part 'expense_controller.g.dart';

@riverpod
class ExpenseController extends _$ExpenseController {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<Expense>> build() {
    return _loadExpenses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Expense>>();

    state = await AsyncValue.guard(_loadExpenses);
  }

  Future<Result<Expense>> createExpense({
    required String title,
    required int amountMinor,
    required String currencyCode,
    required int currencyScale,
    required String categoryId,
    required DateTime occurredAt,
    String? notes,
  }) async {
    final DateTime now = DateTime.now().toUtc();

    final Expense expense = Expense(
      id: _uuid.v4(),
      title: title.trim(),
      amountMinor: amountMinor,
      currencyCode: currencyCode.toUpperCase(),
      currencyScale: currencyScale,
      categoryId: categoryId.trim(),
      occurredAt: occurredAt.toUtc(),
      notes: _normalizeOptional(notes),
      entryType: ExpenseEntryType.expense,
      revision: 1,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(expenseRepositoryProvider).create(expense);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<Result<Expense>> updateExpense({
    required Expense existing,
    required String title,
    required int amountMinor,
    required String currencyCode,
    required int currencyScale,
    required String categoryId,
    required DateTime occurredAt,
    String? notes,
  }) async {
    final Expense changed = existing.copyWith(
      title: title.trim(),
      amountMinor: amountMinor,
      currencyCode: currencyCode.toUpperCase(),
      currencyScale: currencyScale,
      categoryId: categoryId.trim(),
      occurredAt: occurredAt.toUtc(),
      notes: _normalizeOptional(notes),
    );

    final result = await ref.read(expenseRepositoryProvider).update(changed);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<Result<bool>> deleteExpense(String id) async {
    final result = await ref.read(expenseRepositoryProvider).delete(id);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  Future<List<Expense>> _loadExpenses() async {
    final result = await ref.read(expenseRepositoryProvider).getAllActive();

    return result.fold(
      onSuccess: (List<Expense> expenses) => expenses,
      onFailure: (failure) {
        throw StateError(failure.message);
      },
    );
  }

  String? _normalizeOptional(String? value) {
    final String? trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

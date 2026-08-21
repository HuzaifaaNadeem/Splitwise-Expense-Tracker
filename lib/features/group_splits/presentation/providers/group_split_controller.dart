import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group_split.dart';
import 'group_split_providers.dart';

final groupSplitControllerProvider =
    NotifierProvider<GroupSplitController, AsyncValue<void>>(
      GroupSplitController.new,
    );

final class GroupSplitController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData<void>(null);
  }

  Future<bool> createSplit(GroupSplit split) async {
    state = const AsyncLoading<void>();

    final result = await ref.read(groupSplitRepositoryProvider).create(split);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupSplitsProvider(split.groupId));
        return true;
      },
      onFailure: (failure) {
        state = AsyncError<void>(
          StateError(failure.message),
          StackTrace.current,
        );
        return false;
      },
    );
  }

  Future<bool> updateSplit(GroupSplit split) async {
    state = const AsyncLoading<void>();

    final result = await ref.read(groupSplitRepositoryProvider).update(split);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupSplitsProvider(split.groupId));
        return true;
      },
      onFailure: (failure) {
        state = AsyncError<void>(
          StateError(failure.message),
          StackTrace.current,
        );
        return false;
      },
    );
  }

  Future<bool> deleteSplit({
    required String groupId,
    required String splitId,
  }) async {
    state = const AsyncLoading<void>();

    final result = await ref.read(groupSplitRepositoryProvider).delete(splitId);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupSplitsProvider(groupId));
        return true;
      },
      onFailure: (failure) {
        state = AsyncError<void>(
          StateError(failure.message),
          StackTrace.current,
        );
        return false;
      },
    );
  }
}

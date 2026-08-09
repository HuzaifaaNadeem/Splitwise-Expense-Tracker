import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import 'group_providers.dart';

final groupControllerProvider =
    NotifierProvider<GroupController, AsyncValue<void>>(GroupController.new);

final class GroupController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData<void>(null);
  }

  Future<bool> createGroup(Group group) async {
    state = const AsyncLoading<void>();

    final result = await ref.read(groupRepositoryProvider).create(group);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupsProvider);
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

  Future<bool> updateGroup(Group group) async {
    state = const AsyncLoading<void>();

    final result = await ref.read(groupRepositoryProvider).update(group);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupsProvider);
        ref.invalidate(groupByIdProvider(group.id));
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

  Future<bool> archiveGroup(String id) async {
    state = const AsyncLoading<void>();

    final result = await ref.read(groupRepositoryProvider).archive(id);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupsProvider);
        ref.invalidate(groupByIdProvider(id));
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

  Future<bool> deleteGroup(String id) async {
    state = const AsyncLoading<void>();

    final result = await ref.read(groupRepositoryProvider).delete(id);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupsProvider);
        ref.invalidate(groupByIdProvider(id));
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

  Future<bool> addMember(String groupId, GroupMember member) async {
    state = const AsyncLoading<void>();

    final result = await ref
        .read(groupRepositoryProvider)
        .addMember(groupId, member);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupsProvider);
        ref.invalidate(groupByIdProvider(groupId));
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

  Future<bool> updateMember(String groupId, GroupMember member) async {
    state = const AsyncLoading<void>();

    final result = await ref
        .read(groupRepositoryProvider)
        .updateMember(groupId, member);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupsProvider);
        ref.invalidate(groupByIdProvider(groupId));
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

  Future<bool> removeMember(String groupId, String memberId) async {
    state = const AsyncLoading<void>();

    final result = await ref
        .read(groupRepositoryProvider)
        .removeMember(groupId, memberId);

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(groupsProvider);
        ref.invalidate(groupByIdProvider(groupId));
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

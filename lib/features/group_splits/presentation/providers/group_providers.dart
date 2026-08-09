import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/database_provider.dart';
import '../../../../core/db/database_service.dart';
import '../../../../core/errors/result.dart';
import '../../data/datasources/group_local_data_source.dart';
import '../../data/repositories/isar_group_repository.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

final groupLocalDataSourceProvider = Provider<GroupLocalDataSource>((ref) {
  final DatabaseService databaseService = ref.watch(databaseServiceProvider);

  return GroupLocalDataSource(databaseService: databaseService);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final GroupLocalDataSource dataSource = ref.watch(
    groupLocalDataSourceProvider,
  );

  return IsarGroupRepository(localDataSource: dataSource);
});

final groupsProvider = FutureProvider<List<Group>>((ref) async {
  final Result<List<Group>> result = await ref
      .watch(groupRepositoryProvider)
      .getAllActive();

  return result.fold(
    onSuccess: (List<Group> groups) => groups,
    onFailure: (failure) {
      throw StateError(failure.message);
    },
  );
});

final groupByIdProvider = FutureProvider.family<Group?, String>((
  ref,
  String id,
) async {
  final Result<Group?> result = await ref
      .watch(groupRepositoryProvider)
      .getById(id);

  return result.fold(
    onSuccess: (Group? group) => group,
    onFailure: (failure) {
      throw StateError(failure.message);
    },
  );
});

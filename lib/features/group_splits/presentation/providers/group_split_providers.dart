import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/database_provider.dart';
import '../../../../core/db/database_service.dart';
import '../../../../core/errors/result.dart';
import '../../data/datasources/group_split_local_data_source.dart';
import '../../data/repositories/isar_group_split_repository.dart';
import '../../domain/entities/group_split.dart';
import '../../domain/repositories/group_split_repository.dart';

final groupSplitLocalDataSourceProvider = Provider<GroupSplitLocalDataSource>((
  Ref ref,
) {
  final DatabaseService databaseService = ref.watch(databaseServiceProvider);

  return GroupSplitLocalDataSource(databaseService: databaseService);
});

final groupSplitRepositoryProvider = Provider<GroupSplitRepository>((Ref ref) {
  final GroupSplitLocalDataSource localDataSource = ref.watch(
    groupSplitLocalDataSourceProvider,
  );

  return IsarGroupSplitRepository(localDataSource: localDataSource);
});

final groupSplitsProvider = FutureProvider.family<List<GroupSplit>, String>((
  Ref ref,
  String groupId,
) async {
  final Result<List<GroupSplit>> result = await ref
      .watch(groupSplitRepositoryProvider)
      .getByGroupId(groupId);

  return result.fold(
    onSuccess: (List<GroupSplit> splits) => splits,
    onFailure: (failure) {
      throw StateError(failure.message);
    },
  );
});

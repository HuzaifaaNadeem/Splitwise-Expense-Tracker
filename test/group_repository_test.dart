import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';

import 'package:splitwise_expense_tracker/core/db/database_service.dart';
import 'package:splitwise_expense_tracker/features/group_splits/data/datasources/group_local_data_source.dart';
import 'package:splitwise_expense_tracker/features/group_splits/data/repositories/isar_group_repository.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/group.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/group_member.dart';

void main() {
  late Isar isar;
  late DatabaseService databaseService;
  late GroupLocalDataSource dataSource;
  late IsarGroupRepository repository;

  setUpAll(() async {
    isar = await Isar.open(
      <CollectionSchema<Object?>>[GroupModelSchema],
      directory: '',
      name: 'group_repository_test',
    );

    databaseService = DatabaseService.forTesting(isar);

    dataSource = GroupLocalDataSource(databaseService: databaseService);

    repository = IsarGroupRepository(localDataSource: dataSource);
  });

  tearDownAll(() async {
    await isar.close(deleteFromDisk: true);
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.groupModels.clear();
    });
  });

  test('creates and retrieves a group with members', () async {
    final DateTime now = DateTime.now().toUtc();

    final Group group = Group(
      id: 'trip-hunza',
      name: 'Trip to Hunza',
      description: 'Northern trip',
      ownerMemberId: 'user-1',
      members: <GroupMember>[
        GroupMember(
          id: 'user-1',
          displayName: 'Huzaifa',
          isCurrentUser: true,
          joinedAt: now,
        ),
        GroupMember(id: 'user-2', displayName: 'Ali', joinedAt: now),
      ],
      createdAt: now,
      updatedAt: now,
    );

    final createResult = await repository.create(group);

    expect(createResult.isSuccess, isTrue);

    final readResult = await repository.getById('trip-hunza');

    expect(readResult.isSuccess, isTrue);

    final Group? stored = readResult.fold(
      onSuccess: (Group? value) => value,
      onFailure: (_) => null,
    );

    expect(stored, isNotNull);
    expect(stored!.name, 'Trip to Hunza');
    expect(stored.members, hasLength(2));
    expect(stored.currentUser?.displayName, 'Huzaifa');
  });

  test('updates a group and increments revision', () async {
    final DateTime now = DateTime.now().toUtc();

    final Group group = Group(
      id: 'roommates',
      name: 'Roommates',
      ownerMemberId: 'user-1',
      members: <GroupMember>[
        GroupMember(id: 'user-1', displayName: 'Huzaifa', joinedAt: now),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await repository.create(group);

    final Group updated = group.copyWith(name: 'Apartment Roommates');

    final updateResult = await repository.update(updated);

    expect(updateResult.isSuccess, isTrue);

    final readResult = await repository.getById('roommates');

    final Group? stored = readResult.fold(
      onSuccess: (Group? value) => value,
      onFailure: (_) => null,
    );

    expect(stored, isNotNull);
    expect(stored!.name, 'Apartment Roommates');
    expect(stored.revision, 2);
  });

  test('archives a group', () async {
    final DateTime now = DateTime.now().toUtc();

    final Group group = Group(
      id: 'archived-group',
      name: 'Old Trip',
      ownerMemberId: 'user-1',
      members: <GroupMember>[
        GroupMember(id: 'user-1', displayName: 'Huzaifa', joinedAt: now),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await repository.create(group);

    final result = await repository.archive('archived-group');

    expect(result.isSuccess, isTrue);

    final activeGroups = await repository.getAllActive();

    final List<Group>? groups = activeGroups.fold(
      onSuccess: (List<Group> value) => value,
      onFailure: (_) => null,
    );

    expect(groups, isNotNull);
    expect(groups, isEmpty);
  });

  test('soft deletes a group', () async {
    final DateTime now = DateTime.now().toUtc();

    final Group group = Group(
      id: 'delete-group',
      name: 'Delete Me',
      ownerMemberId: 'user-1',
      members: <GroupMember>[
        GroupMember(id: 'user-1', displayName: 'Huzaifa', joinedAt: now),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await repository.create(group);

    final result = await repository.delete('delete-group');

    expect(result.isSuccess, isTrue);

    final readResult = await repository.getById('delete-group');

    final Group? stored = readResult.fold(
      onSuccess: (Group? value) => value,
      onFailure: (_) => null,
    );

    expect(stored, isNull);
  });
}

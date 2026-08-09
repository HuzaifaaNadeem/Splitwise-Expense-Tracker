import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group.dart';
import '../providers/group_providers.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Group>> groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load groups',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(groupsProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (List<Group> groups) {
          if (groups.isEmpty) {
            return _EmptyGroupsState(
              onCreateGroup: () {
                unawaited(_openCreateGroup(context));
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(groupsProvider);
              await ref.read(groupsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: groups.length,
              itemBuilder: (BuildContext context, int index) {
                final Group group = groups[index];

                return _GroupCard(
                  group: group,
                  onTap: () {
                    unawaited(_openGroupDetails(context, group.id));
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          unawaited(_openCreateGroup(context));
        },
        icon: const Icon(Icons.add),
        label: const Text('Create group'),
      ),
    );
  }

  Future<void> _openCreateGroup(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const CreateGroupScreen(),
      ),
    );
  }

  Future<void> _openGroupDetails(BuildContext context, String groupId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => GroupDetailsScreen(groupId: groupId),
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  const _EmptyGroupsState({required this.onCreateGroup});

  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'No groups yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Create groups for trips, roommates, friends, and shared bills.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateGroup,
              icon: const Icon(Icons.add),
              label: const Text('Create your first group'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.onTap});

  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int activeMemberCount = group.activeMembers.length;

    final String groupInitial = group.name.trim().isEmpty
        ? '?'
        : group.name.trim().substring(0, 1).toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                child: Text(
                  groupInitial,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (group.description != null &&
                        group.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '$activeMemberCount '
                      '${activeMemberCount == 1 ? 'member' : 'members'}'
                      ' • ${group.defaultCurrencyCode}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

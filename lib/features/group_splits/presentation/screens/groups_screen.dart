import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group.dart';
import '../providers/group_providers.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);

    _searchController.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Group>> groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          unawaited(_openCreateGroup(context));
        },
        icon: const Icon(Icons.add),
        label: const Text('Create group'),
      ),
      body: groupsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (Object error, StackTrace stackTrace) {
          return _GroupsErrorState(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(groupsProvider);
            },
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

          final List<Group> visibleGroups = _filterGroups(groups);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(groupsProvider);

              await ref.read(groupsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 110),
              children: <Widget>[
                _GroupsHeader(
                  groupCount: groups.length,
                  visibleCount: visibleGroups.length,
                ),
                const SizedBox(height: 22),
                _GroupToolbar(
                  controller: _searchController,
                  onClear: _searchController.clear,
                ),
                const SizedBox(height: 24),
                if (visibleGroups.isEmpty)
                  _NoMatchingGroups(onClear: _searchController.clear)
                else
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final double cardWidth;

                          if (constraints.maxWidth >= 1200) {
                            cardWidth = (constraints.maxWidth - 32) / 3;
                          } else if (constraints.maxWidth >= 760) {
                            cardWidth = (constraints.maxWidth - 16) / 2;
                          } else {
                            cardWidth = constraints.maxWidth;
                          }

                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: <Widget>[
                              for (final Group group in visibleGroups)
                                SizedBox(
                                  width: cardWidth,
                                  child: _GroupCard(
                                    group: group,
                                    onTap: () {
                                      unawaited(
                                        _openGroupDetails(context, group.id),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Group> _filterGroups(List<Group> groups) {
    final String query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return groups;
    }

    return groups
        .where((Group group) {
          final String description =
              group.description?.trim().toLowerCase() ?? '';

          return group.name.toLowerCase().contains(query) ||
              description.contains(query) ||
              group.defaultCurrencyCode.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  Future<void> _openCreateGroup(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const CreateGroupScreen();
        },
      ),
    );
  }

  Future<void> _openGroupDetails(BuildContext context, String groupId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return GroupDetailsScreen(groupId: groupId);
        },
      ),
    );
  }
}

class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader({required this.groupCount, required this.visibleCount});

  final int groupCount;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 18,
      runSpacing: 18,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Shared expense groups',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage shared expenses, balances and settlements.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.groups_outlined, size: 19, color: colors.primary),
              const SizedBox(width: 9),
              Text(
                visibleCount == groupCount
                    ? '$groupCount active ${groupCount == 1 ? 'group' : 'groups'}'
                    : '$visibleCount of $groupCount groups',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupToolbar extends StatelessWidget {
  const _GroupToolbar({required this.controller, required this.onClear});

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search groups',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: onClear,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final int activeMemberCount = group.activeMembers.length;

    final String initial = group.name.trim().isEmpty
        ? '?'
        : group.name.trim().substring(0, 1).toUpperCase();

    final String description = group.description?.trim().isNotEmpty ?? false
        ? group.description!.trim()
        : 'Shared expense workspace';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                group.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _GroupMetric(
                      icon: Icons.people_outline,
                      value: '$activeMemberCount',
                      label: activeMemberCount == 1 ? 'Member' : 'Members',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GroupMetric(
                      icon: Icons.payments_outlined,
                      value: group.defaultCurrencyCode,
                      label: 'Currency',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupMetric extends StatelessWidget {
  const _GroupMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 19, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  const _EmptyGroupsState({required this.onCreateGroup});

  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(38),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.groups_outlined,
                      size: 36,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'No groups yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create groups for trips, roommates, teams, projects '
                    'and other shared expenses.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
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
          ),
        ),
      ),
    );
  }
}

class _NoMatchingGroups extends StatelessWidget {
  const _NoMatchingGroups({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(38),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.search_off_outlined,
              size: 46,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              'No matching groups',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different search term.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              label: const Text('Clear search'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsErrorState extends StatelessWidget {
  const _GroupsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load groups',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

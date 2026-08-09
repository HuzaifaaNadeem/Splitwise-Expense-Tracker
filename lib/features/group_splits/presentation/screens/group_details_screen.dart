import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import '../providers/group_controller.dart';
import '../providers/group_providers.dart';

class GroupDetailsScreen extends ConsumerWidget {
  const GroupDetailsScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Group?> groupAsync = ref.watch(groupByIdProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group details'),
        actions: [
          groupAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (Group? group) {
              if (group == null) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (String value) async {
                  if (value == 'archive') {
                    await _showArchiveDialog(context, ref, group);
                  } else if (value == 'delete') {
                    await _showDeleteDialog(context, ref, group);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return const [
                    PopupMenuItem<String>(
                      value: 'archive',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.archive_outlined),
                        title: Text('Archive group'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete group'),
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: groupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          return _ErrorState(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(groupByIdProvider(groupId));
            },
          );
        },
        data: (Group? group) {
          if (group == null) {
            return const _NotFoundState();
          }

          return _GroupDetailsContent(
            group: group,
            onArchive: () async {
              await _showArchiveDialog(context, ref, group);
            },
            onDelete: () async {
              await _showDeleteDialog(context, ref, group);
            },
          );
        },
      ),
    );
  }

  Future<void> _showArchiveDialog(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Archive group?'),
          content: Text(
            '“${group.name}” will be removed from your active groups. '
            'Its data will remain available for existing records.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool success = await ref
        .read(groupControllerProvider.notifier)
        .archiveGroup(group.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group archived successfully.')),
      );
    } else {
      _showControllerError(context, ref);
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete group?'),
          content: Text(
            'This will permanently remove “${group.name}” from the active '
            'group list. This action cannot be undone from the app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool success = await ref
        .read(groupControllerProvider.notifier)
        .deleteGroup(group.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group deleted successfully.')),
      );
    } else {
      _showControllerError(context, ref);
    }
  }

  void _showControllerError(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> state = ref.read(groupControllerProvider);

    final String message = state.when(
      data: (_) => 'The operation could not be completed.',
      loading: () => 'The operation is still in progress.',
      error: (Object error, StackTrace stackTrace) => error.toString(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _GroupDetailsContent extends StatelessWidget {
  const _GroupDetailsContent({
    required this.group,
    required this.onArchive,
    required this.onDelete,
  });

  final Group group;
  final Future<void> Function() onArchive;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<GroupMember> activeMembers = group.activeMembers;

    final String initial = group.name.trim().isEmpty
        ? '?'
        : group.name.trim().substring(0, 1).toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Center(
          child: CircleAvatar(
            radius: 42,
            child: Text(
              initial,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          group.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (group.description != null &&
            group.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            group.description!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.payments_outlined,
                title: 'Currency',
                value: group.defaultCurrencyCode,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.groups_outlined,
                title: 'Members',
                value: '${activeMembers.length}',
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                title: 'Created',
                value: _formatDate(group.createdAt),
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.update_outlined,
                title: 'Last updated',
                value: _formatDate(group.updatedAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Members',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (activeMembers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No active members.')),
            ),
          )
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int index = 0; index < activeMembers.length; index++) ...[
                  _MemberTile(member: activeMembers[index]),
                  if (index < activeMembers.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              ],
            ),
          ),
        const SizedBox(height: 32),
        Text(
          'Group actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            await onArchive();
          },
          icon: const Icon(Icons.archive_outlined),
          label: const Text('Archive group'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            await onDelete();
          },
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          label: Text(
            'Delete group',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Expenses and settlements for this group will be added '
                  'in the next group-splits step.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final DateTime localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    final String initial = member.displayName.trim().isEmpty
        ? '?'
        : member.displayName.trim().substring(0, 1).toUpperCase();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(member.avatarColorValue),
        child: Text(
          initial,
          style: TextStyle(
            color: _textColorForBackground(member.avatarColorValue),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        member.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: member.email == null || member.email!.trim().isEmpty
          ? null
          : Text(member.email!),
      trailing: member.isCurrentUser ? const Chip(label: Text('You')) : null,
    );
  }

  Color _textColorForBackground(int colorValue) {
    final Color color = Color(colorValue);
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Unable to load group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_outlined, size: 56),
            SizedBox(height: 16),
            Text(
              'Group not found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This group may have been deleted or archived.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

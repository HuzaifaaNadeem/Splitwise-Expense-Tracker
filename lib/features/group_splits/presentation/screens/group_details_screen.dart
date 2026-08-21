import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/debt_settlement.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/group_split.dart';
import '../../domain/entities/member_balance.dart';
import '../../domain/services/debt_settlement_calculator.dart';
import '../../domain/services/group_balance_calculator.dart';
import '../providers/group_controller.dart';
import '../providers/group_providers.dart';
import '../providers/group_split_controller.dart';
import '../providers/group_split_providers.dart';
import '../widgets/group_pdf_export_button.dart';
import 'add_group_expense_screen.dart';

class GroupDetailsScreen extends ConsumerWidget {
  const GroupDetailsScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Group?> groupAsync = ref.watch(groupByIdProvider(groupId));

    final AsyncValue<List<GroupSplit>> splitsAsync = ref.watch(
      groupSplitsProvider(groupId),
    );

    return Scaffold(
      key: const Key('group_details_screen'),
      appBar: AppBar(
        title: const Text('Group details'),
        actions: [
          groupAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (Object _, StackTrace _) => const SizedBox.shrink(),
            data: (Group? group) {
              if (group == null) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'archive') {
                    unawaited(_showArchiveDialog(context, ref, group));
                  } else if (value == 'delete') {
                    unawaited(_showDeleteDialog(context, ref, group));
                  }
                },
                itemBuilder: (BuildContext context) {
                  return const <PopupMenuEntry<String>>[
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
            splitsAsync: splitsAsync,
            onAddExpense: () {
              unawaited(_openAddExpense(context, ref, group));
            },
            onDeleteExpense: (GroupSplit split) {
              unawaited(_confirmDeleteExpense(context, ref, split));
            },
            onArchive: () {
              unawaited(_showArchiveDialog(context, ref, group));
            },
            onDelete: () {
              unawaited(_showDeleteDialog(context, ref, group));
            },
          );
        },
      ),
    );
  }

  Future<void> _openAddExpense(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AddGroupExpenseScreen(group: group);
        },
      ),
    );

    if (!context.mounted) {
      return;
    }

    ref.invalidate(groupSplitsProvider(group.id));
  }

  Future<void> _confirmDeleteExpense(
    BuildContext context,
    WidgetRef ref,
    GroupSplit split,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: Text('Delete “${split.title}” from this group?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
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
        .read(groupSplitControllerProvider.notifier)
        .deleteSplit(groupId: split.groupId, splitId: split.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Group expense deleted.')));
      return;
    }

    final AsyncValue<void> state = ref.read(groupSplitControllerProvider);

    final String message = state.when(
      data: (_) => 'Unable to delete the group expense.',
      loading: () => 'The operation is still in progress.',
      error: (Object error, StackTrace stackTrace) => error.toString(),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            '“${group.name}” will be removed from your '
            'active groups. Existing records will remain.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
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
      _showGroupControllerError(context, ref);
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
            'This will remove “${group.name}” from the '
            'active group list.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
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
      _showGroupControllerError(context, ref);
    }
  }

  void _showGroupControllerError(BuildContext context, WidgetRef ref) {
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
    required this.splitsAsync,
    required this.onAddExpense,
    required this.onDeleteExpense,
    required this.onArchive,
    required this.onDelete,
  });

  final Group group;
  final AsyncValue<List<GroupSplit>> splitsAsync;
  final VoidCallback onAddExpense;
  final ValueChanged<GroupSplit> onDeleteExpense;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<GroupMember> activeMembers = group.activeMembers;

    final String initial = group.name.trim().isEmpty
        ? '?'
        : group.name.trim().substring(0, 1).toUpperCase();

    return ListView(
      key: const Key('group_details_list'),
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
          Text(group.description!, textAlign: TextAlign.center),
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
            ],
          ),
        ),

        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: Text(
                'Group expenses',
                key: const Key('group_expenses_heading'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton.icon(
              key: const Key('add_group_expense_button'),
              onPressed: activeMembers.isEmpty ? null : onAddExpense,
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        splitsAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (Object error, StackTrace stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Unable to load expenses: $error'),
            ),
          ),
          data: (List<GroupSplit> splits) {
            if (splits.isEmpty) {
              return const Card(
                key: Key('group_expenses_empty_state'),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'No group expenses yet',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Add the first shared expense '
                        'to start tracking balances.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (final GroupSplit split in splits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _GroupExpenseCard(
                      key: ValueKey<String>('group_expense_${split.id}'),
                      split: split,
                      group: group,
                      onDelete: () {
                        onDeleteExpense(split);
                      },
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        Text(
          'Balances & settlements',
          key: const Key('group_balances_heading'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        splitsAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (Object error, StackTrace stackTrace) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Unable to calculate balances: $error'),
            ),
          ),
          data: (List<GroupSplit> splits) {
            return _GroupFinanceSummary(group: group, splits: splits);
          },
        ),

        const SizedBox(height: 28),

        Text(
          'Members',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

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

        GroupPdfExportButton(group: group),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: onArchive,
          icon: const Icon(Icons.archive_outlined),
          label: const Text('Archive group'),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          label: Text(
            'Delete group',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final DateTime local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _GroupFinanceSummary extends StatelessWidget {
  const _GroupFinanceSummary({required this.group, required this.splits});

  final Group group;
  final List<GroupSplit> splits;

  static const GroupBalanceCalculator _balanceCalculator =
      GroupBalanceCalculator();

  static const DebtSettlementCalculator _settlementCalculator =
      DebtSettlementCalculator();

  @override
  Widget build(BuildContext context) {
    final List<String> memberIds = group.members
        .map((GroupMember member) => member.id)
        .toList(growable: false);

    try {
      final List<MemberBalance> balances = _balanceCalculator.calculate(
        memberIds: memberIds,
        splits: splits,
      );

      final List<DebtSettlement> settlements = _settlementCalculator.calculate(
        balances,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BalancesCard(group: group, balances: balances),
          const SizedBox(height: 12),
          _SettlementsCard(group: group, settlements: settlements),
        ],
      );
    } on Object catch (error) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 12),
              Expanded(child: Text('Unable to calculate balances: $error')),
            ],
          ),
        ),
      );
    }
  }
}

class _BalancesCard extends StatelessWidget {
  const _BalancesCard({required this.group, required this.balances});

  final Group group;
  final List<MemberBalance> balances;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('group_balances_card'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined),
            title: Text(
              'Net balances',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          for (int index = 0; index < balances.length; index++) ...[
            _BalanceTile(group: group, balance: balances[index]),
            if (index < balances.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.group, required this.balance});

  final Group group;
  final MemberBalance balance;

  @override
  Widget build(BuildContext context) {
    final GroupMember? member = _findMember(group, balance.memberId);

    final String name = member?.displayName ?? 'Unknown member';

    final bool isCurrentUser = member?.isCurrentUser ?? false;

    final int amount = balance.balanceMinor.abs();

    final String status;

    if (balance.balanceMinor > 0) {
      status = isCurrentUser ? 'You are owed' : 'Is owed';
    } else if (balance.balanceMinor < 0) {
      status = isCurrentUser ? 'You owe' : 'Owes';
    } else {
      status = 'Settled';
    }

    return ListTile(
      title: Text(isCurrentUser ? '$name (You)' : name),
      subtitle: Text(status),
      trailing: balance.balanceMinor == 0
          ? const Icon(Icons.check_circle_outline)
          : Text(
              '${group.defaultCurrencyCode} '
              '${_formatMinorAmount(amount, group.defaultCurrencyScale)}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
    );
  }
}

class _SettlementsCard extends StatelessWidget {
  const _SettlementsCard({required this.group, required this.settlements});

  final Group group;
  final List<DebtSettlement> settlements;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('group_settlement_suggestions_card'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text(
              'Settlement suggestions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Suggested payments to settle group balances.'),
          ),
          const Divider(height: 1),
          if (settlements.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Everyone is settled',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          else
            for (int index = 0; index < settlements.length; index++) ...[
              _SettlementTile(group: group, settlement: settlements[index]),
              if (index < settlements.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
        ],
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  const _SettlementTile({required this.group, required this.settlement});

  final Group group;
  final DebtSettlement settlement;

  @override
  Widget build(BuildContext context) {
    final GroupMember? fromMember = _findMember(group, settlement.fromMemberId);

    final GroupMember? toMember = _findMember(group, settlement.toMemberId);

    final String fromName = fromMember?.isCurrentUser ?? false
        ? 'You'
        : fromMember?.displayName ?? 'Unknown';

    final String toName = toMember?.isCurrentUser ?? false
        ? 'You'
        : toMember?.displayName ?? 'Unknown';

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.arrow_forward)),
      title: Text('$fromName → $toName'),
      subtitle: const Text('Pay'),
      trailing: Text(
        '${group.defaultCurrencyCode} '
        '${_formatMinorAmount(settlement.amountMinor, group.defaultCurrencyScale)}',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _GroupExpenseCard extends StatelessWidget {
  const _GroupExpenseCard({
    required this.split,
    required this.group,
    required this.onDelete,
    super.key,
  });

  final GroupSplit split;
  final Group group;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final GroupMember? payer = _findMember(group, split.paidByMemberId);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
        title: Text(
          split.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Paid by ${payer?.displayName ?? 'Unknown'}'
          ' • ${split.shares.length} '
          '${split.shares.length == 1 ? 'member' : 'members'}'
          '\n${_formatDate(split.occurredAt)}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${split.currencyCode} '
              '${_formatMinorAmount(split.totalAmountMinor, split.currencyScale)}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) {
                return const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete expense'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
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
            color: _foregroundColor(member.avatarColorValue),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(member.displayName),
      subtitle: member.email == null || member.email!.trim().isEmpty
          ? null
          : Text(member.email!),
      trailing: member.isCurrentUser ? const Chip(label: Text('You')) : null,
    );
  }

  Color _foregroundColor(int colorValue) {
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
    return const Center(child: Text('Group not found.'));
  }
}

GroupMember? _findMember(Group group, String memberId) {
  for (final GroupMember member in group.members) {
    if (member.id == memberId) {
      return member;
    }
  }

  return null;
}

String _formatMinorAmount(int amountMinor, int scale) {
  final int absoluteAmount = amountMinor.abs();

  int divisor = 1;

  for (int index = 0; index < scale; index++) {
    divisor *= 10;
  }

  final int whole = absoluteAmount ~/ divisor;

  if (scale == 0) {
    return whole.toString();
  }

  final int fraction = absoluteAmount % divisor;

  return '$whole.'
      '${fraction.toString().padLeft(scale, '0')}';
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
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

const String _settlementTitlePrefix = 'Settlement payment: ';

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
        actions: <Widget>[
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
            onAddMember: () {
              unawaited(_showAddMemberDialog(context, ref, group));
            },
            onRemoveMember: (GroupMember member) {
              unawaited(_showRemoveMemberDialog(context, ref, group, member));
            },
            onAddExpense: () {
              unawaited(_openAddExpense(context, ref, group));
            },
            onDeleteExpense: (GroupSplit split) {
              unawaited(_confirmDeleteExpense(context, ref, split));
            },
            onSettle: (DebtSettlement settlement) {
              unawaited(_showSettlementDialog(context, ref, group, settlement));
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

  Future<void> _showAddMemberDialog(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final _NewMemberInput? input = await showDialog<_NewMemberInput>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _AddMemberDialog();
      },
    );

    if (input == null || !context.mounted) {
      return;
    }

    final String normalizedName = input.name.trim().toLowerCase();

    final bool duplicateName = group.activeMembers.any((GroupMember member) {
      return member.displayName.trim().toLowerCase() == normalizedName;
    });

    if (duplicateName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A member with this name already exists.'),
        ),
      );
      return;
    }

    if (input.email != null) {
      final String normalizedEmail = input.email!.trim().toLowerCase();

      final bool duplicateEmail = group.activeMembers.any((GroupMember member) {
        return member.email?.trim().toLowerCase() == normalizedEmail;
      });

      if (duplicateEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A member with this email already exists.'),
          ),
        );
        return;
      }
    }

    final DateTime now = DateTime.now().toUtc();

    final GroupMember member = GroupMember(
      id: 'member-${now.microsecondsSinceEpoch}',
      displayName: input.name,
      email: input.email,
      avatarColorValue: _memberColorFor(group.activeMembers.length),
      isCurrentUser: false,
      isActive: true,
      joinedAt: now,
    );

    final Result<Group> result = await ref
        .read(groupRepositoryProvider)
        .addMember(group.id, member);

    if (!context.mounted) {
      return;
    }

    String? failureMessage;

    final bool success = result.fold(
      onSuccess: (Group _) => true,
      onFailure: (failure) {
        failureMessage = failure.message;
        return false;
      },
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failureMessage ?? 'Unable to add the member.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ref.invalidate(groupByIdProvider(group.id));

    ref.invalidate(groupsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${input.name} added to the group.')),
    );
  }

  Future<void> _showRemoveMemberDialog(
    BuildContext context,
    WidgetRef ref,
    Group group,
    GroupMember member,
  ) async {
    if (member.isCurrentUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot remove yourself from the group.'),
        ),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove member?'),
          content: Text(
            'Remove "${member.displayName}" from '
            '"${group.name}"?\n\n'
            'Existing expense records involving this '
            'member will remain available.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              key: const Key('confirm_remove_member_button'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.person_remove_outlined),
              label: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final Result<Group> result = await ref
        .read(groupRepositoryProvider)
        .removeMember(group.id, member.id);

    if (!context.mounted) {
      return;
    }

    String? failureMessage;

    final bool success = result.fold(
      onSuccess: (Group _) => true,
      onFailure: (failure) {
        failureMessage = failure.message;
        return false;
      },
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failureMessage ?? 'Unable to remove the member.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ref.invalidate(groupByIdProvider(group.id));

    ref.invalidate(groupsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${member.displayName} removed from the group.')),
    );
  }

  Future<void> _showSettlementDialog(
    BuildContext context,
    WidgetRef ref,
    Group group,
    DebtSettlement settlement,
  ) async {
    final GroupMember? fromMember = _findMember(group, settlement.fromMemberId);

    final GroupMember? toMember = _findMember(group, settlement.toMemberId);

    if (fromMember == null || toMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify the members for this payment.'),
        ),
      );
      return;
    }

    final int? amountMinor = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _SettlementPaymentDialog(
          fromName: fromMember.isCurrentUser
              ? '${fromMember.displayName} (You)'
              : fromMember.displayName,
          toName: toMember.isCurrentUser
              ? '${toMember.displayName} (You)'
              : toMember.displayName,
          currencyCode: group.defaultCurrencyCode,
          currencyScale: group.defaultCurrencyScale,
          maximumAmountMinor: settlement.amountMinor,
        );
      },
    );

    if (amountMinor == null || amountMinor <= 0 || !context.mounted) {
      return;
    }

    final DateTime now = DateTime.now().toUtc();

    final GroupSplit payment = GroupSplit(
      id:
          '${group.id}-settlement-'
          '${now.microsecondsSinceEpoch}',
      groupId: group.id,
      title:
          '$_settlementTitlePrefix'
          '${fromMember.displayName} → '
          '${toMember.displayName}',
      notes:
          'Recorded settlement payment between '
          '${fromMember.displayName} and '
          '${toMember.displayName}.',
      totalAmountMinor: amountMinor,
      currencyCode: group.defaultCurrencyCode,
      currencyScale: group.defaultCurrencyScale,
      paidByMemberId: fromMember.id,
      occurredAt: now,
      splitMethod: GroupSplitMethod.exact,
      shares: <GroupSplitShare>[
        GroupSplitShare(memberId: toMember.id, owedAmountMinor: amountMinor),
      ],
      createdAt: now,
      updatedAt: now,
    );

    final bool success = await ref
        .read(groupSplitControllerProvider.notifier)
        .createSplit(payment);

    if (!context.mounted) {
      return;
    }

    if (!success) {
      final AsyncValue<void> state = ref.read(groupSplitControllerProvider);

      final String message = state.when(
        data: (_) => 'Unable to record the settlement payment.',
        loading: () => 'The payment is still being recorded.',
        error: (Object error, StackTrace stackTrace) => error.toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ref.invalidate(groupSplitsProvider(group.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment of ${group.defaultCurrencyCode} '
          '${_formatMinorAmount(amountMinor, group.defaultCurrencyScale)} recorded successfully.',
        ),
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
    final bool settlementPayment = _isSettlementPayment(split);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            settlementPayment
                ? 'Delete settlement payment?'
                : 'Delete expense?',
          ),
          content: Text(
            settlementPayment
                ? 'Deleting this payment will restore '
                      'the previous outstanding balances.'
                : 'Delete "${split.title}" from this group?',
          ),
          actions: <Widget>[
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            settlementPayment
                ? 'Settlement payment deleted.'
                : 'Group expense deleted.',
          ),
        ),
      );
      return;
    }

    final AsyncValue<void> state = ref.read(groupSplitControllerProvider);

    final String message = state.when(
      data: (_) => 'Unable to delete the transaction.',
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
            '"${group.name}" will be removed from your '
            'active groups. Existing records will remain.',
          ),
          actions: <Widget>[
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
            'This will remove "${group.name}" '
            'from the active group list.',
          ),
          actions: <Widget>[
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

  static int _memberColorFor(int index) {
    const List<int> colors = <int>[
      0xFF2563EB,
      0xFF7C3AED,
      0xFF059669,
      0xFFEA580C,
      0xFFDB2777,
      0xFF0891B2,
      0xFF4F46E5,
      0xFF65A30D,
    ];

    return colors[index % colors.length];
  }
}

class _NewMemberInput {
  const _NewMemberInput({required this.name, required this.email});

  final String name;
  final String? email;
}

class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog();

  @override
  State<_AddMemberDialog> createState() {
    return _AddMemberDialogState();
  }
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add member'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                key: const Key('add_member_name_field'),
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Ali',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the member name.';
                  }

                  if (value.trim().length < 2) {
                    return 'Name must contain at least '
                        '2 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('add_member_email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'e.g. ali@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (String? value) {
                  final String email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return null;
                  }

                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Enter a valid email address.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('confirm_add_member_button'),
          onPressed: _submit,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add member'),
        ),
      ],
    );
  }

  void _submit() {
    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final String name = _nameController.text.trim();

    final String email = _emailController.text.trim();

    Navigator.of(
      context,
    ).pop(_NewMemberInput(name: name, email: email.isEmpty ? null : email));
  }
}

class _SettlementPaymentDialog extends StatefulWidget {
  const _SettlementPaymentDialog({
    required this.fromName,
    required this.toName,
    required this.currencyCode,
    required this.currencyScale,
    required this.maximumAmountMinor,
  });

  final String fromName;
  final String toName;
  final String currencyCode;
  final int currencyScale;
  final int maximumAmountMinor;

  @override
  State<_SettlementPaymentDialog> createState() {
    return _SettlementPaymentDialogState();
  }
}

class _SettlementPaymentDialogState extends State<_SettlementPaymentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: _formatMinorAmount(widget.maximumAmountMinor, widget.currencyScale),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Record settlement payment'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SettlementPartyRow(label: 'From', value: widget.fromName),
              const SizedBox(height: 10),
              _SettlementPartyRow(label: 'To', value: widget.toName),
              const SizedBox(height: 18),
              Text('Outstanding amount', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                '${widget.currencyCode} '
                '${_formatMinorAmount(widget.maximumAmountMinor, widget.currencyScale)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('settlement_amount_field'),
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Payment amount',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  suffixText: widget.currencyCode,
                  border: const OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final int? amount = _parseMinorAmount(
                    value ?? '',
                    widget.currencyScale,
                  );

                  if (amount == null) {
                    return 'Enter a valid amount.';
                  }

                  if (amount <= 0) {
                    return 'Payment must be greater '
                        'than zero.';
                  }

                  if (amount > widget.maximumAmountMinor) {
                    return 'Payment cannot exceed the '
                        'outstanding amount.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(
                'You can record the full amount or '
                'enter a smaller amount for a partial payment.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('confirm_settlement_payment_button'),
          onPressed: _submit,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Record payment'),
        ),
      ],
    );
  }

  void _submit() {
    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final int? amount = _parseMinorAmount(
      _amountController.text,
      widget.currencyScale,
    );

    if (amount == null || amount <= 0) {
      return;
    }

    Navigator.of(context).pop(amount);
  }
}

class _SettlementPartyRow extends StatelessWidget {
  const _SettlementPartyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 60,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _GroupDetailsContent extends StatelessWidget {
  const _GroupDetailsContent({
    required this.group,
    required this.splitsAsync,
    required this.onAddMember,
    required this.onRemoveMember,
    required this.onAddExpense,
    required this.onDeleteExpense,
    required this.onSettle,
    required this.onArchive,
    required this.onDelete,
  });

  final Group group;
  final AsyncValue<List<GroupSplit>> splitsAsync;
  final VoidCallback onAddMember;
  final ValueChanged<GroupMember> onRemoveMember;
  final VoidCallback onAddExpense;
  final ValueChanged<GroupSplit> onDeleteExpense;
  final ValueChanged<DebtSettlement> onSettle;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final List<GroupMember> activeMembers = group.activeMembers;

    return ListView(
      key: const Key('group_details_list'),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
      children: <Widget>[
        _GroupOverviewCard(
          group: group,
          activeMemberCount: activeMembers.length,
        ),
        const SizedBox(height: 30),
        _SectionHeader(
          title: 'Group expenses',
          subtitle: 'Shared transactions recorded for this group.',
          titleKey: const Key('group_expenses_heading'),
          action: FilledButton.icon(
            key: const Key('add_group_expense_button'),
            onPressed: activeMembers.isEmpty ? null : onAddExpense,
            icon: const Icon(Icons.add),
            label: const Text('Add expense'),
          ),
        ),
        const SizedBox(height: 14),
        splitsAsync.when(
          loading: () => const _SectionLoadingCard(),
          error: (Object error, StackTrace stackTrace) =>
              _SectionErrorCard(message: 'Unable to load expenses: $error'),
          data: (List<GroupSplit> splits) {
            final List<GroupSplit> expenses = splits
                .where((GroupSplit split) => !_isSettlementPayment(split))
                .toList(growable: false);

            if (expenses.isEmpty) {
              return const Card(
                key: Key('group_expenses_empty_state'),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: _InlineEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No group expenses yet',
                    message:
                        'Add the first shared expense to start tracking balances.',
                  ),
                ),
              );
            }

            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  for (
                    int index = 0;
                    index < expenses.length;
                    index++
                  ) ...<Widget>[
                    _GroupExpenseCard(
                      key: ValueKey<String>(
                        'group_expense_${expenses[index].id}',
                      ),
                      split: expenses[index],
                      group: group,
                      onDelete: () {
                        onDeleteExpense(expenses[index]);
                      },
                    ),
                    if (index < expenses.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        _SectionHeader(
          title: 'Balances & settlements',
          subtitle: 'See who owes whom and record settlement payments.',
          titleKey: const Key('group_balances_heading'),
        ),
        const SizedBox(height: 14),
        splitsAsync.when(
          loading: () => const _SectionLoadingCard(),
          error: (Object error, StackTrace stackTrace) => _SectionErrorCard(
            message: 'Unable to calculate balances: $error',
          ),
          data: (List<GroupSplit> splits) {
            return _GroupFinanceSummary(
              group: group,
              splits: splits,
              onSettle: onSettle,
            );
          },
        ),
        const SizedBox(height: 30),
        splitsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (Object error, StackTrace stackTrace) =>
              const SizedBox.shrink(),
          data: (List<GroupSplit> splits) {
            final List<GroupSplit> settlementPayments =
                splits.where(_isSettlementPayment).toList(growable: false)
                  ..sort(
                    (GroupSplit first, GroupSplit second) =>
                        second.occurredAt.compareTo(first.occurredAt),
                  );

            if (settlementPayments.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionHeader(
                  title: 'Settlement payments',
                  subtitle:
                      'Recorded payments that reduce outstanding balances.',
                  titleKey: const Key('settlement_payments_heading'),
                ),
                const SizedBox(height: 14),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      for (
                        int index = 0;
                        index < settlementPayments.length;
                        index++
                      ) ...<Widget>[
                        _SettlementPaymentCard(
                          split: settlementPayments[index],
                          group: group,
                          onDelete: () {
                            onDeleteExpense(settlementPayments[index]);
                          },
                        ),
                        if (index < settlementPayments.length - 1)
                          const Divider(height: 1, indent: 72),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
        _SectionHeader(
          title: 'Members',
          subtitle: 'People participating in this shared expense group.',
          action: FilledButton.tonalIcon(
            key: const Key('add_group_member_button'),
            onPressed: onAddMember,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add member'),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              for (
                int index = 0;
                index < activeMembers.length;
                index++
              ) ...<Widget>[
                _MemberTile(
                  member: activeMembers[index],
                  onRemove: activeMembers[index].isCurrentUser
                      ? null
                      : () {
                          onRemoveMember(activeMembers[index]);
                        },
                ),
                if (index < activeMembers.length - 1)
                  const Divider(height: 1, indent: 76),
              ],
            ],
          ),
        ),
        const SizedBox(height: 30),
        const _SectionHeader(
          title: 'Group actions',
          subtitle: 'Export records or manage this group.',
        ),
        const SizedBox(height: 14),
        _GroupActionsCard(
          group: group,
          onArchive: onArchive,
          onDelete: onDelete,
        ),
      ],
    );
  }
}

class _GroupOverviewCard extends StatelessWidget {
  const _GroupOverviewCard({
    required this.group,
    required this.activeMemberCount,
  });

  final Group group;
  final int activeMemberCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String initial = group.name.trim().isEmpty
        ? '?'
        : group.name.trim().substring(0, 1).toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 760;

            final Widget identity = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        group.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (group.description != null &&
                          group.description!.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          group.description!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );

            final Widget metrics = Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _OverviewMetric(
                  icon: Icons.people_outline,
                  label: 'Members',
                  value: '$activeMemberCount',
                ),
                _OverviewMetric(
                  icon: Icons.payments_outlined,
                  label: 'Currency',
                  value: group.defaultCurrencyCode,
                ),
                _OverviewMetric(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created',
                  value: _formatDate(group.createdAt),
                ),
              ],
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: identity),
                  const SizedBox(width: 28),
                  metrics,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[identity, const SizedBox(height: 22), metrics],
            );
          },
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 19, color: colors.onSurfaceVariant),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.titleKey,
    this.action,
  });

  final String title;
  final String subtitle;
  final Key? titleKey;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                key: titleKey,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...<Widget>[const SizedBox(width: 16), action!],
      ],
    );
  }
}

class _SectionLoadingCard extends StatelessWidget {
  const _SectionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SectionErrorCard extends StatelessWidget {
  const _SectionErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: colors.primary, size: 28),
        ),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _GroupActionsCard extends StatelessWidget {
  const _GroupActionsCard({
    required this.group,
    required this.onArchive,
    required this.onDelete,
  });

  final Group group;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            GroupPdfExportButton(group: group),
            OutlinedButton.icon(
              onPressed: onArchive,
              icon: const Icon(Icons.archive_outlined),
              label: const Text('Archive group'),
            ),
            OutlinedButton.icon(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error.withValues(alpha: 0.45)),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete group'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupFinanceSummary extends StatelessWidget {
  const _GroupFinanceSummary({
    required this.group,
    required this.splits,
    required this.onSettle,
  });

  final Group group;
  final List<GroupSplit> splits;
  final ValueChanged<DebtSettlement> onSettle;

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

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _BalancesCard(group: group, balances: balances),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SettlementsCard(
                    group: group,
                    settlements: settlements,
                    onSettle: onSettle,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _BalancesCard(group: group, balances: balances),
              const SizedBox(height: 14),
              _SettlementsCard(
                group: group,
                settlements: settlements,
                onSettle: onSettle,
              ),
            ],
          );
        },
      );
    } on Object catch (error) {
      return _SectionErrorCard(message: 'Unable to calculate balances: $error');
    }
  }
}

class _BalancesCard extends StatelessWidget {
  const _BalancesCard({required this.group, required this.balances});

  final Group group;
  final List<MemberBalance> balances;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      key: const Key('group_balances_card'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: colors.primary,
              ),
            ),
            title: const Text(
              'Net balances',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Positive means the member should receive money.',
            ),
          ),
          const Divider(height: 1),
          for (int index = 0; index < balances.length; index++) ...<Widget>[
            _BalanceTile(group: group, balance: balances[index]),
            if (index < balances.length - 1)
              const Divider(height: 1, indent: 20, endIndent: 20),
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String status;
    final Color statusColor;
    final IconData statusIcon;

    if (balance.balanceMinor > 0) {
      status = isCurrentUser ? 'You are owed' : 'Is owed';
      statusColor = AppColors.positive;
      statusIcon = Icons.south_west_rounded;
    } else if (balance.balanceMinor < 0) {
      status = isCurrentUser ? 'You owe' : 'Owes';
      statusColor = AppColors.danger;
      statusIcon = Icons.north_east_rounded;
    } else {
      status = 'Settled';
      statusColor = colors.onSurfaceVariant;
      statusIcon = Icons.check_rounded;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(statusIcon, size: 19, color: statusColor),
      ),
      title: Text(
        isCurrentUser ? '$name (You)' : name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(status, style: TextStyle(color: statusColor)),
      trailing: balance.balanceMinor == 0
          ? Icon(Icons.check_circle_outline, color: AppColors.positive)
          : Text(
              '${group.defaultCurrencyCode} '
              '${_formatMinorAmount(amount, group.defaultCurrencyScale)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _SettlementsCard extends StatelessWidget {
  const _SettlementsCard({
    required this.group,
    required this.settlements,
    required this.onSettle,
  });

  final Group group;
  final List<DebtSettlement> settlements;
  final ValueChanged<DebtSettlement> onSettle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      key: const Key('group_settlement_suggestions_card'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.swap_horiz, color: colors.primary),
            ),
            title: const Text(
              'Settlement suggestions',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Record a payment when one member settles another balance.',
            ),
          ),
          const Divider(height: 1),
          if (settlements.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: _InlineEmptyState(
                icon: Icons.check_circle_outline,
                title: 'Everyone is settled',
                message: 'There are no outstanding payments in this group.',
              ),
            )
          else
            for (
              int index = 0;
              index < settlements.length;
              index++
            ) ...<Widget>[
              _SettlementTile(
                group: group,
                settlement: settlements[index],
                onSettle: () {
                  onSettle(settlements[index]);
                },
              ),
              if (index < settlements.length - 1)
                const Divider(height: 1, indent: 20, endIndent: 20),
            ],
        ],
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  const _SettlementTile({
    required this.group,
    required this.settlement,
    required this.onSettle,
  });

  final Group group;
  final DebtSettlement settlement;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    final GroupMember? fromMember = _findMember(group, settlement.fromMemberId);
    final GroupMember? toMember = _findMember(group, settlement.toMemberId);
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String fromName = fromMember?.isCurrentUser ?? false
        ? 'You'
        : fromMember?.displayName ?? 'Unknown';
    final String toName = toMember?.isCurrentUser ?? false
        ? 'You'
        : toMember?.displayName ?? 'Unknown';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 19,
          color: colors.primary,
        ),
      ),
      title: Text(
        '$fromName → $toName',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Pay ${group.defaultCurrencyCode} '
        '${_formatMinorAmount(settlement.amountMinor, group.defaultCurrencyScale)}',
      ),
      trailing: FilledButton.tonal(
        key: ValueKey<String>(
          'settle_${settlement.fromMemberId}_${settlement.toMemberId}',
        ),
        onPressed: onSettle,
        child: const Text('Settle'),
      ),
    );
  }
}

class _SettlementPaymentCard extends StatelessWidget {
  const _SettlementPaymentCard({
    required this.split,
    required this.group,
    required this.onDelete,
  });

  final GroupSplit split;
  final Group group;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final GroupMember? payer = _findMember(group, split.paidByMemberId);
    final String receiverId = split.shares.isEmpty
        ? ''
        : split.shares.first.memberId;
    final GroupMember? receiver = _findMember(group, receiverId);

    final String payerName = payer?.isCurrentUser ?? false
        ? 'You'
        : payer?.displayName ?? 'Unknown';
    final String receiverName = receiver?.isCurrentUser ?? false
        ? 'You'
        : receiver?.displayName ?? 'Unknown';

    return ListTile(
      key: ValueKey<String>('settlement_payment_${split.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.positive.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.payments_outlined,
          color: AppColors.positive,
          size: 20,
        ),
      ),
      title: Text(
        '$payerName → $receiverName',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Settlement payment • ${_formatDate(split.occurredAt)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${split.currencyCode} '
            '${_formatMinorAmount(split.totalAmountMinor, split.currencyScale)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.positive,
              fontWeight: FontWeight.w700,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Payment actions',
            onSelected: (String value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) {
              return const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_outline),
                      SizedBox(width: 10),
                      Text('Delete payment'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String payerName = payer?.isCurrentUser ?? false
        ? '${payer?.displayName ?? 'You'} (You)'
        : payer?.displayName ?? 'Unknown';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          Icons.receipt_long_outlined,
          size: 20,
          color: colors.primary,
        ),
      ),
      title: Text(
        split.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          'Paid by $payerName • ${split.shares.length} '
          '${split.shares.length == 1 ? 'member' : 'members'} • '
          '${_formatDate(split.occurredAt)}',
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${split.currencyCode} '
            '${_formatMinorAmount(split.totalAmountMinor, split.currencyScale)}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          PopupMenuButton<String>(
            tooltip: 'Expense actions',
            onSelected: (String value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) {
              return const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_outline),
                      SizedBox(width: 10),
                      Text('Delete expense'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onRemove});

  final GroupMember member;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final String initial = member.displayName.trim().isEmpty
        ? '?'
        : member.displayName.trim().substring(0, 1).toUpperCase();
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      leading: CircleAvatar(
        backgroundColor: Color(member.avatarColorValue),
        child: Text(
          initial,
          style: TextStyle(
            color: _foregroundColor(member.avatarColorValue),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        member.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: member.email == null || member.email!.trim().isEmpty
          ? Text(
              member.isCurrentUser ? 'Current user' : 'Group member',
              style: TextStyle(color: colors.onSurfaceVariant),
            )
          : Text(member.email!),
      trailing: member.isCurrentUser
          ? const Chip(label: Text('You'))
          : IconButton(
              key: ValueKey<String>('remove_group_member_${member.id}'),
              tooltip: 'Remove member',
              onPressed: onRemove,
              icon: Icon(Icons.person_remove_outlined, color: colors.error),
            ),
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
          children: <Widget>[
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

bool _isSettlementPayment(GroupSplit split) {
  return split.title.startsWith(_settlementTitlePrefix);
}

String _formatDate(DateTime date) {
  final DateTime local = date.toLocal();

  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year}';
}

String _formatMinorAmount(int amountMinor, int scale) {
  final int absoluteAmount = amountMinor.abs();

  int divisor = 1;

  for (int index = 0; index < scale; index++) {
    divisor *= 10;
  }

  final int whole = absoluteAmount ~/ divisor;

  final String wholeFormatted = _addThousandsSeparators(whole.toString());

  if (scale == 0) {
    return '${amountMinor < 0 ? '-' : ''}'
        '$wholeFormatted';
  }

  final int fraction = absoluteAmount % divisor;

  return '${amountMinor < 0 ? '-' : ''}'
      '$wholeFormatted.'
      '${fraction.toString().padLeft(scale, '0')}';
}

String _addThousandsSeparators(String digits) {
  final StringBuffer buffer = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    buffer.write(digits[index]);

    final int remaining = digits.length - index - 1;

    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}

int? _parseMinorAmount(String input, int scale) {
  final String normalized = input.trim().replaceAll(',', '');

  if (normalized.isEmpty || normalized.startsWith('-')) {
    return null;
  }

  final List<String> parts = normalized.split('.');

  if (parts.length > 2) {
    return null;
  }

  final String wholePart = parts.first;

  if (wholePart.isEmpty || !RegExp(r'^\d+$').hasMatch(wholePart)) {
    return null;
  }

  String fractionPart = parts.length == 2 ? parts[1] : '';

  if (scale == 0) {
    if (fractionPart.isNotEmpty) {
      return null;
    }
  } else {
    if (fractionPart.length > scale) {
      return null;
    }

    if (fractionPart.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fractionPart)) {
      return null;
    }

    fractionPart = fractionPart.padRight(scale, '0');
  }

  int multiplier = 1;

  for (int index = 0; index < scale; index++) {
    multiplier *= 10;
  }

  final int whole = int.parse(wholePart);

  final int fraction = fractionPart.isEmpty ? 0 : int.parse(fractionPart);

  return whole * multiplier + fraction;
}

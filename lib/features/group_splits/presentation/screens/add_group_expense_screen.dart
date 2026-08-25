import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/group_split.dart';
import '../../domain/services/equal_split_calculator.dart';
import '../providers/group_split_controller.dart';

class AddGroupExpenseScreen extends ConsumerStatefulWidget {
  const AddGroupExpenseScreen({required this.group, super.key});

  final Group group;

  @override
  ConsumerState<AddGroupExpenseScreen> createState() =>
      _AddGroupExpenseScreenState();
}

class _AddGroupExpenseScreenState extends ConsumerState<AddGroupExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  late String _paidByMemberId;
  late Set<String> _selectedMemberIds;

  DateTime _occurredAt = DateTime.now();

  bool _isSaving = false;

  static const EqualSplitCalculator _equalSplitCalculator =
      EqualSplitCalculator();

  List<GroupMember> get _activeMembers => widget.group.activeMembers;

  @override
  void initState() {
    super.initState();

    final List<GroupMember> members = _activeMembers;

    if (members.isNotEmpty) {
      final GroupMember? currentUser = widget.group.currentUser;

      _paidByMemberId = currentUser?.id ?? members.first.id;

      // Standard equal-split behaviour:
      // every member participates initially, including the payer.
      _selectedMemberIds = members
          .map((GroupMember member) => member.id)
          .toSet();
    } else {
      _paidByMemberId = '';
      _selectedMemberIds = <String>{};
    }

    _amountController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _amountController.removeListener(_refreshPreview);

    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      key: const Key('add_group_expense_screen'),
      appBar: AppBar(title: const Text('Add group expense')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            key: const Key('add_group_expense_list'),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: <Widget>[
              Text(
                widget.group.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Record who paid and exactly who should share the expense.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ----------------------------------------------------------
              // TITLE
              // ----------------------------------------------------------
              TextFormField(
                key: const Key('group_expense_title_field'),
                controller: _titleController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Expense title',
                  hintText: 'e.g. Dinner',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final String title = value?.trim() ?? '';

                  if (title.isEmpty) {
                    return 'Enter an expense title.';
                  }

                  if (title.length > 100) {
                    return 'Title must be 100 characters or less.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ----------------------------------------------------------
              // AMOUNT
              // ----------------------------------------------------------
              TextFormField(
                key: const Key('group_expense_amount_field'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Total amount',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  suffixText: widget.group.defaultCurrencyCode,
                  border: const OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final int? amountMinor = _parseAmountMinor(
                    value ?? '',
                    widget.group.defaultCurrencyScale,
                  );

                  if (amountMinor == null) {
                    return 'Enter a valid amount.';
                  }

                  if (amountMinor <= 0) {
                    return 'Amount must be greater than zero.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ----------------------------------------------------------
              // PAYER
              // ----------------------------------------------------------
              DropdownButtonFormField<String>(
                key: const Key('group_expense_payer_dropdown'),
                initialValue: _paidByMemberId.isEmpty ? null : _paidByMemberId,
                decoration: const InputDecoration(
                  labelText: 'Paid by',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _activeMembers
                    .map(
                      (GroupMember member) => DropdownMenuItem<String>(
                        value: member.id,
                        child: Text(
                          member.isCurrentUser
                              ? '${member.displayName} (You)'
                              : member.displayName,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSaving
                    ? null
                    : (String? value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _paidByMemberId = value;
                        });
                      },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Select who paid.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 10),

              _PayerExplanationCard(
                payer: _findActiveMember(_paidByMemberId),
                payerSelected: _selectedMemberIds.contains(_paidByMemberId),
              ),

              const SizedBox(height: 24),

              // ----------------------------------------------------------
              // PARTICIPANTS
              // ----------------------------------------------------------
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Split between',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isSaving ? null : _toggleAllMembers,
                    child: Text(
                      _selectedMemberIds.length == _activeMembers.length
                          ? 'Clear all'
                          : 'Select all',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                'Only checked members will owe a share of this expense.',
                style: theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 10),

              if (_activeMembers.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'This group has no active members.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      for (
                        int index = 0;
                        index < _activeMembers.length;
                        index++
                      ) ...<Widget>[
                        _ParticipantTile(
                          key: ValueKey<String>(
                            'participant_${_activeMembers[index].id}',
                          ),
                          member: _activeMembers[index],
                          selected: _selectedMemberIds.contains(
                            _activeMembers[index].id,
                          ),
                          enabled: !_isSaving,
                          isPayer: _activeMembers[index].id == _paidByMemberId,
                          onChanged: (bool selected) {
                            _setMemberSelected(
                              _activeMembers[index].id,
                              selected,
                            );
                          },
                        ),
                        if (index < _activeMembers.length - 1)
                          const Divider(height: 1, indent: 72),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              Text(
                '${_selectedMemberIds.length} '
                '${_selectedMemberIds.length == 1 ? 'member' : 'members'} '
                'selected',
                style: theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 24),

              // ----------------------------------------------------------
              // LIVE SPLIT PREVIEW
              // ----------------------------------------------------------
              Text(
                'Split preview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              _buildSplitPreview(context),

              const SizedBox(height: 24),

              // ----------------------------------------------------------
              // NOTES
              // ----------------------------------------------------------
              TextFormField(
                key: const Key('group_expense_notes_field'),
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                key: const Key('group_expense_date_button'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Expense date'),
                subtitle: Text(_formatDate(_occurredAt)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isSaving ? null : _selectDate,
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                key: const Key('save_group_expense_button'),
                onPressed: _isSaving ? null : _saveExpense,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Saving...' : 'Save expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitPreview(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final int? totalAmountMinor = _parseAmountMinor(
      _amountController.text,
      widget.group.defaultCurrencyScale,
    );

    if (totalAmountMinor == null || totalAmountMinor <= 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Enter an amount to preview the split.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_selectedMemberIds.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Select at least one member.',
            style: TextStyle(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final List<String> participantIds = _orderedSelectedMemberIds();

    final List<GroupSplitShare> shares;

    try {
      shares = _equalSplitCalculator.calculate(
        totalAmountMinor: totalAmountMinor,
        memberIds: participantIds,
      );
    } on FormatException catch (error) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(error.message, textAlign: TextAlign.center),
        ),
      );
    }

    final Map<String, int> amountByMemberId = <String, int>{
      for (final GroupSplitShare share in shares)
        share.memberId: share.owedAmountMinor,
    };

    return Card(
      key: const Key('group_expense_split_preview'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (
            int index = 0;
            index < participantIds.length;
            index++
          ) ...<Widget>[
            _SplitPreviewTile(
              member: _memberById(participantIds[index]),
              amountMinor: amountByMemberId[participantIds[index]]!,
              currencyCode: widget.group.defaultCurrencyCode,
              currencyScale: widget.group.defaultCurrencyScale,
              isPayer: participantIds[index] == _paidByMemberId,
            ),
            if (index < participantIds.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
          const Divider(height: 1),
          ListTile(
            title: const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '${widget.group.defaultCurrencyCode} '
              '${_formatMinorAmount(totalAmountMinor, widget.group.defaultCurrencyScale)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshPreview() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _toggleAllMembers() {
    setState(() {
      if (_selectedMemberIds.length == _activeMembers.length) {
        _selectedMemberIds.clear();
      } else {
        _selectedMemberIds = _activeMembers
            .map((GroupMember member) => member.id)
            .toSet();
      }
    });
  }

  void _setMemberSelected(String memberId, bool selected) {
    setState(() {
      if (selected) {
        _selectedMemberIds.add(memberId);
      } else {
        _selectedMemberIds.remove(memberId);
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _occurredAt = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _occurredAt.hour,
        _occurredAt.minute,
      );
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      _showMessage('Select at least one member to split the expense.');
      return;
    }

    final int? totalAmountMinor = _parseAmountMinor(
      _amountController.text,
      widget.group.defaultCurrencyScale,
    );

    if (totalAmountMinor == null || totalAmountMinor <= 0) {
      _showMessage('Enter a valid expense amount.');
      return;
    }

    final List<String> participantIds = _orderedSelectedMemberIds();

    final List<GroupSplitShare> shares;

    try {
      shares = _equalSplitCalculator.calculate(
        totalAmountMinor: totalAmountMinor,
        memberIds: participantIds,
      );
    } on FormatException catch (error) {
      _showMessage(error.message);
      return;
    }

    final int verificationTotal = shares.fold<int>(
      0,
      (int total, GroupSplitShare share) => total + share.owedAmountMinor,
    );

    if (verificationTotal != totalAmountMinor) {
      _showMessage(
        'Split verification failed. The shares do not equal the total.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final DateTime now = DateTime.now().toUtc();

    final GroupSplit split = GroupSplit(
      id: _newSplitId(),
      groupId: widget.group.id,
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      totalAmountMinor: totalAmountMinor,
      currencyCode: widget.group.defaultCurrencyCode,
      currencyScale: widget.group.defaultCurrencyScale,
      paidByMemberId: _paidByMemberId,
      occurredAt: _occurredAt.toUtc(),
      splitMethod: GroupSplitMethod.equal,
      shares: shares,
      createdAt: now,
      updatedAt: now,
    );

    final bool success = await ref
        .read(groupSplitControllerProvider.notifier)
        .createSplit(split);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (!success) {
      final AsyncValue<void> state = ref.read(groupSplitControllerProvider);

      final String message = state.when(
        data: (_) => 'Unable to save the group expense.',
        loading: () => 'The expense is still being saved.',
        error: (Object error, StackTrace stackTrace) => error.toString(),
      );

      _showMessage(message);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group expense added successfully.')),
    );

    Navigator.of(context).pop();
  }

  List<String> _orderedSelectedMemberIds() {
    return _activeMembers
        .where((GroupMember member) => _selectedMemberIds.contains(member.id))
        .map((GroupMember member) => member.id)
        .toList(growable: false);
  }

  GroupMember? _findActiveMember(String memberId) {
    for (final GroupMember member in _activeMembers) {
      if (member.id == memberId) {
        return member;
      }
    }

    return null;
  }

  GroupMember _memberById(String memberId) {
    for (final GroupMember member in _activeMembers) {
      if (member.id == memberId) {
        return member;
      }
    }

    throw StateError('Unknown group member: $memberId');
  }

  int? _parseAmountMinor(String input, int scale) {
    final String normalized = input.trim().replaceAll(',', '');

    if (normalized.isEmpty) {
      return null;
    }

    if (normalized.startsWith('-')) {
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

    if (fractionPart.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fractionPart)) {
      return null;
    }

    if (fractionPart.length > scale) {
      return null;
    }

    fractionPart = fractionPart.padRight(scale, '0');

    int multiplier = 1;

    for (int index = 0; index < scale; index++) {
      multiplier *= 10;
    }

    final int whole = int.parse(wholePart);

    final int fraction = fractionPart.isEmpty ? 0 : int.parse(fractionPart);

    return whole * multiplier + fraction;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _newSplitId() {
    return '${widget.group.id}-split-'
        '${DateTime.now().microsecondsSinceEpoch}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _PayerExplanationCard extends StatelessWidget {
  const _PayerExplanationCard({
    required this.payer,
    required this.payerSelected,
  });

  final GroupMember? payer;
  final bool payerSelected;

  @override
  Widget build(BuildContext context) {
    if (payer == null) {
      return const SizedBox.shrink();
    }

    final String name = payer!.isCurrentUser ? 'You' : payer!.displayName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                payerSelected
                    ? '$name paid the bill and is also included '
                          'in the split.'
                    : '$name paid the bill but is not included '
                          'in the split, so the selected members '
                          'will repay the full amount.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.member,
    required this.selected,
    required this.enabled,
    required this.isPayer,
    required this.onChanged,
    super.key,
  });

  final GroupMember member;
  final bool selected;
  final bool enabled;
  final bool isPayer;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final String initial = member.displayName.trim().isEmpty
        ? '?'
        : member.displayName.trim().substring(0, 1).toUpperCase();

    return CheckboxListTile(
      value: selected,
      onChanged: enabled
          ? (bool? value) {
              onChanged(value ?? false);
            }
          : null,
      secondary: CircleAvatar(
        backgroundColor: Color(member.avatarColorValue),
        child: Text(
          initial,
          style: TextStyle(
            color: _foregroundColor(member.avatarColorValue),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        member.isCurrentUser
            ? '${member.displayName} (You)'
            : member.displayName,
      ),
      subtitle: Text(
        isPayer
            ? selected
                  ? 'Paid • included in split'
                  : 'Paid • not included in split'
            : selected
            ? 'Included in split'
            : 'Not included',
      ),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Color _foregroundColor(int colorValue) {
    final Color color = Color(colorValue);

    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

class _SplitPreviewTile extends StatelessWidget {
  const _SplitPreviewTile({
    required this.member,
    required this.amountMinor,
    required this.currencyCode,
    required this.currencyScale,
    required this.isPayer,
  });

  final GroupMember member;
  final int amountMinor;
  final String currencyCode;
  final int currencyScale;
  final bool isPayer;

  @override
  Widget build(BuildContext context) {
    final String name = member.isCurrentUser
        ? '${member.displayName} (You)'
        : member.displayName;

    return ListTile(
      title: Text(name),
      subtitle: isPayer
          ? const Text('Payer • own share')
          : const Text('Owes this share'),
      trailing: Text(
        '$currencyCode '
        '${_formatMinorAmount(amountMinor, currencyScale)}',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

String _formatMinorAmount(int amountMinor, int scale) {
  int divisor = 1;

  for (int index = 0; index < scale; index++) {
    divisor *= 10;
  }

  final int whole = amountMinor ~/ divisor;

  if (scale == 0) {
    return whole.toString();
  }

  final int fraction = amountMinor % divisor;

  return '$whole.'
      '${fraction.toString().padLeft(scale, '0')}';
}

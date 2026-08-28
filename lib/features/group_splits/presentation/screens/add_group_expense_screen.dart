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

      _selectedMemberIds = members
          .map((GroupMember member) => member.id)
          .toSet();
    } else {
      _paidByMemberId = '';
      _selectedMemberIds = <String>{};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      key: const Key('add_group_expense_screen'),
      appBar: AppBar(title: const Text('Add group expense')),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            key: const Key('add_group_expense_list'),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: <Widget>[
              Text(
                widget.group.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Record a shared expense and split it equally '
                'between selected members.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
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
              TextFormField(
                key: const Key('group_expense_amount_field'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  suffixText: widget.group.defaultCurrencyCode,
                  border: const OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final double? amount = double.tryParse(value?.trim() ?? '');

                  if (amount == null) {
                    return 'Enter a valid amount.';
                  }

                  if (amount <= 0) {
                    return 'Amount must be greater than zero.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
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
              const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
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
          ),
        ),
      ),
    );
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

    final List<String> participantIds = _activeMembers
        .where((GroupMember member) => _selectedMemberIds.contains(member.id))
        .map((GroupMember member) => member.id)
        .toList(growable: false);

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

  int? _parseAmountMinor(String input, int scale) {
    final double? amount = double.tryParse(input.trim());

    if (amount == null) {
      return null;
    }

    int multiplier = 1;

    for (int index = 0; index < scale; index++) {
      multiplier *= 10;
    }

    return (amount * multiplier).round();
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

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.member,
    required this.selected,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final GroupMember member;
  final bool selected;
  final bool enabled;
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
      subtitle: member.email == null || member.email!.trim().isEmpty
          ? null
          : Text(member.email!),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Color _foregroundColor(int colorValue) {
    final Color color = Color(colorValue);

    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

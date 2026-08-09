import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group.dart';
import '../../domain/entities/group_member.dart';
import '../providers/group_controller.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _currencyCode = 'PKR';

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> controllerState = ref.watch(groupControllerProvider);

    final bool controllerLoading = controllerState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create group')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Group details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a group for shared expenses and settlements.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  hintText: 'e.g. Karachi Trip',
                  prefixIcon: Icon(Icons.groups_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final String name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Enter a group name';
                  }

                  if (name.length > 100) {
                    return 'Group name is too long';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.done,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _currencyCode,
                decoration: const InputDecoration(
                  labelText: 'Default currency',
                  prefixIcon: Icon(Icons.currency_exchange),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'PKR',
                    child: Text('PKR — Pakistani Rupee'),
                  ),
                  DropdownMenuItem(
                    value: 'USD',
                    child: Text('USD — US Dollar'),
                  ),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR — Euro')),
                  DropdownMenuItem(
                    value: 'GBP',
                    child: Text('GBP — British Pound'),
                  ),
                  DropdownMenuItem(
                    value: 'AED',
                    child: Text('AED — UAE Dirham'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _currencyCode = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: (_isSaving || controllerLoading)
                    ? null
                    : _createGroup,
                icon: (_isSaving || controllerLoading)
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  (_isSaving || controllerLoading)
                      ? 'Creating...'
                      : 'Create group',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    final DateTime now = DateTime.now().toUtc();

    const String currentUserId = 'current-user';

    final GroupMember currentUser = GroupMember(
      id: currentUserId,
      displayName: 'You',
      joinedAt: now,
      isCurrentUser: true,
      isActive: true,
    );

    final Group group = Group(
      id: _createLocalId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      ownerMemberId: currentUserId,
      defaultCurrencyCode: _currencyCode,
      defaultCurrencyScale: 2,
      members: <GroupMember>[currentUser],
      createdAt: now,
      updatedAt: now,
    );

    final bool success = await ref
        .read(groupControllerProvider.notifier)
        .createGroup(group);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully')),
      );

      Navigator.of(context).pop();
      return;
    }

    final AsyncValue<void> state = ref.read(groupControllerProvider);

    final String message = state.when(
      data: (_) => 'Unable to create group.',
      loading: () => 'Creating group...',
      error: (Object error, StackTrace stackTrace) {
        return error.toString().replaceFirst('Bad state: ', '');
      },
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _createLocalId() {
    return '${DateTime.now().microsecondsSinceEpoch}-group';
  }
}

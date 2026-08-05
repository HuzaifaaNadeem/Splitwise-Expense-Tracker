import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/utils/money_utils.dart';
import '../../domain/entities/expense.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_category_option.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({this.expense, super.key});

  final Expense? expense;

  bool get isEditing => expense != null;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late String _categoryId;
  late String _currencyCode;
  late int _currencyScale;
  late DateTime _occurredAtLocal;

  bool _isSaving = false;

  static const Map<String, int> _currencies = <String, int>{
    'PKR': 2,
    'USD': 2,
    'EUR': 2,
    'GBP': 2,
    'AED': 2,
    'SAR': 2,
  };

  @override
  void initState() {
    super.initState();

    final Expense? expense = widget.expense;

    _titleController = TextEditingController(text: expense?.title ?? '');

    _amountController = TextEditingController(
      text: expense == null ? '' : _editableAmount(expense),
    );

    _notesController = TextEditingController(text: expense?.notes ?? '');

    _categoryId = expense?.categoryId ?? 'food';
    _currencyCode = expense?.currencyCode ?? 'PKR';
    _currencyScale = expense?.currencyScale ?? 2;

    _occurredAtLocal = expense?.occurredAt.toLocal() ?? DateTime.now();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Lunch',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an expense title.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  prefixText: '$_currencyCode ',
                ),
                validator: (String? value) {
                  final int? amount = MoneyUtils.parseToMinorUnits(
                    value ?? '',
                    scale: _currencyScale,
                  );

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _currencyCode,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                items: _currencies.keys
                    .map(
                      (String currency) => DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _currencyCode = value;
                    _currencyScale = _currencies[value] ?? 2;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: defaultExpenseCategories
                    .map((ExpenseCategoryOption category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Row(
                          children: <Widget>[
                            Icon(category.icon, size: 20),
                            const SizedBox(width: 12),
                            Text(category.label),
                          ],
                        ),
                      );
                    })
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _categoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(_occurredAtLocal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(
                        MaterialLocalizations.of(context).formatTimeOfDay(
                          TimeOfDay.fromDateTime(_occurredAtLocal),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveExpense,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(widget.isEditing ? 'Save Changes' : 'Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _occurredAtLocal,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _occurredAtLocal = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _occurredAtLocal.hour,
        _occurredAtLocal.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAtLocal),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _occurredAtLocal = DateTime(
        _occurredAtLocal.year,
        _occurredAtLocal.month,
        _occurredAtLocal.day,
        selected.hour,
        selected.minute,
      );
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_occurredAtLocal.isAfter(DateTime.now())) {
      _showError('Expense date and time cannot be in the future.');
      return;
    }

    final int? amountMinor = MoneyUtils.parseToMinorUnits(
      _amountController.text,
      scale: _currencyScale,
    );

    if (amountMinor == null) {
      _showError('Enter a valid amount.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final Result<Expense> result;

    if (widget.expense == null) {
      result = await ref
          .read(expenseControllerProvider.notifier)
          .createExpense(
            title: _titleController.text,
            amountMinor: amountMinor,
            currencyCode: _currencyCode,
            currencyScale: _currencyScale,
            categoryId: _categoryId,
            occurredAt: _occurredAtLocal,
            notes: _notesController.text,
          );
    } else {
      result = await ref
          .read(expenseControllerProvider.notifier)
          .updateExpense(
            existing: widget.expense!,
            title: _titleController.text,
            amountMinor: amountMinor,
            currencyCode: _currencyCode,
            currencyScale: _currencyScale,
            categoryId: _categoryId,
            occurredAt: _occurredAtLocal,
            notes: _notesController.text,
          );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    result.fold(
      onSuccess: (Expense expense) {
        Navigator.of(context).pop(true);
      },
      onFailure: (failure) {
        _showError(failure.message);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _editableAmount(Expense expense) {
    final int divisor = _powerOfTen(expense.currencyScale);

    final int whole = expense.amountMinor ~/ divisor;

    if (expense.currencyScale == 0) {
      return whole.toString();
    }

    final int fraction = expense.amountMinor % divisor;

    return '$whole.'
        '${fraction.toString().padLeft(expense.currencyScale, '0')}';
  }

  int _powerOfTen(int exponent) {
    int result = 1;

    for (int index = 0; index < exponent; index++) {
      result *= 10;
    }

    return result;
  }
}

import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/feature_empty_state.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No expenses yet',
      description:
          'Your personal expenses, categories, search, and filters will '
          'appear here.',
    );
  }
}

import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/feature_empty_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureEmptyState(
      icon: Icons.donut_large_outlined,
      title: 'Analytics will appear here',
      description:
          'Category spending, budgets, income, and expense comparisons '
          'will be visualized after transactions are available.',
    );
  }
}

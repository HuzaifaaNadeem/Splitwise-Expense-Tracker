import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/feature_empty_state.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureEmptyState(
      icon: Icons.groups_outlined,
      title: 'No groups yet',
      description:
          'Create groups for trips, roommates, friends, and shared bills.',
    );
  }
}

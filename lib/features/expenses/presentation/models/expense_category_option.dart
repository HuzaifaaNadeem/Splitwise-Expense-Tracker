import 'package:flutter/material.dart';

final class ExpenseCategoryOption {
  const ExpenseCategoryOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

const List<ExpenseCategoryOption> defaultExpenseCategories =
    <ExpenseCategoryOption>[
      ExpenseCategoryOption(
        id: 'food',
        label: 'Food',
        icon: Icons.restaurant_outlined,
      ),
      ExpenseCategoryOption(
        id: 'travel',
        label: 'Travel',
        icon: Icons.directions_car_outlined,
      ),
      ExpenseCategoryOption(
        id: 'bills',
        label: 'Bills',
        icon: Icons.receipt_outlined,
      ),
      ExpenseCategoryOption(
        id: 'entertainment',
        label: 'Entertainment',
        icon: Icons.movie_outlined,
      ),
      ExpenseCategoryOption(
        id: 'health',
        label: 'Health',
        icon: Icons.medical_services_outlined,
      ),
    ];

ExpenseCategoryOption expenseCategoryById(String id) {
  for (final ExpenseCategoryOption category in defaultExpenseCategories) {
    if (category.id == id) {
      return category;
    }
  }

  return const ExpenseCategoryOption(
    id: 'other',
    label: 'Other',
    icon: Icons.category_outlined,
  );
}

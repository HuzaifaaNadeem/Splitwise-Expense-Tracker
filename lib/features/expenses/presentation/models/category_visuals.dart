import 'package:flutter/material.dart';

final class CategoryIconChoice {
  const CategoryIconChoice({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const List<CategoryIconChoice> categoryIconChoices = <CategoryIconChoice>[
  CategoryIconChoice(label: 'Food', icon: Icons.restaurant_outlined),
  CategoryIconChoice(label: 'Travel', icon: Icons.directions_car_outlined),
  CategoryIconChoice(label: 'Bills', icon: Icons.receipt_outlined),
  CategoryIconChoice(label: 'Entertainment', icon: Icons.movie_outlined),
  CategoryIconChoice(label: 'Health', icon: Icons.medical_services_outlined),
  CategoryIconChoice(label: 'Shopping', icon: Icons.shopping_bag_outlined),
  CategoryIconChoice(label: 'Education', icon: Icons.school_outlined),
  CategoryIconChoice(label: 'Other', icon: Icons.category_outlined),
];

const List<int> categoryColorChoices = <int>[
  0xFFEF4444,
  0xFFF59E0B,
  0xFF10B981,
  0xFF3B82F6,
  0xFF6366F1,
  0xFF8B5CF6,
  0xFFEC4899,
  0xFF64748B,
];

IconData categoryIconFromCodePoint(int codePoint) {
  for (final CategoryIconChoice choice in categoryIconChoices) {
    if (choice.icon.codePoint == codePoint) {
      return choice.icon;
    }
  }

  return Icons.category_outlined;
}

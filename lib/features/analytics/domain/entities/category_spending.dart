import 'package:equatable/equatable.dart';

final class CategorySpending extends Equatable {
  const CategorySpending({required this.categoryId, required this.amountMinor});

  final String categoryId;
  final int amountMinor;

  @override
  List<Object> get props => <Object>[categoryId, amountMinor];
}

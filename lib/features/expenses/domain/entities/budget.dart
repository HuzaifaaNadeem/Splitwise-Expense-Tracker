import 'package:equatable/equatable.dart';

enum BudgetPeriod { weekly, monthly }

final class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.period,
    required this.amountMinor,
    required this.currencyCode,
    required this.currencyScale,
    required this.isActive,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final BudgetPeriod period;
  final int amountMinor;
  final String currencyCode;
  final int currencyScale;

  final bool isActive;
  final int revision;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Budget copyWith({
    String? id,
    BudgetPeriod? period,
    int? amountMinor,
    String? currencyCode,
    int? currencyScale,
    bool? isActive,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      period: period ?? this.period,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyScale: currencyScale ?? this.currencyScale,
      isActive: isActive ?? this.isActive,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    period,
    amountMinor,
    currencyCode,
    currencyScale,
    isActive,
    revision,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

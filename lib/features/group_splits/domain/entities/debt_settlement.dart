import 'package:equatable/equatable.dart';

final class DebtSettlement extends Equatable {
  const DebtSettlement({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountMinor,
  });

  final String fromMemberId;
  final String toMemberId;
  final int amountMinor;

  @override
  List<Object> get props => <Object>[fromMemberId, toMemberId, amountMinor];
}

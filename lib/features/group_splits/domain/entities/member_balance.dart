import 'package:equatable/equatable.dart';

final class MemberBalance extends Equatable {
  const MemberBalance({required this.memberId, required this.balanceMinor});

  final String memberId;

  /// Positive: this member should receive money.
  /// Negative: this member owes money.
  /// Zero: this member is settled.
  final int balanceMinor;

  @override
  List<Object> get props => <Object>[memberId, balanceMinor];
}

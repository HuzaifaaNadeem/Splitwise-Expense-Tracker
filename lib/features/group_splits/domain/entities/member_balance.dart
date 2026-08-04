import 'package:equatable/equatable.dart';

final class MemberBalance extends Equatable {
  const MemberBalance({required this.memberId, required this.balanceMinor});

  final String memberId;

  /// Positive = member should receive money.
  ///
  /// Negative = member owes money.
  ///
  /// Zero = already settled.
  final int balanceMinor;

  @override
  List<Object> get props => <Object>[memberId, balanceMinor];
}

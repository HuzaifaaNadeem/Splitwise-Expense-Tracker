import '../entities/group_split.dart';
import '../entities/member_balance.dart';

final class GroupBalanceCalculator {
  const GroupBalanceCalculator();

  List<MemberBalance> calculate({
    required List<String> memberIds,
    required List<GroupSplit> splits,
  }) {
    final List<String> normalizedIds = memberIds
        .map((String id) => id.trim())
        .toList(growable: false);

    if (normalizedIds.any((String id) => id.isEmpty)) {
      throw const FormatException('Member id cannot be empty.');
    }

    if (normalizedIds.toSet().length != normalizedIds.length) {
      throw const FormatException('Duplicate member ids are not allowed.');
    }

    final Map<String, int> balances = <String, int>{
      for (final String memberId in normalizedIds) memberId: 0,
    };

    for (final GroupSplit split in splits) {
      if (split.isDeleted) {
        continue;
      }

      if (!balances.containsKey(split.paidByMemberId)) {
        throw StateError('Unknown payer: ${split.paidByMemberId}');
      }

      final int sharesTotal = split.shares.fold<int>(
        0,
        (int total, GroupSplitShare share) => total + share.owedAmountMinor,
      );

      if (sharesTotal != split.totalAmountMinor) {
        throw StateError('Split shares do not equal the expense total.');
      }

      balances[split.paidByMemberId] =
          balances[split.paidByMemberId]! + split.totalAmountMinor;

      for (final GroupSplitShare share in split.shares) {
        if (!balances.containsKey(share.memberId)) {
          throw StateError('Unknown participant: ${share.memberId}');
        }

        balances[share.memberId] =
            balances[share.memberId]! - share.owedAmountMinor;
      }
    }

    final int finalTotal = balances.values.fold<int>(
      0,
      (int total, int balance) => total + balance,
    );

    if (finalTotal != 0) {
      throw StateError('Group balances must always sum to zero.');
    }

    return normalizedIds
        .map(
          (String memberId) => MemberBalance(
            memberId: memberId,
            balanceMinor: balances[memberId]!,
          ),
        )
        .toList(growable: false);
  }
}

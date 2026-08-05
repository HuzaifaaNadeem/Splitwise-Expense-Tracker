import '../entities/debt_settlement.dart';
import '../entities/member_balance.dart';

final class DebtSettlementCalculator {
  const DebtSettlementCalculator();

  List<DebtSettlement> calculate(List<MemberBalance> balances) {
    if (balances.isEmpty) {
      return const <DebtSettlement>[];
    }

    _validateBalances(balances);

    final Map<String, int> remainingBalances = <String, int>{
      for (final MemberBalance balance in balances)
        balance.memberId: balance.balanceMinor,
    };

    final List<DebtSettlement> settlements = <DebtSettlement>[];

    while (true) {
      final MapEntry<String, int>? creditor = _findLargestCreditor(
        remainingBalances,
      );

      final MapEntry<String, int>? debtor = _findLargestDebtor(
        remainingBalances,
      );

      if (creditor == null || debtor == null) {
        break;
      }

      final int transferAmount = _minimum(creditor.value, -debtor.value);

      if (transferAmount <= 0) {
        break;
      }

      settlements.add(
        DebtSettlement(
          fromMemberId: debtor.key,
          toMemberId: creditor.key,
          amountMinor: transferAmount,
        ),
      );

      remainingBalances[creditor.key] = creditor.value - transferAmount;

      remainingBalances[debtor.key] = debtor.value + transferAmount;
    }

    _verifySettlementComplete(remainingBalances);

    return List<DebtSettlement>.unmodifiable(settlements);
  }

  void _validateBalances(List<MemberBalance> balances) {
    final Set<String> memberIds = <String>{};
    int total = 0;

    for (final MemberBalance balance in balances) {
      final String memberId = balance.memberId.trim();

      if (memberId.isEmpty) {
        throw const FormatException('Member id cannot be empty.');
      }

      if (!memberIds.add(memberId)) {
        throw FormatException('Duplicate member id: $memberId');
      }

      total += balance.balanceMinor;
    }

    if (total != 0) {
      throw StateError(
        'Group balances must sum to zero. '
        'Current total: $total',
      );
    }
  }

  MapEntry<String, int>? _findLargestCreditor(Map<String, int> balances) {
    MapEntry<String, int>? result;

    for (final MapEntry<String, int> entry in balances.entries) {
      if (entry.value <= 0) {
        continue;
      }

      if (result == null || entry.value > result.value) {
        result = entry;
      }
    }

    return result;
  }

  MapEntry<String, int>? _findLargestDebtor(Map<String, int> balances) {
    MapEntry<String, int>? result;

    for (final MapEntry<String, int> entry in balances.entries) {
      if (entry.value >= 0) {
        continue;
      }

      if (result == null || entry.value < result.value) {
        result = entry;
      }
    }

    return result;
  }

  int _minimum(int first, int second) {
    return first < second ? first : second;
  }

  void _verifySettlementComplete(Map<String, int> balances) {
    for (final int balance in balances.values) {
      if (balance != 0) {
        throw StateError('Debt settlement failed to resolve all balances.');
      }
    }
  }
}

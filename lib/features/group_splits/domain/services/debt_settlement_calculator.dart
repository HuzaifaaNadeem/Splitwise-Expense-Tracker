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
      final MapEntry<String, int>? largestCreditor = _findLargestCreditor(
        remainingBalances,
      );

      final MapEntry<String, int>? largestDebtor = _findLargestDebtor(
        remainingBalances,
      );

      if (largestCreditor == null || largestDebtor == null) {
        break;
      }

      final int amountToTransfer = _minimum(
        largestCreditor.value,
        -largestDebtor.value,
      );

      if (amountToTransfer <= 0) {
        break;
      }

      settlements.add(
        DebtSettlement(
          fromMemberId: largestDebtor.key,
          toMemberId: largestCreditor.key,
          amountMinor: amountToTransfer,
        ),
      );

      remainingBalances[largestCreditor.key] =
          largestCreditor.value - amountToTransfer;

      remainingBalances[largestDebtor.key] =
          largestDebtor.value + amountToTransfer;
    }

    _verifySettlementComplete(remainingBalances);

    return List<DebtSettlement>.unmodifiable(settlements);
  }

  void _validateBalances(List<MemberBalance> balances) {
    final Set<String> memberIds = <String>{};

    int total = 0;

    for (final MemberBalance balance in balances) {
      if (balance.memberId.trim().isEmpty) {
        throw const FormatException('Member id cannot be empty.');
      }

      if (!memberIds.add(balance.memberId)) {
        throw FormatException('Duplicate member id: ${balance.memberId}');
      }

      total += balance.balanceMinor;
    }

    if (total != 0) {
      throw StateError(
        'Group balances must sum to zero. Current total: $total',
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

import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/debt_settlement.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/group_split.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/member_balance.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/services/debt_settlement_calculator.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/services/equal_split_calculator.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/services/group_balance_calculator.dart';

void main() {
  const EqualSplitCalculator equalSplitCalculator = EqualSplitCalculator();

  const GroupBalanceCalculator balanceCalculator = GroupBalanceCalculator();

  const DebtSettlementCalculator settlementCalculator =
      DebtSettlementCalculator();

  group('Group finance flow', () {
    test('PKR 3000 paid by A for 3 members produces correct balances', () {
      final List<GroupSplitShare> shares = equalSplitCalculator.calculate(
        totalAmountMinor: 300000,
        memberIds: const <String>['a', 'b', 'c'],
      );

      expect(shares, hasLength(3));
      expect(shares[0].owedAmountMinor, 100000);
      expect(shares[1].owedAmountMinor, 100000);
      expect(shares[2].owedAmountMinor, 100000);

      final DateTime date = DateTime.utc(2026, 8, 21);

      final GroupSplit split = GroupSplit(
        id: 'split-1',
        groupId: 'group-1',
        title: 'Dinner',
        totalAmountMinor: 300000,
        currencyCode: 'PKR',
        currencyScale: 2,
        paidByMemberId: 'a',
        occurredAt: date,
        splitMethod: GroupSplitMethod.equal,
        shares: shares,
        createdAt: date,
        updatedAt: date,
      );

      final List<MemberBalance> balances = balanceCalculator.calculate(
        memberIds: const <String>['a', 'b', 'c'],
        splits: <GroupSplit>[split],
      );

      final Map<String, int> balancesByMember = <String, int>{
        for (final MemberBalance balance in balances)
          balance.memberId: balance.balanceMinor,
      };

      // A paid PKR 3000 but owes only PKR 1000.
      // Therefore A should receive PKR 2000.
      expect(balancesByMember['a'], 200000);

      // B owes PKR 1000.
      expect(balancesByMember['b'], -100000);

      // C owes PKR 1000.
      expect(balancesByMember['c'], -100000);

      expect(
        balances.fold<int>(
          0,
          (int total, MemberBalance balance) => total + balance.balanceMinor,
        ),
        0,
      );
    });

    test('creates correct settlement suggestions', () {
      const List<MemberBalance> balances = <MemberBalance>[
        MemberBalance(memberId: 'a', balanceMinor: 200000),
        MemberBalance(memberId: 'b', balanceMinor: -100000),
        MemberBalance(memberId: 'c', balanceMinor: -100000),
      ];

      final List<DebtSettlement> settlements = settlementCalculator.calculate(
        balances,
      );

      expect(settlements, hasLength(2));

      expect(
        settlements.every(
          (DebtSettlement settlement) => settlement.toMemberId == 'a',
        ),
        isTrue,
      );

      expect(
        settlements
            .map((DebtSettlement settlement) => settlement.fromMemberId)
            .toSet(),
        <String>{'b', 'c'},
      );

      expect(
        settlements.every(
          (DebtSettlement settlement) => settlement.amountMinor == 100000,
        ),
        isTrue,
      );

      final int settlementTotal = settlements.fold<int>(
        0,
        (int total, DebtSettlement settlement) =>
            total + settlement.amountMinor,
      );

      expect(settlementTotal, 200000);
    });

    test('multiple expenses produce correct final settlement', () {
      final DateTime date = DateTime.utc(2026, 8, 21);

      final GroupSplit firstSplit = GroupSplit(
        id: 'split-1',
        groupId: 'group-1',
        title: 'Dinner',
        totalAmountMinor: 90000,
        currencyCode: 'PKR',
        currencyScale: 2,
        paidByMemberId: 'a',
        occurredAt: date,
        splitMethod: GroupSplitMethod.equal,
        shares: const <GroupSplitShare>[
          GroupSplitShare(memberId: 'a', owedAmountMinor: 30000),
          GroupSplitShare(memberId: 'b', owedAmountMinor: 30000),
          GroupSplitShare(memberId: 'c', owedAmountMinor: 30000),
        ],
        createdAt: date,
        updatedAt: date,
      );

      final GroupSplit secondSplit = GroupSplit(
        id: 'split-2',
        groupId: 'group-1',
        title: 'Taxi',
        totalAmountMinor: 60000,
        currencyCode: 'PKR',
        currencyScale: 2,
        paidByMemberId: 'b',
        occurredAt: date,
        splitMethod: GroupSplitMethod.equal,
        shares: const <GroupSplitShare>[
          GroupSplitShare(memberId: 'a', owedAmountMinor: 20000),
          GroupSplitShare(memberId: 'b', owedAmountMinor: 20000),
          GroupSplitShare(memberId: 'c', owedAmountMinor: 20000),
        ],
        createdAt: date,
        updatedAt: date,
      );

      final List<MemberBalance> balances = balanceCalculator.calculate(
        memberIds: const <String>['a', 'b', 'c'],
        splits: <GroupSplit>[firstSplit, secondSplit],
      );

      final Map<String, int> byMember = <String, int>{
        for (final MemberBalance balance in balances)
          balance.memberId: balance.balanceMinor,
      };

      expect(byMember['a'], 40000);
      expect(byMember['b'], 10000);
      expect(byMember['c'], -50000);

      final List<DebtSettlement> settlements = settlementCalculator.calculate(
        balances,
      );

      expect(settlements, hasLength(2));

      final int totalPaid = settlements.fold<int>(
        0,
        (int total, DebtSettlement settlement) =>
            total + settlement.amountMinor,
      );

      expect(totalPaid, 50000);

      expect(
        settlements.every(
          (DebtSettlement settlement) => settlement.fromMemberId == 'c',
        ),
        isTrue,
      );
    });

    test('rounding never loses minor currency units', () {
      final List<GroupSplitShare> shares = equalSplitCalculator.calculate(
        totalAmountMinor: 100000,
        memberIds: const <String>['a', 'b', 'c'],
      );

      expect(shares[0].owedAmountMinor, 33334);

      expect(shares[1].owedAmountMinor, 33333);

      expect(shares[2].owedAmountMinor, 33333);

      expect(
        shares.fold<int>(
          0,
          (int total, GroupSplitShare share) => total + share.owedAmountMinor,
        ),
        100000,
      );
    });
  });
}

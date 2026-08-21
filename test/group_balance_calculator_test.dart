import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/group_split.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/member_balance.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/services/group_balance_calculator.dart';

void main() {
  const GroupBalanceCalculator calculator = GroupBalanceCalculator();

  GroupSplit createSplit({
    required String id,
    required int total,
    required String payer,
    required List<GroupSplitShare> shares,
  }) {
    final DateTime date = DateTime.utc(2026, 8, 21);

    return GroupSplit(
      id: id,
      groupId: 'group-1',
      title: 'Test expense',
      totalAmountMinor: total,
      currencyCode: 'PKR',
      currencyScale: 2,
      paidByMemberId: payer,
      occurredAt: date,
      splitMethod: GroupSplitMethod.equal,
      shares: shares,
      createdAt: date,
      updatedAt: date,
    );
  }

  test('calculates balances for one equal expense', () {
    final GroupSplit split = createSplit(
      id: 'split-1',
      total: 900,
      payer: 'a',
      shares: const <GroupSplitShare>[
        GroupSplitShare(memberId: 'a', owedAmountMinor: 300),
        GroupSplitShare(memberId: 'b', owedAmountMinor: 300),
        GroupSplitShare(memberId: 'c', owedAmountMinor: 300),
      ],
    );

    final List<MemberBalance> balances = calculator.calculate(
      memberIds: const <String>['a', 'b', 'c'],
      splits: <GroupSplit>[split],
    );

    expect(balances[0].balanceMinor, 600);

    expect(balances[1].balanceMinor, -300);

    expect(balances[2].balanceMinor, -300);
  });

  test('combines multiple expenses correctly', () {
    final GroupSplit first = createSplit(
      id: 'split-1',
      total: 900,
      payer: 'a',
      shares: const <GroupSplitShare>[
        GroupSplitShare(memberId: 'a', owedAmountMinor: 300),
        GroupSplitShare(memberId: 'b', owedAmountMinor: 300),
        GroupSplitShare(memberId: 'c', owedAmountMinor: 300),
      ],
    );

    final GroupSplit second = createSplit(
      id: 'split-2',
      total: 600,
      payer: 'b',
      shares: const <GroupSplitShare>[
        GroupSplitShare(memberId: 'a', owedAmountMinor: 200),
        GroupSplitShare(memberId: 'b', owedAmountMinor: 200),
        GroupSplitShare(memberId: 'c', owedAmountMinor: 200),
      ],
    );

    final List<MemberBalance> balances = calculator.calculate(
      memberIds: const <String>['a', 'b', 'c'],
      splits: <GroupSplit>[first, second],
    );

    expect(balances[0].balanceMinor, 400);

    expect(balances[1].balanceMinor, 100);

    expect(balances[2].balanceMinor, -500);

    final int total = balances.fold<int>(
      0,
      (int sum, MemberBalance balance) => sum + balance.balanceMinor,
    );

    expect(total, 0);
  });

  test('returns zero for member with no activity', () {
    final GroupSplit split = createSplit(
      id: 'split-1',
      total: 1000,
      payer: 'a',
      shares: const <GroupSplitShare>[
        GroupSplitShare(memberId: 'a', owedAmountMinor: 500),
        GroupSplitShare(memberId: 'b', owedAmountMinor: 500),
      ],
    );

    final List<MemberBalance> balances = calculator.calculate(
      memberIds: const <String>['a', 'b', 'c'],
      splits: <GroupSplit>[split],
    );

    expect(balances[2].balanceMinor, 0);
  });

  test('throws when payer is unknown', () {
    final GroupSplit split = createSplit(
      id: 'split-1',
      total: 1000,
      payer: 'unknown',
      shares: const <GroupSplitShare>[
        GroupSplitShare(memberId: 'a', owedAmountMinor: 1000),
      ],
    );

    expect(
      () => calculator.calculate(
        memberIds: const <String>['a'],
        splits: <GroupSplit>[split],
      ),
      throwsStateError,
    );
  });

  test('throws when shares do not equal expense total', () {
    final GroupSplit split = createSplit(
      id: 'split-1',
      total: 1000,
      payer: 'a',
      shares: const <GroupSplitShare>[
        GroupSplitShare(memberId: 'a', owedAmountMinor: 400),
        GroupSplitShare(memberId: 'b', owedAmountMinor: 400),
      ],
    );

    expect(
      () => calculator.calculate(
        memberIds: const <String>['a', 'b'],
        splits: <GroupSplit>[split],
      ),
      throwsStateError,
    );
  });
}

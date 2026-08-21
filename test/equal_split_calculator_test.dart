import 'package:flutter_test/flutter_test.dart';

import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/group_split.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/services/equal_split_calculator.dart';

void main() {
  const EqualSplitCalculator calculator = EqualSplitCalculator();

  test('splits amount equally when divisible', () {
    final List<GroupSplitShare> shares = calculator.calculate(
      totalAmountMinor: 900,
      memberIds: const <String>['a', 'b', 'c'],
    );

    expect(shares, hasLength(3));
    expect(shares[0].owedAmountMinor, 300);
    expect(shares[1].owedAmountMinor, 300);
    expect(shares[2].owedAmountMinor, 300);

    final int total = shares.fold<int>(
      0,
      (int sum, GroupSplitShare share) => sum + share.owedAmountMinor,
    );

    expect(total, 900);
  });

  test('distributes remainder without losing minor units', () {
    final List<GroupSplitShare> shares = calculator.calculate(
      totalAmountMinor: 1000,
      memberIds: const <String>['a', 'b', 'c'],
    );

    expect(shares, hasLength(3));

    expect(
      shares.map((GroupSplitShare share) => share.owedAmountMinor),
      containsAll(<int>[334, 333, 333]),
    );

    final int total = shares.fold<int>(
      0,
      (int sum, GroupSplitShare share) => sum + share.owedAmountMinor,
    );

    expect(total, 1000);
  });

  test('assigns remainder deterministically to earlier members', () {
    final List<GroupSplitShare> shares = calculator.calculate(
      totalAmountMinor: 1001,
      memberIds: const <String>['first', 'second', 'third'],
    );

    expect(shares[0].owedAmountMinor, 334);
    expect(shares[1].owedAmountMinor, 334);
    expect(shares[2].owedAmountMinor, 333);
  });

  test('throws when amount is zero', () {
    expect(
      () => calculator.calculate(
        totalAmountMinor: 0,
        memberIds: const <String>['a'],
      ),
      throwsFormatException,
    );
  });

  test('throws when member list is empty', () {
    expect(
      () => calculator.calculate(
        totalAmountMinor: 1000,
        memberIds: const <String>[],
      ),
      throwsFormatException,
    );
  });

  test('throws when member IDs contain duplicates', () {
    expect(
      () => calculator.calculate(
        totalAmountMinor: 1000,
        memberIds: const <String>['a', 'a'],
      ),
      throwsFormatException,
    );
  });

  test('throws when member ID is empty', () {
    expect(
      () => calculator.calculate(
        totalAmountMinor: 1000,
        memberIds: const <String>['a', ' '],
      ),
      throwsFormatException,
    );
  });
}

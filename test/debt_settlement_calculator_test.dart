import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/debt_settlement.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/entities/member_balance.dart';
import 'package:splitwise_expense_tracker/features/group_splits/domain/services/debt_settlement_calculator.dart';

void main() {
  const DebtSettlementCalculator calculator = DebtSettlementCalculator();

  group('DebtSettlementCalculator', () {
    test('returns no transfers for empty balances', () {
      final List<DebtSettlement> result = calculator.calculate(
        const <MemberBalance>[],
      );

      expect(result, isEmpty);
    });

    test('returns no transfers when everyone is settled', () {
      final List<DebtSettlement> result = calculator
          .calculate(const <MemberBalance>[
            MemberBalance(memberId: 'ali', balanceMinor: 0),
            MemberBalance(memberId: 'sara', balanceMinor: 0),
          ]);

      expect(result, isEmpty);
    });

    test('creates one direct settlement', () {
      final List<DebtSettlement> result = calculator
          .calculate(const <MemberBalance>[
            MemberBalance(memberId: 'ali', balanceMinor: -50000),
            MemberBalance(memberId: 'sara', balanceMinor: 50000),
          ]);

      expect(result, const <DebtSettlement>[
        DebtSettlement(
          fromMemberId: 'ali',
          toMemberId: 'sara',
          amountMinor: 50000,
        ),
      ]);
    });

    test('simplifies multiple debts', () {
      final List<DebtSettlement> result = calculator
          .calculate(const <MemberBalance>[
            MemberBalance(memberId: 'ali', balanceMinor: -400000),
            MemberBalance(memberId: 'sara', balanceMinor: -100000),
            MemberBalance(memberId: 'ahmed', balanceMinor: 200000),
            MemberBalance(memberId: 'hamza', balanceMinor: 300000),
          ]);

      expect(result.length, 3);

      expect(
        result[0],
        const DebtSettlement(
          fromMemberId: 'ali',
          toMemberId: 'hamza',
          amountMinor: 300000,
        ),
      );

      expect(
        result[1],
        const DebtSettlement(
          fromMemberId: 'ali',
          toMemberId: 'ahmed',
          amountMinor: 100000,
        ),
      );

      expect(
        result[2],
        const DebtSettlement(
          fromMemberId: 'sara',
          toMemberId: 'ahmed',
          amountMinor: 100000,
        ),
      );
    });

    test('handles multiple creditors and debtors', () {
      final List<DebtSettlement> result = calculator
          .calculate(const <MemberBalance>[
            MemberBalance(memberId: 'a', balanceMinor: -7000),
            MemberBalance(memberId: 'b', balanceMinor: -3000),
            MemberBalance(memberId: 'c', balanceMinor: 6000),
            MemberBalance(memberId: 'd', balanceMinor: 4000),
          ]);

      final int settledAmount = result.fold<int>(0, (
        int total,
        DebtSettlement settlement,
      ) {
        return total + settlement.amountMinor;
      });

      expect(settledAmount, 10000);
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('rejects balances which do not sum to zero', () {
      expect(
        () => calculator.calculate(const <MemberBalance>[
          MemberBalance(memberId: 'ali', balanceMinor: -10000),
          MemberBalance(memberId: 'sara', balanceMinor: 5000),
        ]),
        throwsStateError,
      );
    });

    test('rejects duplicate member ids', () {
      expect(
        () => calculator.calculate(const <MemberBalance>[
          MemberBalance(memberId: 'ali', balanceMinor: -10000),
          MemberBalance(memberId: 'ali', balanceMinor: 10000),
        ]),
        throwsFormatException,
      );
    });

    test('rejects empty member ids', () {
      expect(
        () => calculator.calculate(const <MemberBalance>[
          MemberBalance(memberId: '', balanceMinor: -10000),
          MemberBalance(memberId: 'sara', balanceMinor: 10000),
        ]),
        throwsFormatException,
      );
    });
  });
}

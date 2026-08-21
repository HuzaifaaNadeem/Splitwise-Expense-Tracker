import '../entities/group_split.dart';

final class EqualSplitCalculator {
  const EqualSplitCalculator();

  List<GroupSplitShare> calculate({
    required int totalAmountMinor,
    required List<String> memberIds,
  }) {
    if (totalAmountMinor <= 0) {
      throw const FormatException('Total amount must be greater than zero.');
    }

    if (memberIds.isEmpty) {
      throw const FormatException('At least one member is required.');
    }

    final List<String> normalizedMemberIds = memberIds
        .map((String id) => id.trim())
        .toList(growable: false);

    if (normalizedMemberIds.any((String id) => id.isEmpty)) {
      throw const FormatException('Member id cannot be empty.');
    }

    if (normalizedMemberIds.toSet().length != normalizedMemberIds.length) {
      throw const FormatException('Duplicate members are not allowed.');
    }

    final int memberCount = normalizedMemberIds.length;
    final int baseShare = totalAmountMinor ~/ memberCount;
    final int remainder = totalAmountMinor % memberCount;

    return List<GroupSplitShare>.generate(memberCount, (int index) {
      final int owedAmountMinor = baseShare + (index < remainder ? 1 : 0);

      return GroupSplitShare(
        memberId: normalizedMemberIds[index],
        owedAmountMinor: owedAmountMinor,
      );
    }, growable: false);
  }
}

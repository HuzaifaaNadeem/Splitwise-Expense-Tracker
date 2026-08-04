import 'package:isar_community/isar.dart';

part 'group_split_model.g.dart';

enum SplitMethod { equal, exact, percentage, shares }

@embedded
class GroupSplitShareModel {
  GroupSplitShareModel();

  late String memberId;

  /// Final canonical amount owed by this member.
  int owedAmountMinor = 0;

  /// Ten thousand basis points equal 100%.
  int? percentageBasisPoints;

  /// Used for weighted share calculations.
  int? shareWeight;
}

@collection
class GroupSplitModel {
  GroupSplitModel();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String localId;

  @Index()
  late String groupId;

  String title = '';

  String? notes;

  int totalAmountMinor = 0;

  String currencyCode = 'PKR';

  int currencyScale = 2;

  @Index()
  late String paidByMemberId;

  @Index()
  DateTime occurredAt = _epoch();

  @Enumerated(EnumType.name)
  SplitMethod splitMethod = SplitMethod.equal;

  List<GroupSplitShareModel> shares = <GroupSplitShareModel>[];

  @Index()
  String? linkedExpenseId;

  int revision = 1;

  DateTime createdAt = _epoch();

  DateTime updatedAt = _epoch();

  DateTime? deletedAt;
}

DateTime _epoch() {
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

import 'package:isar_community/isar.dart';

part 'group_model.g.dart';

@embedded
class GroupMemberModel {
  GroupMemberModel();

  late String memberId;

  String displayName = '';

  String? email;

  /// ARGB color value stored without depending on Flutter UI classes.
  int avatarColorValue = 0xFF2563EB;

  bool isCurrentUser = false;

  /// Inactive members remain available for old transactions.
  bool isActive = true;

  DateTime joinedAt = _epoch();
}

@collection
class GroupModel {
  GroupModel();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String localId;

  @Index()
  String name = '';

  String? description;

  late String ownerMemberId;

  String defaultCurrencyCode = 'PKR';

  int defaultCurrencyScale = 2;

  List<GroupMemberModel> members = <GroupMemberModel>[];

  bool isArchived = false;

  int revision = 1;

  DateTime createdAt = _epoch();

  DateTime updatedAt = _epoch();

  DateTime? deletedAt;
}

DateTime _epoch() {
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

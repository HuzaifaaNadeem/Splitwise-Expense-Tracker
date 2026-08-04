import 'package:isar_community/isar.dart';

part 'expense_model.g.dart';

enum LedgerEntryType { expense, income }

@collection
class ExpenseModel {
  ExpenseModel();

  Id id = Isar.autoIncrement;

  /// Stable identifier used by repositories, exports, and future backups.
  @Index(unique: true, replace: true)
  late String localId;

  /// Financial values are stored in minor units.
  ///
  /// Example:
  /// PKR 1,250.50 is stored as 125050.
  int amountMinor = 0;

  String currencyCode = 'PKR';

  int currencyScale = 2;

  String title = '';

  @Index()
  late String categoryId;

  @Index()
  DateTime occurredAt = _epoch();

  String? notes;

  /// Non-null when this entry belongs to a shared group.
  @Index()
  String? groupId;

  /// Connects the personal entry to a shared group transaction.
  @Index()
  String? groupSplitId;

  @Enumerated(EnumType.name)
  LedgerEntryType entryType = LedgerEntryType.expense;

  int revision = 1;

  DateTime createdAt = _epoch();

  DateTime updatedAt = _epoch();

  /// A non-null value means the record was soft-deleted.
  DateTime? deletedAt;
}

DateTime _epoch() {
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

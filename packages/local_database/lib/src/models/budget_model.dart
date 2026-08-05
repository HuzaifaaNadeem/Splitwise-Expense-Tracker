import 'package:isar_community/isar.dart';

part 'budget_model.g.dart';

enum BudgetPeriodType { weekly, monthly }

@collection
class BudgetModel {
  BudgetModel();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String localId;

  @Enumerated(EnumType.name)
  BudgetPeriodType periodType = BudgetPeriodType.monthly;

  int amountMinor = 0;

  String currencyCode = 'PKR';

  int currencyScale = 2;

  bool isActive = true;

  int revision = 1;

  DateTime createdAt = _epoch();

  DateTime updatedAt = _epoch();

  DateTime? deletedAt;
}

DateTime _epoch() {
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

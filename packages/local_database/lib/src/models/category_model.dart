import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  CategoryModel();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String localId;

  @Index()
  String name = '';

  /// Material icon code point.
  int iconCodePoint = 0xe56c;

  /// ARGB color value.
  int colorValue = 0xFF2563EB;

  /// Built-in categories cannot be accidentally removed.
  bool isDefault = false;

  bool isActive = true;

  int sortOrder = 0;

  DateTime createdAt = _epoch();

  DateTime updatedAt = _epoch();

  DateTime? deletedAt;
}

DateTime _epoch() {
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

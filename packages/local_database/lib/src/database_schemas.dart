import 'package:isar_community/isar.dart';

import 'models/budget_model.dart';
import 'models/category_model.dart';
import 'models/expense_model.dart';
import 'models/group_model.dart';
import 'models/group_split_model.dart';

final List<CollectionSchema<dynamic>> applicationSchemas =
    List<CollectionSchema<dynamic>>.unmodifiable(<CollectionSchema<dynamic>>[
      ExpenseModelSchema,
      GroupModelSchema,
      GroupSplitModelSchema,
      CategoryModelSchema,
      BudgetModelSchema,
    ]);

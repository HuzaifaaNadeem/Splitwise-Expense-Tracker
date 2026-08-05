import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/db/database_provider.dart';
import 'core/db/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final DatabaseService databaseService = await DatabaseService.open();

  runApp(
    ProviderScope(
      overrides: <Override>[
        databaseServiceProvider.overrideWithValue(databaseService),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

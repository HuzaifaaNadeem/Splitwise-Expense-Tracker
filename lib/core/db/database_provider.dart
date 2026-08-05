import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_service.dart';

final Provider<DatabaseService> databaseServiceProvider =
    Provider<DatabaseService>((ref) {
      throw StateError('DatabaseService must be overridden in ProviderScope.');
    });

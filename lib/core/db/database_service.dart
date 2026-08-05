import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:local_database/local_database.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/database_constants.dart';

final class DatabaseService {
  DatabaseService._(this.isar);

  /// Creates a database service around an already-open Isar instance.
  ///
  /// Intended for automated tests where the database is opened in a
  /// temporary directory.
  DatabaseService.forTesting(this.isar);

  static Future<DatabaseService>? _openingFuture;

  final Isar isar;

  static Future<DatabaseService> open() {
    final Isar? existingInstance = Isar.getInstance(
      DatabaseConstants.instanceName,
    );

    if (existingInstance != null) {
      return Future<DatabaseService>.value(DatabaseService._(existingInstance));
    }

    return _openingFuture ??= _openInternal().whenComplete(() {
      _openingFuture = null;
    });
  }

  static Future<DatabaseService> _openInternal() async {
    final Directory directory = await getApplicationSupportDirectory();

    final Isar database = await Isar.open(
      applicationSchemas,
      directory: directory.path,
      name: DatabaseConstants.instanceName,
      maxSizeMiB: DatabaseConstants.maximumSizeMiB,
      relaxedDurability: false,
      inspector: kDebugMode,
    );

    return DatabaseService._(database);
  }

  Future<T> write<T>(Future<T> Function() operation) {
    return isar.writeTxn<T>(operation);
  }

  Future<bool> close({bool deleteFromDisk = false}) {
    return isar.close(deleteFromDisk: deleteFromDisk);
  }
}

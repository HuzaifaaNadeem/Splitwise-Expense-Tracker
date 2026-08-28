import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app_currency.dart';

final defaultCurrencyControllerProvider =
    NotifierProvider<DefaultCurrencyController, AppCurrency>(
      DefaultCurrencyController.new,
    );

final class DefaultCurrencyController extends Notifier<AppCurrency> {
  static const String _fileName = 'default_currency.txt';

  bool _loadStarted = false;
  bool _changedByUser = false;

  @override
  AppCurrency build() {
    if (!_loadStarted) {
      _loadStarted = true;
      unawaited(_loadPersistedCurrency());
    }

    return AppCurrency.pkr;
  }

  Future<bool> setCurrency(String code) async {
    final AppCurrency currency = AppCurrency.fromCode(code);

    _changedByUser = true;
    state = currency;

    try {
      final File file = await _settingsFile();

      await file.parent.create(recursive: true);
      await file.writeAsString(currency.code, flush: true);

      return true;
    } on Object {
      return false;
    }
  }

  Future<void> _loadPersistedCurrency() async {
    try {
      final File file = await _settingsFile();

      if (!await file.exists()) {
        return;
      }

      final String code = (await file.readAsString()).trim();

      if (_changedByUser) {
        return;
      }

      state = AppCurrency.fromCode(code);
    } on Object {
      // Keep the in-memory PKR fallback when local settings are unavailable.
    }
  }

  Future<File> _settingsFile() async {
    final Directory directory = await getApplicationSupportDirectory();

    return File(
      '${directory.path}${Platform.pathSeparator}$_fileName',
    );
  }
}

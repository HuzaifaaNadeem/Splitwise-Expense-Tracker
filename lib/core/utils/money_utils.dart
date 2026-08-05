import 'package:intl/intl.dart';

abstract final class MoneyUtils {
  static int? parseToMinorUnits(String input, {required int scale}) {
    if (scale < 0 || scale > 3) {
      return null;
    }

    final String normalized = input.trim().replaceAll(',', '');

    if (normalized.isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(normalized)) {
      return null;
    }

    final List<String> parts = normalized.split('.');

    if (parts.length > 2) {
      return null;
    }

    final int? whole = int.tryParse(parts.first);

    if (whole == null) {
      return null;
    }

    String fraction = parts.length == 2 ? parts[1] : '';

    if (fraction.length > scale) {
      return null;
    }

    fraction = fraction.padRight(scale, '0');

    final int fractionValue = fraction.isEmpty ? 0 : int.parse(fraction);

    return (whole * _powerOfTen(scale)) + fractionValue;
  }

  static String formatMinorUnits(
    int amountMinor, {
    required String currencyCode,
    required int scale,
  }) {
    final bool isNegative = amountMinor < 0;
    final int absoluteAmount = amountMinor.abs();
    final int divisor = _powerOfTen(scale);

    final int whole = absoluteAmount ~/ divisor;
    final int fraction = absoluteAmount % divisor;

    final String wholeFormatted = NumberFormat.decimalPattern().format(whole);

    final String sign = isNegative ? '-' : '';

    if (scale == 0) {
      return '$currencyCode $sign$wholeFormatted';
    }

    final String fractionFormatted = fraction.toString().padLeft(scale, '0');

    return '$currencyCode '
        '$sign$wholeFormatted.$fractionFormatted';
  }

  static int _powerOfTen(int exponent) {
    int result = 1;

    for (int index = 0; index < exponent; index++) {
      result *= 10;
    }

    return result;
  }
}

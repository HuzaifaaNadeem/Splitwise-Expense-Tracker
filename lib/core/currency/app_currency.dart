final class AppCurrency {
  const AppCurrency({required this.code, required this.name, this.scale = 2});

  final String code;
  final String name;
  final int scale;

  String get label => '$code - $name';

  static const AppCurrency pkr = AppCurrency(
    code: 'PKR',
    name: 'Pakistani Rupee',
  );

  static const AppCurrency usd = AppCurrency(code: 'USD', name: 'US Dollar');

  static const AppCurrency gbp = AppCurrency(
    code: 'GBP',
    name: 'British Pound',
  );

  static const AppCurrency eur = AppCurrency(code: 'EUR', name: 'Euro');

  static const AppCurrency aed = AppCurrency(code: 'AED', name: 'UAE Dirham');

  static const AppCurrency sar = AppCurrency(code: 'SAR', name: 'Saudi Riyal');

  static const List<AppCurrency> supported = <AppCurrency>[
    pkr,
    usd,
    gbp,
    eur,
    aed,
    sar,
  ];

  static AppCurrency fromCode(String? code) {
    final String normalized = code?.trim().toUpperCase() ?? '';

    for (final AppCurrency currency in supported) {
      if (currency.code == normalized) {
        return currency;
      }
    }

    return pkr;
  }
}

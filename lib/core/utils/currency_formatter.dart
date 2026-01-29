import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _nprFormatter = NumberFormat.currency(
    locale: 'en_NP',
    symbol: 'NPR ',
    decimalDigits: 2,
  );

  static String npr(num amount) {
    return _nprFormatter.format(amount);
  }

  static String nprCompact(num amount) {
    final compact = NumberFormat.compact(locale: 'en_NP');
    return 'NPR ${compact.format(amount)}';
  }
}

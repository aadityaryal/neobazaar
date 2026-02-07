import 'package:intl/intl.dart';

class GamificationFormatters {
  GamificationFormatters._();

  static final NumberFormat _numberFormatter = NumberFormat('#,##0', 'en_US');

  static String tokens(num value) {
    return '${_numberFormatter.format(value)} TOK';
  }

  static String xp(num value) {
    return '${_numberFormatter.format(value)} XP';
  }

  static String reputation(num value) {
    return _numberFormatter.format(value);
  }
}

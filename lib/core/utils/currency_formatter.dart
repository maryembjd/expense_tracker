import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    final symbol = _symbolFor(currencyCode);
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    final nf = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${nf.format(amount)}';
  }

  static String formatFull(double amount, String currencyCode) {
    final symbol = _symbolFor(currencyCode);
    final nf = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${nf.format(amount)}';
  }

  static String formatCompact(double amount, String currencyCode) {
    final symbol = _symbolFor(currencyCode);
    if (amount >= 1000000) return '$symbol${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String _symbolFor(String code) {
    final match = AppConstants.currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'symbol': code},
    );
    return match['symbol'] ?? code;
  }

  static String nameFor(String code) {
    final match = AppConstants.currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'name': code},
    );
    return match['name'] ?? code;
  }
}

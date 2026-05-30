import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateShort = DateFormat('MMM d');
  static final _dateMedium = DateFormat('MMM d, yyyy');
  static final _dateLong = DateFormat('MMMM d, yyyy');
  static final _dateTime = DateFormat('MMM d, yyyy • h:mm a');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _monthShort = DateFormat('MMM yyyy');
  static final _dayMonth = DateFormat('d MMM');
  static final _weekday = DateFormat('EEEE');
  static final _isoDate = DateFormat('yyyy-MM-dd');

  static String toShort(DateTime date) => _dateShort.format(date);
  static String toMedium(DateTime date) => _dateMedium.format(date);
  static String toLong(DateTime date) => _dateLong.format(date);
  static String toDateTime(DateTime date) => _dateTime.format(date);
  static String toMonthYear(DateTime date) => _monthYear.format(date);
  static String toMonthShort(DateTime date) => _monthShort.format(date);
  static String toDayMonth(DateTime date) => _dayMonth.format(date);
  static String toWeekday(DateTime date) => _weekday.format(date);
  static String toIso(DateTime date) => _isoDate.format(date);

  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes < 2) return 'Just now';
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return toMedium(date);
  }

  static String toGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (today.difference(d).inDays < 7) return _weekday.format(date);
    return toMedium(date);
  }

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
  static DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  static DateTime startOfWeek(DateTime date) {
    final diff = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - diff);
  }

  static List<DateTime> getLast12Months() {
    final now = DateTime.now();
    return List.generate(12, (i) => DateTime(now.year, now.month - i, 1)).reversed.toList();
  }
}

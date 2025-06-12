import 'package:intl/intl.dart';

class DateHelper {
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Formats [DateTime?] into Laravel-compatible string, or returns null.
  static String? format(DateTime? dateTime) {
    return dateTime == null ? null : _formatter.format(dateTime);
  }
}

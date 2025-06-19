import 'package:intl/intl.dart';

class DateHelper {
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Formats [DateTime?] into Laravel-compatible string, or returns null.
  static String? format(DateTime? dateTime) {
    return dateTime == null ? null : _formatter.format(dateTime);
  }
}

class AppHelper {
  // static const String baseurl = 'http://192.168.1.16:8000';
  static const String baseurl = 'http://10.35.0.141:8000';
  // static const String baseurl = 'https://kendedes.cathajatim.id';
  static const String apiUrl = '$baseurl/api';
  static const String updateUrl = 'https://s.bps.go.id/kendedes';
  static const String majapahitLoginUrl =
      'https://www.majapah.it/dashboard?callback_uri=$baseurl/majapahit-mobile-login';
}

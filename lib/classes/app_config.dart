class AppConfig {
  static const String baseurl = 'http://192.168.1.8:8000';
  // static const String baseurl = 'http://10.35.1.11:8000';
  // static const String baseurl = 'https://kendedes.cathajatim.id';
  static const String apiUrl = '$baseurl/api';
  static const String updateUrl = 'https://s.bps.go.id/kendedes';
  static const String majapahitLoginUrl =
      'https://www.majapah.it/dashboard?callback_uri=$baseurl/majapahit-mobile-login';

  static const String helpUrl = 'http://s.bps.go.id/kendedes_panduan';
  static const String feedbackUrl = 'http://s.bps.go.id/kendedes_feedback';

  static const int stackTraceLimitCharacter = 200;
}

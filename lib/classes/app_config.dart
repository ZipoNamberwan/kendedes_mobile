class AppConfig {
  // static const String baseurl = 'http://192.168.1.7:8888';
  // static const String baseurl = 'http://10.35.0.98:8888';
  static const String baseurl = 'https://kendedes.cathajatim.id';
  static const String apiUrl = '$baseurl/api';
  static const String updateUrl = 'https://s.bps.go.id/kendedes';
  static const String majapahitLoginUrl =
      '$baseurl/login/majapahit?source=android';

  static const String helpUrl = 'http://s.bps.go.id/kendedes_panduan';
  static const String feedbackUrl = 'http://s.bps.go.id/kendedes_feedback';

  static const int stackTraceLimitCharacter = 200;
}

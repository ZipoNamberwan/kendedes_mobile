import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:kendedes_mobile/classes/services/shared_preference_service.dart';

class VersionCheckingProvider {
  static final VersionCheckingProvider _instance =
      VersionCheckingProvider._internal();
  factory VersionCheckingProvider() => _instance;

  VersionCheckingProvider._internal();

  late DioService _dioService;
  late SharedPreferenceService _sharedPreferenceService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
    _sharedPreferenceService = SharedPreferenceService();
    await _sharedPreferenceService.init();
  }

  Future<Map<String, dynamic>> checkForUpdates(
    int currentVersion,
    String organizationId,
  ) async {
    final response = await _dioService.dio.get(
      '/version/check',
      queryParameters: {
        'version': currentVersion,
        'organization': organizationId,
      },
    );
    return response.data['data'];
  }

  Future<void> saveLastCheckVersion(int millisecondsSinceEpoch) async {
    await _sharedPreferenceService.saveLastCheckVersion(millisecondsSinceEpoch);
  }

  int? getLastCheckVersion() {
    return _sharedPreferenceService.getLastCheckVersion();
  }
}

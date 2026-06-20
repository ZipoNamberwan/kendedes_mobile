import 'package:kendedes_mobile/classes/services/dio_service.dart';

class InfoProvider {
  static final InfoProvider _instance = InfoProvider._internal();
  factory InfoProvider() => _instance;

  InfoProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  /// Fetches a list of infos from the server.
  /// [lastCheck] is an optional ISO-8601 date string (e.g. '2026-06-10')
  /// sent as the [last_check] query parameter.
  /// Returns the raw list from [response.data['data']] or null if not present.
  Future<List<Map<String, dynamic>>?> getInfoList({String? lastCheck}) async {
    final Map<String, dynamic> queryParams = {};
    if (lastCheck != null) {
      queryParams['last_check'] = lastCheck;
    }

    final response = await _dioService.dio.get(
      '/info',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data['data'];
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetches the detail of a single info by [id].
  /// Returns the raw map from [response.data['data']] or null if not present.
  Future<Map<String, dynamic>?> getInfoDetail(String id) async {
    final response = await _dioService.dio.get('/info/$id');

    final data = response.data['data'];
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }
}


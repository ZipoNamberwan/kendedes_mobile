import 'package:kendedes_mobile/classes/services/dio_service.dart';

class KbliProvider {
  static final KbliProvider _instance = KbliProvider._internal();
  factory KbliProvider() => _instance;

  KbliProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  Future<List<Map<String, dynamic>>> getKbliStatistics(
    String type,
    String longCode,
  ) async {
    final response = await _dioService.dio.get('/statistics/$type/$longCode');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }
}

import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/area/sls.dart';

class PolygonProvider {
  static final PolygonProvider _instance = PolygonProvider._internal();
  factory PolygonProvider() => _instance;

  PolygonProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  Future<List<Village>> getVillagesBySubdistrictId(String subdistrictId) async {
    final response = await _dioService.dio.get('/villages/$subdistrictId');

    final List<dynamic> villagesData = response.data['data'];
    return villagesData.map((village) => Village.fromJson(village)).toList();
  }

  Future<List<Sls>> getSlsByVillageId(String villageId) async {
    final response = await _dioService.dio.get('/sls/$villageId');

    final List<dynamic> slsData = response.data['data'];
    return slsData.map((sls) => Sls.fromJson(sls)).toList();
  }

  Future<Map<String, dynamic>> downloadPolygonGeoJson(
    String polygonId,
    String polygonType,
  ) async {
    final response = await _dioService.dio.post(
      '/polygon/download',
      data: {'id': polygonId, 'type': polygonType},
    );

    return response.data;
  }
}

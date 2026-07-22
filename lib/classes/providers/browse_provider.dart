import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/village.dart';

class BrowseProvider {
  static final BrowseProvider _instance = BrowseProvider._internal();
  factory BrowseProvider() => _instance;

  BrowseProvider._internal();

  late DioService _dioService;
  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  Future<List<Map<String, dynamic>>> getBusinessesInBox(
    double minLat,
    double minLng,
    double maxLat,
    double maxLng,
  ) async {
    final response = await _dioService.dio.get(
      '/v2/business-in-box-spatial',
      queryParameters: {
        'min_lat': minLat,
        'min_lng': minLng,
        'max_lat': maxLat,
        'max_lng': maxLng,
      },
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> getBusinessesBySls(String slsId) async {
    final response = await _dioService.dio.get(
      '/v2/business-by-sls',
      queryParameters: {'sls': slsId},
    );
    return Map<String, dynamic>.from(response.data['data']);
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
}

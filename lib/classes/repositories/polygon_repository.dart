import 'package:kendedes_mobile/classes/providers/polygon_provider.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/area/sls.dart';

class PolygonRepository {
  static final PolygonRepository _instance = PolygonRepository._internal();
  factory PolygonRepository() => _instance;

  PolygonRepository._internal();

  late PolygonProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = PolygonProvider();
    await _provider.init();
  }

  Future<List<Village>> getVillagesBySubdistrictId(String subdistrictId) async {
    return await _provider.getVillagesBySubdistrictId(subdistrictId);
  }

  Future<List<Sls>> getSlsByVillageId(String villageId) async {
    return await _provider.getSlsByVillageId(villageId);
  }

  Future<Map<String, dynamic>> downloadPolygonGeoJson(
    String polygonId,
    String polygonType,
  ) async {
    return await _provider.downloadPolygonGeoJson(polygonId, polygonType);
  }
}

import 'package:kendedes_mobile/classes/providers/browse_provider.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class BrowseRepository {
  static final BrowseRepository _instance = BrowseRepository._internal();
  factory BrowseRepository() => _instance;

  BrowseRepository._internal();

  late BrowseProvider _browseProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _browseProvider = BrowseProvider();
    await _browseProvider.init();
  }

  Future<List<TagData>> getBusinessesInBox({
    required double minLat,
    required double minLng,
    required double maxLat,
    required double maxLng,
  }) async {
    final response = await _browseProvider.getBusinessesInBox(
      minLat,
      minLng,
      maxLat,
      maxLng,
    );
    return response.map((data) => TagData.fromServerJson(data)).toList();
  }

  Future<Map<String, dynamic>> getBusinessesBySls(String slsId) async {
    final response = await _browseProvider.getBusinessesBySls(slsId);
    return response;
  }

  Future<List<Village>> getVillagesBySubdistrictId(String subdistrictId) async {
    return await _browseProvider.getVillagesBySubdistrictId(subdistrictId);
  }

  Future<List<Sls>> getSlsByVillageId(String villageId) async {
    return await _browseProvider.getSlsByVillageId(villageId);
  }
}

import 'package:kendedes_mobile/classes/providers/move_provider.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';

class MoveRepository {
  static final MoveRepository _instance = MoveRepository._internal();
  factory MoveRepository() => _instance;

  MoveRepository._internal();

  late MoveProvider _moveProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _moveProvider = MoveProvider();
    await _moveProvider.init();
  }

  Future<Map<String, dynamic>> getBusinessesBySls(String slsId) async {
    final response = await _moveProvider.getBusinessesBySls(slsId);
    return response;
  }

  Future<List<Village>> getVillagesBySubdistrictId(String subdistrictId) async {
    return await _moveProvider.getVillagesBySubdistrictId(subdistrictId);
  }

  Future<List<Sls>> getSlsByVillageId(String villageId) async {
    return await _moveProvider.getSlsByVillageId(villageId);
  }

  Future<Sls> findSlsByLatLng(double lat, double lng) async {
    final response = await _moveProvider.findSlsByLatLng(lat, lng);
    return Sls.fromJson(response);
  }

  Future<List<Map<String, dynamic>>> checkBusinessDataUpdate(
    List<SlsWithBusiness> slsWithBusinessData,
  ) async {
    final data = slsWithBusinessData.map((e) => e.toServerJson()).toList();
    return await _moveProvider.checkBusinessDataUpdate(data);
  }
}

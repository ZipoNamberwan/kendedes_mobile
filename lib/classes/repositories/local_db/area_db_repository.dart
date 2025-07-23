import 'package:kendedes_mobile/classes/providers/local_db/area_db_provider.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/area/sls.dart';

class AreaDbRepository {
  static final AreaDbRepository _instance = AreaDbRepository._internal();
  factory AreaDbRepository() => _instance;

  AreaDbRepository._internal();

  late AreaDbProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = AreaDbProvider();
    await _provider.init();
  }

  /// Get all regencies
  Future<List<Regency>> getRegencies() async {
    final regenciesData = await _provider.getRegencies();
    return regenciesData.map((data) => Regency.fromJson(data)).toList();
  }

  /// Get subdistricts by regency ID
  Future<List<Subdistrict>> getSubdistrictsByRegency(String regencyId) async {
    final subdistrictsData = await _provider.getSubdistrictsByRegency(
      regencyId,
    );
    return subdistrictsData.map((data) => Subdistrict.fromJson(data)).toList();
  }

  /// Get villages by subdistrict ID
  Future<List<Village>> getVillagesBySubdistrict(String subdistrictId) async {
    final villagesData = await _provider.getVillagesBySubdistrict(
      subdistrictId,
    );
    return villagesData.map((data) => Village.fromJson(data)).toList();
  }

  /// Get SLS by village ID
  Future<List<Sls>> getSlsByVillage(String villageId) async {
    final slsData = await _provider.getSlsByVillage(villageId);
    return slsData.map((data) => Sls.fromJson(data)).toList();
  }

  /// Get regency by ID
  Future<Regency?> getRegencyById(String regencyId) async {
    final regencyData = await _provider.getRegencyById(regencyId);
    return regencyData != null ? Regency.fromJson(regencyData) : null;
  }

  /// Get subdistrict by ID
  Future<Subdistrict?> getSubdistrictById(String subdistrictId) async {
    final subdistrictData = await _provider.getSubdistrictById(subdistrictId);
    return subdistrictData != null
        ? Subdistrict.fromJson(subdistrictData)
        : null;
  }

  /// Get village by ID
  Future<Village?> getVillageById(String villageId) async {
    final villageData = await _provider.getVillageById(villageId);
    return villageData != null ? Village.fromJson(villageData) : null;
  }

  /// Get SLS by ID
  Future<Sls?> getSlsById(String slsId) async {
    final slsData = await _provider.getSlsById(slsId);
    return slsData != null ? Sls.fromJson(slsData) : null;
  }

  /// Check if regencies table is empty
  Future<bool> isRegenciesEmpty() async {
    return await _provider.isRegenciesEmpty();
  }

  /// Check if subdistricts table is empty
  Future<bool> isSubdistrictsEmpty() async {
    return await _provider.isSubdistrictsEmpty();
  }

  /// Insert batch of regencies
  Future<void> insertBatchRegencies(List<Regency> regencies) async {
    final regenciesData = regencies.map((regency) => regency.toJson()).toList();
    await _provider.insertBatchRegencies(regenciesData);
  }

  /// Insert batch of subdistricts
  Future<void> insertBatchSubdistricts(List<Subdistrict> subdistricts) async {
    final subdistrictsData =
        subdistricts.map((subdistrict) => subdistrict.toJson()).toList();
    await _provider.insertBatchSubdistricts(subdistrictsData);
  }

  /// Insert batch of villages
  Future<void> insertBatchVillages(List<Village> villages) async {
    final villagesData = villages.map((village) => village.toJson()).toList();
    await _provider.insertBatchVillages(villagesData);
  }

  /// Insert batch of SLS
  Future<void> insertBatchSls(List<Sls> slsList) async {
    final slsData = slsList.map((sls) => sls.toJson()).toList();
    await _provider.insertBatchSls(slsData);
  }
}

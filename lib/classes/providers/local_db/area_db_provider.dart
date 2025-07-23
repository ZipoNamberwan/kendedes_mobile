import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class AreaDbProvider {
  static final AreaDbProvider _instance = AreaDbProvider._internal();
  factory AreaDbProvider() => _instance;

  AreaDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  /// Check if regencies table is empty
  Future<bool> isRegenciesEmpty() async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM regencies',
    );

    final int count = result.first['count'] as int;
    return count == 0;
  }

  /// Check if subdistricts table is empty
  Future<bool> isSubdistrictsEmpty() async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM subdistricts',
    );

    final int count = result.first['count'] as int;
    return count == 0;
  }

  /// Get all regencies
  Future<List<Map<String, dynamic>>> getRegencies() async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'regencies',
      orderBy: 'id ASC',
    );

    return result;
  }

  /// Get subdistricts by regency ID
  /// [regencyId] The ID of the regency
  Future<List<Map<String, dynamic>>> getSubdistrictsByRegency(
    String regencyId,
  ) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'subdistricts',
      where: 'regency_id = ?',
      whereArgs: [regencyId],
      orderBy: 'id ASC',
    );

    return result;
  }

  /// Get villages by subdistrict ID
  /// [subdistrictId] The ID of the subdistrict
  Future<List<Map<String, dynamic>>> getVillagesBySubdistrict(
    String subdistrictId,
  ) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'villages',
      where: 'subdistrict_id = ?',
      whereArgs: [subdistrictId],
      orderBy: 'id ASC',
    );

    return result;
  }

  /// Get SLS by village ID
  /// [villageId] The ID of the village
  Future<List<Map<String, dynamic>>> getSlsByVillage(String villageId) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'sls',
      where: 'village_id = ?',
      whereArgs: [villageId],
      orderBy: 'id ASC',
    );

    return result;
  }

  /// Get regency by ID
  Future<Map<String, dynamic>?> getRegencyById(String regencyId) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'regencies',
      where: 'id = ?',
      whereArgs: [regencyId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Get subdistrict by ID
  Future<Map<String, dynamic>?> getSubdistrictById(String subdistrictId) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'subdistricts',
      where: 'id = ?',
      whereArgs: [subdistrictId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Get village by ID
  Future<Map<String, dynamic>?> getVillageById(String villageId) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'villages',
      where: 'id = ?',
      whereArgs: [villageId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Get SLS by ID
  Future<Map<String, dynamic>?> getSlsById(String slsId) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'sls',
      where: 'id = ?',
      whereArgs: [slsId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Insert batch of regencies
  /// [regencies] List of regency data maps
  Future<void> insertBatchRegencies(
    List<Map<String, dynamic>> regencies,
  ) async {
    final Database db = _dbProvider.db;

    await db.transaction((txn) async {
      for (Map<String, dynamic> regency in regencies) {
        await txn.insert(
          'regencies',
          regency,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Insert batch of subdistricts
  /// [subdistricts] List of subdistrict data maps
  Future<void> insertBatchSubdistricts(
    List<Map<String, dynamic>> subdistricts,
  ) async {
    final Database db = _dbProvider.db;

    await db.transaction((txn) async {
      for (Map<String, dynamic> subdistrict in subdistricts) {
        await txn.insert(
          'subdistricts',
          subdistrict,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Insert batch of villages
  /// [villages] List of village data maps
  Future<void> insertBatchVillages(List<Map<String, dynamic>> villages) async {
    final Database db = _dbProvider.db;

    await db.transaction((txn) async {
      for (Map<String, dynamic> village in villages) {
        await txn.insert(
          'villages',
          village,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Insert batch of SLS
  /// [slsList] List of SLS data maps
  Future<void> insertBatchSls(List<Map<String, dynamic>> slsList) async {
    final Database db = _dbProvider.db;

    await db.transaction((txn) async {
      for (Map<String, dynamic> sls in slsList) {
        await txn.insert(
          'sls',
          sls,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}

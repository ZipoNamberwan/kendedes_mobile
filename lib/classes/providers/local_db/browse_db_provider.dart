import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:kendedes_mobile/models/interaction_mode.dart';
import 'package:sqflite/sqflite.dart';

class BrowseDbProvider {
  static final BrowseDbProvider _instance = BrowseDbProvider._internal();
  factory BrowseDbProvider() => _instance;

  BrowseDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  // Local Database Operations
  Future<void> insertBrowseProject(Map<String, dynamic> data) async {
    await _dbProvider.db.insert(
      'projects',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getProjectsByUser(String userId) async {
    final result = await _dbProvider.db.query(
      'projects',
      where: 'user_id = ? AND interaction_mode = ?',
      whereArgs: [userId, InteractionMode.browse.key],
    );

    return result;
  }

  // sls_with_business table operations
  Future<void> createSlsWithBusiness(Map<String, dynamic> data) async {
    await _dbProvider.db.insert(
      'sls_with_business',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSlsWithBusiness(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _dbProvider.db.update(
      'sls_with_business',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSlsWithBusiness(String id) async {
    await _dbProvider.db.delete(
      'sls_with_business',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSlsWithBusinessList({
    required String currentUserId,
  }) async {
    return await _dbProvider.db.query(
      'sls_with_business',
      where: 'user_id = ?',
      whereArgs: [currentUserId],
      orderBy: 'sls_long_code ASC',
    );
  }

  Future<void> insertBusinessesDataBatch(
    List<Map<String, dynamic>> dataList,
  ) async {
    final db = _dbProvider.db;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final data in dataList) {
        batch.insert(
          'tag_data',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  Future<void> insertProjectsBatch(List<Map<String, dynamic>> dataList) async {
    final db = _dbProvider.db;
    final batch = db.batch();

    for (final data in dataList) {
      batch.insert(
        'projects',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getBusinessesByBrowseProjects(
    List<String> projectIds,
  ) async {
    final placeholders = List.filled(projectIds.length, '?').join(', ');
    final result = await _dbProvider.db.query(
      'tag_data',
      where: 'project_id IN ($placeholders)',
      whereArgs: projectIds,
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getBusinessesBySls(
    String slsId,
    List<String> projectIds,
  ) async {
    final placeholders = List.filled(projectIds.length, '?').join(', ');
    final result = await _dbProvider.db.query(
      'tag_data',
      where: 'sls_id = ? AND project_id IN ($placeholders)',
      whereArgs: [slsId, ...projectIds],
    );
    return result;
  }

  Future<bool> deleteBusinessesBySlsId(
    String slsId,
    List<String> projectIds,
  ) async {
    final placeholders = List.filled(projectIds.length, '?').join(', ');
    final count = await _dbProvider.db.delete(
      'tag_data',
      where: 'sls_id = ? AND project_id IN ($placeholders)',
      whereArgs: [slsId, ...projectIds],
    );
    return count > 0;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _dbProvider.db.query('users');
  }

  //insert users by batch
  Future<void> insertUsersBatch(List<Map<String, dynamic>> dataList) async {
    final db = _dbProvider.db;
    final batch = db.batch();

    for (final data in dataList) {
      batch.insert('users', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<int?> getSlsWithBusinessCountBySlsId(
    String slsId,
    String userId,
  ) async {
    final result = await _dbProvider.db.query(
      'sls_with_business',
      where: 'sls_id = ? AND user_id = ?',
      whereArgs: [slsId, userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final businessCountValue = result.first['business_count'];
      if (businessCountValue is int) return businessCountValue;
      if (businessCountValue is num) return businessCountValue.toInt();
      return null;
    }
    return null;
  }

  Future<int?> getBusinessCountBySlsId(
    String slsId,
    List<String> projectIds,
  ) async {
    final placeholders = List.filled(projectIds.length, '?').join(', ');
    final result = await _dbProvider.db.query(
      'tag_data',
      columns: ['COUNT(*) AS count'],
      where: 'sls_id = ? AND project_id IN ($placeholders)',
      whereArgs: [slsId, ...projectIds],
    );
    if (result.isNotEmpty) {
      final countValue = result.first['count'];
      if (countValue is int) return countValue;
      if (countValue is num) return countValue.toInt();
    }
    return null;
  }

  Future<bool> hasPolygonBySlsId(String slsId, String userId) async {
    final result = await _dbProvider.db.query(
      'user_polygons',
      columns: ['id'],
      where: 'user_id = ? AND polygon_id = ?',
      whereArgs: [userId, slsId],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}

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
    required String userId,
  }) async {
    return await _dbProvider.db.query(
      'sls_with_business',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'sls_long_code ASC',
    );
  }

  Future<void> insertTagDataBatch(List<Map<String, dynamic>> dataList) async {
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

  Future<List<Map<String, dynamic>>> getAllProjects() async {
    return await _dbProvider.db.query('projects');
  }

  Future<List<Map<String, dynamic>>> getBusinessByBrowseProjects(
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
}

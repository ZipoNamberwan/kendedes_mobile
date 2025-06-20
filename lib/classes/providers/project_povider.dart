import 'package:kendedes_mobile/classes/providers/local_database_provider.dart';
import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:sqflite/sqflite.dart';

class ProjectProvider {
  static final ProjectProvider _instance = ProjectProvider._internal();
  factory ProjectProvider() => _instance;

  ProjectProvider._internal();

  late DioService _dioService;
  late LocalDatabaseProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
    _dbProvider = LocalDatabaseProvider();
    await _dbProvider.init();
  }

  Future<List<Map<String, dynamic>>> getProjects(String userId) async {
    final response = await _dioService.dio.get('/users/$userId/projects');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> createProject(
    Map<String, dynamic> projectData,
  ) async {
    final response = await _dioService.dio.post(
      '/mobile-projects',
      data: projectData,
    );
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> updateProject(
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    final response = await _dioService.dio.put(
      '/mobile-projects/$projectId',
      data: projectData,
    );
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<void> deleteProject(String projectId) async {
    await _dioService.dio.delete('/mobile-projects/$projectId');
  }

  // Local Database Operations
  Future<void> insertToLocalDb(Map<String, dynamic> data) async {
    await _dbProvider.db.insert(
      'projects',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getByIdFromLocalDb(String id) async {
    final result = await _dbProvider.db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllProjectByUserIdFromLocalDb(
    String userId,
  ) async {
    return await _dbProvider.db.query(
      'projects',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> insertAllToLocalDb(List<Map<String, dynamic>> dataList) async {
    final db = _dbProvider.db;
    final batch = db.batch();

    for (final data in dataList) {
      batch.insert(
        'projects',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(
      noResult: true,
    ); // Set `noResult` to true for faster insert
  }

  Future<void> deleteFromLocalDb(String id) async {
    await _dbProvider.db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }
}

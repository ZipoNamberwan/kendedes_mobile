import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class ProjectDbProvider {
  static final ProjectDbProvider _instance = ProjectDbProvider._internal();
  factory ProjectDbProvider() => _instance;

  ProjectDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  // Local Database Operations
  Future<void> insert(Map<String, dynamic> data) async {
    await _dbProvider.db.insert(
      'projects',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final result = await _dbProvider.db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllProjectByUser(String userId) async {
    return await _dbProvider.db.query(
      'projects',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> insertAll(List<Map<String, dynamic>> dataList) async {
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

  Future<void> delete(String id) async {
    await _dbProvider.db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  /// Count tags by sync status grouped by project ID
  /// Returns a map with project_id as key and another map containing sync counts
  /// Example: {'project1': {'synced': 5, 'unsynced': 3}, 'project2': {'synced': 2, 'unsynced': 1}}
  Future<Map<String, Map<String, int>>>
  getTagCountsByProjectAndSyncStatus() async {
    final result = await _dbProvider.db.rawQuery('''
      SELECT 
        project_id,
        has_sent_to_server,
        COUNT(*) as count
      FROM tag_data 
      WHERE is_deleted = 0 OR is_deleted IS NULL
      GROUP BY project_id, has_sent_to_server
    ''');

    final Map<String, Map<String, int>> projectCounts = {};

    for (final row in result) {
      final projectId = row['project_id'] as String;
      final hasSentToServer = (row['has_sent_to_server'] as int) == 1;
      final count = row['count'] as int;

      // Initialize project map if it doesn't exist
      if (!projectCounts.containsKey(projectId)) {
        projectCounts[projectId] = {'synced': 0, 'unsynced': 0};
      }

      // Update the appropriate count
      if (hasSentToServer) {
        projectCounts[projectId]!['synced'] = count;
      } else {
        projectCounts[projectId]!['unsynced'] = count;
      }
    }

    return projectCounts;
  }
}

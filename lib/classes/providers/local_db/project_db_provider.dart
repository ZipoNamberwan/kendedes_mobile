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

  Future<List<Map<String, dynamic>>> getAllProjectByUser(
    String userId,
  ) async {
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
}

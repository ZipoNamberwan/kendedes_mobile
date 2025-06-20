import 'package:kendedes_mobile/classes/providers/local_database_provider.dart';
import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:sqflite/sqflite.dart';

class TaggingProvider {
  static final TaggingProvider _instance = TaggingProvider._internal();
  factory TaggingProvider() => _instance;

  TaggingProvider._internal();

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

  Future<List<Map<String, dynamic>>> getTaggingInBox(
    double minLat,
    double minLng,
    double maxLat,
    double maxLng,
  ) async {
    final response = await _dioService.dio.get(
      '/business-in-box',
      queryParameters: {
        'min_lat': minLat,
        'min_lng': minLng,
        'max_lat': maxLat,
        'max_lng': maxLng,
      },
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> storeTagging(
    Map<String, dynamic> taggingData,
  ) async {
    final response = await _dioService.dio.post('/business', data: taggingData);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateTagging(
    String taggingId,
    Map<String, dynamic> taggingData,
  ) async {
    final response = await _dioService.dio.put(
      '/business/$taggingId',
      data: taggingData,
    );
    return response.data['data'];
  }

  Future<void> deleteTagging(String taggingId) async {
    await _dioService.dio.delete('/business/$taggingId');
  }

  Future<Map<String, dynamic>> deleteMultipleTags(List<String> ids) async {
    final response = await _dioService.dio.delete(
      '/business/delete-multiple',
      data: {'ids': ids},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> uploadMultipleTags(
    List<Map<String, dynamic>> taggingData,
  ) async {
    final response = await _dioService.dio.post(
      '/business/upload-multiple',
      data: {'tags': taggingData},
    );
    return response.data['data'];
  }

  // Local Database Operations
  /// Get all tag data by project ID
  Future<List<Map<String, dynamic>>> getAllByProjectId(String projectId) async {
    return await _dbProvider.db.query(
      'tag_data',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  /// Insert or update a single tag_data entry
  Future<void> insertOrUpdate(Map<String, dynamic> data) async {
    await _dbProvider.db.insert(
      'tag_data',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a tag_data entry by ID
  Future<void> deleteById(String id) async {
    await _dbProvider.db.delete('tag_data', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all tag_data entries by project ID
  Future<void> deleteAllByProjectId(String projectId) async {
    await _dbProvider.db.delete(
      'tag_data',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  /// Get a single tag_data entry by ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final result = await _dbProvider.db.query(
      'tag_data',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Modify a single column by ID
  Future<void> updateColumn(String id, String columnName, dynamic value) async {
    await _dbProvider.db.update(
      'tag_data',
      {columnName: value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertAllToLocalDb(List<Map<String, dynamic>> dataList) async {
    final db = _dbProvider.db;
    final batch = db.batch();

    for (final data in dataList) {
      batch.insert(
        'tag_data',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(', ');
    await _dbProvider.db.delete(
      'tag_data',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<Map<String, int>> countSentAndUnsentByProjectId(
    String projectId,
  ) async {
    final db = _dbProvider.db;

    // Count sent
    final sentResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count FROM tag_data 
    WHERE project_id = ? AND has_sent_to_server = 1
  ''',
      [projectId],
    );

    // Count unsent
    final unsentResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count FROM tag_data 
    WHERE project_id = ? AND has_sent_to_server = 0
  ''',
      [projectId],
    );

    return {
      'sent': Sqflite.firstIntValue(sentResult) ?? 0,
      'unsent': Sqflite.firstIntValue(unsentResult) ?? 0,
    };
  }
}

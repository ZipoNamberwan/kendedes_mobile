import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:kendedes_mobile/classes/services/shared_preference_service.dart';
import 'package:sqflite/sqflite.dart';

class InfoDbProvider {
  static final InfoDbProvider _instance = InfoDbProvider._internal();
  factory InfoDbProvider() => _instance;

  InfoDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;
  late SharedPreferenceService _sharedPreferenceService;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
    _sharedPreferenceService = SharedPreferenceService();
    await _sharedPreferenceService.init();
  }

  // ==================== INFOS CRUD ====================

  /// Bulk-insert or replace a list of info maps into the [infos] table.
  /// Each map must already be in DB column format (snake_case keys, booleans as int).
  /// Returns the number of rows successfully written.
  Future<int> saveInfoList(List<Map<String, dynamic>> infoList) async {
    int count = 0;
    await _dbProvider.db.transaction((txn) async {
      for (final info in infoList) {
        await txn.insert(
          'infos',
          info,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
    });
    return count;
  }

  /// Updates only the [need_update] column for the row with the given [id].
  /// Returns the number of rows affected (0 or 1).
  Future<int> updateNeedUpdate(String id, {required bool needUpdate}) async {
    return await _dbProvider.db.update(
      'infos',
      {'need_update': needUpdate ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Updates only the [content] column for the row with the given [id].
  /// Returns the number of rows affected (0 or 1).
  Future<int> saveContent(String id, String content) async {
    return await _dbProvider.db.update(
      'infos',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Updates only the [is_read] column for the row with the given [id].
  /// Returns the number of rows affected (0 or 1).
  Future<int> updateIsRead(String id, {required bool isRead}) async {
    return await _dbProvider.db.update(
      'infos',
      {'is_read': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all infos as raw maps.
  Future<List<Map<String, dynamic>>> getAllInfos() async {
    return await _dbProvider.db.query(
      'infos',
      where: 'is_published = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC',
    );
  }

  /// Get a single info by id as a raw map.
  Future<Map<String, dynamic>?> getInfoById(String id) async {
    final maps = await _dbProvider.db.query(
      'infos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  // ==================== SHARED PREFERENCES ====================

  /// Persists the last-check timestamp for infos (milliseconds since epoch).
  Future<void> saveLastCheckInfos(int millisecondsSinceEpoch) async {
    await _sharedPreferenceService.saveLastCheckInfos(millisecondsSinceEpoch);
  }

  /// Returns the last-check timestamp for infos (milliseconds since epoch),
  /// or null if it has never been saved.
  int? getLastCheckInfos() {
    return _sharedPreferenceService.getLastCheckInfos();
  }
}

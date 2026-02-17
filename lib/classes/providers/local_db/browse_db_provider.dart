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

  Future<bool> hasBrowseProject(String userId) async {
    final result = await _dbProvider.db.query(
      'projects',
      columns: ['id'],
      where: 'user_id = ? AND interaction_mode = ?',
      whereArgs: [userId, InteractionMode.browse.key],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getBrowseProject(String userId) async {
    final result = await _dbProvider.db.query(
      'projects',
      where: 'user_id = ? AND interaction_mode = ?',
      whereArgs: [userId, InteractionMode.browse.key],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }
}

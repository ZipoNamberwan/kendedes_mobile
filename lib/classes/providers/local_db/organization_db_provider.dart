import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class OrganizationDbProvider {
  static final OrganizationDbProvider _instance =
      OrganizationDbProvider._internal();
  factory OrganizationDbProvider() => _instance;

  OrganizationDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _dbProvider.db.insert(
      'organizations',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final result = await _dbProvider.db.query(
      'organizations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _dbProvider.db.query('organizations');
  }

  Future<void> delete(String id) async {
    await _dbProvider.db.delete(
      'organizations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

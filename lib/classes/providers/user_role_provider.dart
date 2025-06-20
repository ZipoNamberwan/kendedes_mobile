import 'package:kendedes_mobile/classes/providers/local_database_provider.dart';
import 'package:sqflite/sqflite.dart';

class UserRoleProvider {
  static final UserRoleProvider _instance = UserRoleProvider._internal();
  factory UserRoleProvider() => _instance;

  UserRoleProvider._internal();

  late LocalDatabaseProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDatabaseProvider();
    await _dbProvider.init();
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _dbProvider.db.insert(
      'user_roles',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final result = await _dbProvider.db.query(
      'user_roles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _dbProvider.db.query('user_roles');
  }

  Future<void> delete(String id) async {
    await _dbProvider.db.delete('user_roles', where: 'id = ?', whereArgs: [id]);
  }
}

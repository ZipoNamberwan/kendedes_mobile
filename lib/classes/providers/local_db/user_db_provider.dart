import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDbProvider {
  static final UserDbProvider _instance = UserDbProvider._internal();
  factory UserDbProvider() => _instance;

  UserDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  Future<void> insert(
    Map<String, dynamic> userData,
    List<Map<String, dynamic>> roleMaps,
  ) async {
    await _dbProvider.db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert role pivots
    for (final role in roleMaps) {
      await _dbProvider.db.insert('user_role_pivot', {
        'user_id': userData['id'],
        'role_id': role['id'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final result = await _dbProvider.db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _dbProvider.db.query('users');
  }

  Future<List<String>> getUserRoleIds(String userId) async {
    final result = await _dbProvider.db.query(
      'user_role_pivot',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => e['role_id'] as String).toList();
  }

  Future<void> delete(String id) async {
    await _dbProvider.db.delete(
      'user_role_pivot',
      where: 'user_id = ?',
      whereArgs: [id],
    );
    await _dbProvider.db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}

import 'package:kendedes_mobile/classes/providers/local_db/user_role_db_provider.dart';
import 'package:kendedes_mobile/models/user_role.dart';

class UserRoleDbRepository {
  static final UserRoleDbRepository _instance = UserRoleDbRepository._internal();
  factory UserRoleDbRepository() => _instance;

  UserRoleDbRepository._internal();

  late UserRoleDbProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = UserRoleDbProvider();
    await _provider.init();
  }

  Future<void> insert(UserRole role) async {
    await _provider.insert({'id': role.id, 'name': role.name});
  }

  Future<UserRole?> getById(String id) async {
    final map = await _provider.getById(id);
    if (map == null) return null;

    return UserRole(id: map['id'], name: map['name']);
  }

  Future<List<UserRole>> getAll() async {
    final maps = await _provider.getAll();
    return maps
        .map((map) => UserRole(id: map['id'], name: map['name']))
        .toList();
  }
}

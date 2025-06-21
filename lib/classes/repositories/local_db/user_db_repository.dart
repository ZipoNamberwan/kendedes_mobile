import 'package:kendedes_mobile/classes/providers/local_db/organization_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/user_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/user_role_db_provider.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:kendedes_mobile/models/user_role.dart';

class UserDbRepository {
  static final UserDbRepository _instance = UserDbRepository._internal();
  factory UserDbRepository() => _instance;

  UserDbRepository._internal();

  late UserDbProvider _provider;
  late OrganizationDbProvider _orgProvider;
  late UserRoleDbProvider _roleProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = UserDbProvider();
    await _provider.init();
    _orgProvider = OrganizationDbProvider();
    await _orgProvider.init();
    _roleProvider = UserRoleDbProvider();
    await _roleProvider.init();
  }

  Future<void> insert(User user) async {
    // 1. Insert organization (if exists)
    if (user.organization != null) {
      await _orgProvider.insert({
        'id': user.organization!.id,
        'short_code': user.organization!.shortCode,
        'long_code': user.organization!.longCode,
        'name': user.organization!.name,
      });
    }

    // 2. Insert roles
    final roleMaps = <Map<String, dynamic>>[];
    for (final role in user.roles) {
      final roleMap = {'id': role.id, 'name': role.name};
      roleMaps.add(roleMap);
      await _roleProvider.insert(roleMap);
    }

    // 3. Insert user
    final userMap = {
      'id': user.id,
      'email': user.email,
      'firstname': user.firstname,
      'organization_id': user.organization?.id,
    };

    await _provider.insert(userMap, roleMaps);
  }

  Future<User?> getById(String id) async {
    final userMap = await _provider.getById(id);
    if (userMap == null) return null;

    final roleIds = await _provider.getUserRoleIds(id);
    final roles = <UserRole>[];
    for (final roleId in roleIds) {
      final roleMap = await _roleProvider.getById(roleId);
      if (roleMap != null) {
        roles.add(UserRole(id: roleMap['id'], name: roleMap['name']));
      }
    }

    Organization? org;
    if (userMap['organization_id'] != null) {
      final orgMap = await _orgProvider.getById(userMap['organization_id']);
      if (orgMap != null) {
        org = Organization(
          id: orgMap['id'],
          shortCode: orgMap['short_code'],
          longCode: orgMap['long_code'],
          name: orgMap['name'],
        );
      }
    }

    return User(
      id: userMap['id'],
      email: userMap['email'],
      firstname: userMap['firstname'],
      organization: org,
      roles: roles,
    );
  }
}

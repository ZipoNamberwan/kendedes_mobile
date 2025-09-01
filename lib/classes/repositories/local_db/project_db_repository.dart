import 'package:kendedes_mobile/classes/providers/local_db/organization_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/project_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/user_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/user_role_db_provider.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:kendedes_mobile/models/user_role.dart';

class ProjectDbRepository {
  static final ProjectDbRepository _instance = ProjectDbRepository._internal();
  factory ProjectDbRepository() => _instance;

  ProjectDbRepository._internal();

  late ProjectDbProvider _projectDbProvider;
  late UserDbProvider _userDbProvider;
  late OrganizationDbProvider _orgProvider;
  late UserRoleDbProvider _roleProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _projectDbProvider = ProjectDbProvider();
    await _projectDbProvider.init();
    _userDbProvider = UserDbProvider();
    await _userDbProvider.init();
    _orgProvider = OrganizationDbProvider();
    await _orgProvider.init();
    _roleProvider = UserRoleDbProvider();
    await _roleProvider.init();
  }

  Future<void> insert(Project project) async {
    // // 1. Insert organization (if exists)
    // if (project.user?.organization != null) {
    //   final org = project.user!.organization!;
    //   await _orgProvider.insert({
    //     'id': org.id,
    //     'short_code': org.shortCode,
    //     'long_code': org.longCode,
    //     'name': org.name,
    //   });
    // }

    // // 2. Insert user roles (if any)
    // final roleMaps = <Map<String, dynamic>>[];
    // if (project.user?.roles != null) {
    //   for (final role in project.user!.roles) {
    //     final roleMap = {'id': role.id, 'name': role.name};
    //     roleMaps.add(roleMap);
    //     await _roleProvider.insert(roleMap);
    //   }
    // }

    // // 3. Insert user
    // if (project.user != null) {
    //   final user = project.user!;
    //   final userMap = {
    //     'id': user.id,
    //     'email': user.email,
    //     'firstname': user.firstname,
    //     'organization_id': user.organization?.id,
    //   };
    //   await _userDbProvider.insert(userMap, roleMaps);
    // }

    // 4. Insert project
    final map = {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': project.updatedAt.toIso8601String(),
      'deleted_at': project.deletedAt?.toIso8601String(),
      'type': project.type.key,
      'user_id': project.user?.id,
    };

    await _projectDbProvider.insert(map);
  }

  Future<Project?> getById(String id) async {
    final map = await _projectDbProvider.getById(id);
    if (map == null) return null;

    User? user;
    if (map['user_id'] != null) {
      final userMap = await _userDbProvider.getById(map['user_id']);
      if (userMap != null) {
        // Get organization (if any)
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

        // Get roles
        final roleIds = await _userDbProvider.getUserRoleIds(userMap['id']);
        final roles = <UserRole>[];
        for (final roleId in roleIds) {
          final roleMap = await _roleProvider.getById(roleId);
          if (roleMap != null) {
            roles.add(UserRole(id: roleMap['id'], name: roleMap['name']));
          }
        }

        user = User(
          id: userMap['id'],
          email: userMap['email'],
          firstname: userMap['firstname'],
          organization: org,
          roles: roles,
        );
      }
    }

    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      type: ProjectType.values.firstWhere((e) => e.key == map['type']),
      user: user,
    );
  }

  Future<List<Project>> getAllProjectByUser(String userId) async {
    final maps = await _projectDbProvider.getAllProjectByUser(userId);
    final ids = maps.map((map) => map['id'] as String).toList();

    final List<Project> projects = [];

    for (final id in ids) {
      final project = await getById(id);
      if (project != null) {
        projects.add(project);
      }
    }

    return projects;
  }

  Future<void> insertAll(List<Project> projects) async {
    final dataList =
        projects.map((project) {
          return {
            'id': project.id,
            'name': project.name,
            'description': project.description,
            'created_at': project.createdAt.toIso8601String(),
            'updated_at': project.updatedAt.toIso8601String(),
            'deleted_at': project.deletedAt?.toIso8601String(),
            'type': project.type.key,
            'user_id': project.user?.id,
          };
        }).toList();

    await _projectDbProvider.insertAll(dataList);
  }

  Future<void> delete(String id) async {
    await _projectDbProvider.delete(id);
  }

  Future<Map<String, Map<String, int>>>
  getTagCountsByProjectAndSyncStatus() async {
    return await _projectDbProvider.getTagCountsByProjectAndSyncStatus();
  }
}

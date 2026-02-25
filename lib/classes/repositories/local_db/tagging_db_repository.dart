import 'package:kendedes_mobile/classes/providers/local_db/organization_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/project_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/tagging_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/user_db_provider.dart';
import 'package:kendedes_mobile/classes/providers/local_db/user_role_db_provider.dart';
import 'package:kendedes_mobile/models/interaction_mode.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:kendedes_mobile/models/user_role.dart';

class TaggingDbRepository {
  static final TaggingDbRepository _instance = TaggingDbRepository._internal();
  factory TaggingDbRepository() => _instance;

  TaggingDbRepository._internal();

  late TaggingDbProvider _taggingDbProvider;
  late ProjectDbProvider _projectDbProvider;
  late UserDbProvider _userDbProvider;
  late OrganizationDbProvider _orgProvider;
  late UserRoleDbProvider _roleProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _taggingDbProvider = TaggingDbProvider();
    await _taggingDbProvider.init();
    _projectDbProvider = ProjectDbProvider();
    await _projectDbProvider.init();
    _userDbProvider = UserDbProvider();
    await _userDbProvider.init();
    _orgProvider = OrganizationDbProvider();
    await _orgProvider.init();
    _roleProvider = UserRoleDbProvider();
    await _roleProvider.init();
  }

  // Local Database Operations
  /// Get all tag data by project ID
  Future<List<TagData>> getAllByProjectId(String projectId) async {
    final maps = await _taggingDbProvider.getAllByProjectId(projectId);
    if (maps.isEmpty) return [];

    // Preload project and user once
    final preloadedProject = await _hydrateProject(projectId);

    // If all tags are done by same user (optional optimization)
    final userId = maps.first['user_id'];
    final preloadedUser = await _hydrateUser(userId);

    final List<TagData> tags = [];

    for (final map in maps) {
      final tag = await getById(
        map['id'],
        preloadedProject: preloadedProject,
        preloadedUser: preloadedUser,
      );
      if (tag != null) tags.add(tag);
    }

    return tags;
  }

  /// Insert or update a TagData
  Future<void> insertOrUpdate(TagData tag) async {
    await _taggingDbProvider.insertOrUpdate(tag.toLocalDbJson());
  }

  /// Delete by ID
  Future<void> deleteById(String id) async {
    await _taggingDbProvider.deleteById(id);
  }

  /// Delete all by project ID
  Future<void> deleteAllByProjectId(String projectId) async {
    await _taggingDbProvider.deleteAllByProjectId(projectId);
  }

  Future<Project?> _hydrateProject(String projectId) async {
    final map = await _projectDbProvider.getById(projectId);
    if (map == null) return null;

    final user = await _hydrateUser(map['user_id']);

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
      interactionMode: InteractionMode.tag,
    );
  }

  Future<User?> _hydrateUser(String? userId) async {
    if (userId == null) return null;

    final map = await _userDbProvider.getById(userId);
    if (map == null) return null;

    Organization? org;
    if (map['organization_id'] != null) {
      final orgMap = await _orgProvider.getById(map['organization_id']);
      if (orgMap != null) {
        org = Organization(
          id: orgMap['id'],
          shortCode: orgMap['short_code'],
          longCode: orgMap['long_code'],
          name: orgMap['name'],
        );
      }
    }

    final roleIds = await _userDbProvider.getUserRoleIds(map['id']);
    final roles = <UserRole>[];
    for (final roleId in roleIds) {
      final roleMap = await _roleProvider.getById(roleId);
      if (roleMap != null) {
        roles.add(UserRole(id: roleMap['id'], name: roleMap['name']));
      }
    }

    return User(
      id: map['id'],
      email: map['email'],
      firstname: map['firstname'],
      organization: org,
      roles: roles,
    );
  }

  /// Get tag data by ID
  Future<TagData?> getById(
    String id, {
    Project? preloadedProject,
    User? preloadedUser,
  }) async {
    final map = await _taggingDbProvider.getById(id);
    if (map == null) return null;

    // Use preloaded project or hydrate it
    final project =
        preloadedProject ??
        await _hydrateProject(
          map['project_id'],
        ); // We'll extract this logic below
    if (project == null) return null;

    // Use preloaded user or hydrate it
    final user = preloadedUser ?? await _hydrateUser(map['user_id']);

    return TagData.fromLocalDbJson(map, user, project);
  }

  /// Update a single column
  Future<void> updateColumn(String id, String columnName, dynamic value) async {
    await _taggingDbProvider.updateColumn(id, columnName, value);
  }

  Future<void> insertAll(List<TagData> tagList) async {
    final dataList =
        tagList.map((tag) {
          return tag.toLocalDbJson();
        }).toList();

    await _taggingDbProvider.insertAll(dataList);
  }

  Future<void> deleteByIds(List<String> ids) async {
    await _taggingDbProvider.deleteByIds(ids);
  }

  Future<Map<String, int>> countSentAndUnsentByProjectId(
    String projectId,
  ) async {
    return await _taggingDbProvider.countSentAndUnsentByProjectId(projectId);
  }

  bool? hasCheckLockedTags(String projectId) {
    return _taggingDbProvider.hasCheckLockedTags(projectId);
  }

  Future<void> saveCheckLockedTags(String projectId) async {
    await _taggingDbProvider.saveCheckLockedTags(projectId);
  }
}

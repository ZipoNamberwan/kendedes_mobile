import 'package:kendedes_mobile/classes/providers/local_db/browse_db_provider.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_db_repository.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:uuid/uuid.dart';

class BrowseDbRepository {
  static final BrowseDbRepository _instance = BrowseDbRepository._internal();
  factory BrowseDbRepository() => _instance;

  BrowseDbRepository._internal();

  late BrowseDbProvider _browseDbProvider;
  late UserDbRepository _userDbRepository;
  bool _initialized = false;
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _browseDbProvider = BrowseDbProvider();
    await _browseDbProvider.init();

    _userDbRepository = UserDbRepository();
    await _userDbRepository.init();
  }

  Future<List<Project>> getProjectsByUser(String userId) async {
    final user = await _userDbRepository.getById(userId);
    final userJson = user?.toJson();

    final maps = await _browseDbProvider.getProjectsByUser(userId);
    return maps.map((map) {
      final mutableMap = Map<String, dynamic>.from(map);
      if (userJson != null) {
        mutableMap['user'] = userJson;
      }
      return Project.fromLocalDbJson(mutableMap);
    }).toList();
  }

  // sls_with_business CRUD
  Future<bool> createSlsWithBusiness(SlsWithBusiness item) async {
    final existingSlsWithBusinessList = await getSlsWithBusinessList(
      userId: item.user.id,
    );

    final pairExists = existingSlsWithBusinessList.any(
      (existing) => existing.sls.id == item.sls.id,
    );
    if (!pairExists) {
      await _browseDbProvider.createSlsWithBusiness(item.toJson());
    }
    return !pairExists;
  }

  Future<void> updateSlsWithBusiness(SlsWithBusiness item) async {
    final data = Map<String, dynamic>.from(item.toJson());
    data.remove('id');
    data.removeWhere((key, value) => value == null);

    await _browseDbProvider.updateSlsWithBusiness(item.id, data);
  }

  Future<void> deleteSlsWithBusiness(String id) async {
    await _browseDbProvider.deleteSlsWithBusiness(id);
  }

  Future<List<SlsWithBusiness>> getSlsWithBusinessList({
    required String userId,
  }) async {
    final rows = await _browseDbProvider.getSlsWithBusinessList(userId: userId);

    final user = await _userDbRepository.getById(userId);
    if (user == null) {
      throw StateError('User not found for userId=$userId');
    }

    final List<SlsWithBusiness> items = [];

    for (final row in rows) {
      final json = Map<String, dynamic>.from(row);
      json['user'] = user.toJson();

      items.add(SlsWithBusiness.fromJson(json));
    }

    return items;
  }

  Future<void> insertBusinessesDataBatch(
    List<TagData> businesses,
    String userId, {
    int chunkSize = 500,
  }) async {
    if (businesses.isEmpty) return;

    final existingProjects = await getProjectsByUser(userId);
    final existingProjectsByRemoteId = {
      for (final project in existingProjects) project.remoteId: project,
    };
    final existingBusiness =
        existingProjects.isEmpty
            ? <TagData>[]
            : await getBusinessByBrowseProjects(
              existingProjects.map((project) => project.id).toList(),
            );
    final existingBusinessRemoteIds =
        existingBusiness
            .map((business) => business.remoteId)
            .where((remoteId) => remoteId.isNotEmpty)
            .toSet();

    for (int i = 0; i < businesses.length; i += chunkSize) {
      final chunk = businesses.sublist(
        i,
        i + chunkSize > businesses.length ? businesses.length : i + chunkSize,
      );

      final newBusinesses =
          chunk.where((business) {
            if (existingBusinessRemoteIds.contains(business.remoteId)) {
              return false;
            }

            existingBusinessRemoteIds.add(business.remoteId);
            return true;
          }).toList();

      if (newBusinesses.isEmpty) {
        continue;
      }

      final mappedChunk =
          newBusinesses.map((business) {
            final businessJson = Map<String, dynamic>.from(business.toLocalDbJson());

            // Find existing project that matches business's project_id with remote_id
            final matchingProject =
                existingProjectsByRemoteId[businessJson['project_id']];
            if (matchingProject == null) {
              throw StateError(
                'Project not found for remote_id=${businessJson['project_id']}',
              );
            }
            // Replace project_id with existing project's local id
            businessJson['project_id'] = matchingProject.id;

            return businessJson;
          }).toList();

      await _browseDbProvider.insertBusinessesDataBatch(mappedChunk);
    }
  }

  Future<void> insertProjectBatch(List<Project> projects) async {
    final dataList =
        projects.map((project) {
          return project.toLocalDbJson();
        }).toList();

    await _browseDbProvider.insertProjectsBatch(dataList);
  }

  Future<void> insertUniqueProjects(
    List<Project> projects,
    String userId,
  ) async {
    final existingProjects = await getProjectsByUser(userId);
    final existingRemoteIds =
        existingProjects.map((project) => project.remoteId).toSet();

    final newProjects =
        projects
            .map(
              (project) =>
                  project.copyWith(id: _uuid.v4(), remoteId: project.remoteId),
            )
            .where((project) => !existingRemoteIds.contains(project.remoteId))
            .toList();

    if (newProjects.isNotEmpty) {
      await insertProjectBatch(newProjects);
    }
  }

  Future<List<Project>> getAllProjects() async {
    final maps = await _browseDbProvider.getAllProjects();
    return maps.map((map) {
      return Project.fromLocalDbJson(map);
    }).toList();
  }

  Future<List<User>> getAllUsers() async {
    final maps = await _browseDbProvider.getAllUsers();
    return maps.map((map) {
      return User.fromJson(map);
    }).toList();
  }

  // insert user by calling browseDbProvider.insertUsersBatch
  Future<void> insertUsersBatch(List<User> users, {int chunkSize = 500}) async {
    // add chunking to avoid inserting too many records at once
    for (int i = 0; i < users.length; i += chunkSize) {
      final chunk = users.sublist(
        i,
        i + chunkSize > users.length ? users.length : i + chunkSize,
      );

      final mappedChunk =
          chunk.map((user) {
            return {
              'id': user.id,
              'firstname': user.firstname,
              'email': user.email,
            };
          }).toList();

      await _browseDbProvider.insertUsersBatch(mappedChunk);
    }
  }

  Future<void> insertUniqueUsers(List<User> users) async {
    final existingUsers = await getAllUsers();

    final newUsers =
        users
            .where(
              (user) =>
                  !existingUsers.any((existing) => existing.id == user.id),
            )
            .toList();
    if (newUsers.isNotEmpty) {
      await insertUsersBatch(newUsers.map((user) => user).toList());
    }
  }

  Future<List<TagData>> getBusinessByBrowseProjects(
    List<String> projectIds,
  ) async {
    final businessMaps = await _browseDbProvider.getBusinessByBrowseProjects(
      projectIds,
    );

    final projectMaps = await _browseDbProvider.getAllProjects();
    final userMaps = await _browseDbProvider.getAllUsers();

    // return list of business data with business details
    return businessMaps.map((map) {
      final projectMap = projectMaps.firstWhere(
        (p) => p['id'] == map['project_id'],
        orElse: () => {},
      );

      final userMap = userMaps.firstWhere(
        (u) => u['id'] == map['user_id'],
        orElse: () => {},
      );

      final business = TagData.fromLocalDbJson(
        map,
        User.fromJson(userMap),
        Project.fromLocalDbJson(projectMap),
      );
      return business;
    }).toList();
  }
}

import 'package:kendedes_mobile/classes/providers/local_db/browse_db_provider.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/polygon_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_db_repository.dart';
import 'package:kendedes_mobile/models/interaction_mode.dart';
import 'package:kendedes_mobile/models/polygon.dart';
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
  late PolygonDbRepository _polygonDbRepository;

  bool _initialized = false;
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _browseDbProvider = BrowseDbProvider();
    await _browseDbProvider.init();

    _userDbRepository = UserDbRepository();
    await _userDbRepository.init();

    _polygonDbRepository = PolygonDbRepository();
    await _polygonDbRepository.init();
  }

  Future<List<Project>> getProjectsByUser(String currentUserId) async {
    final user = await _userDbRepository.getById(currentUserId);
    final userJson = user?.toJson();

    final maps = await _browseDbProvider.getProjectsByUser(currentUserId);
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
      currentUserId: item.user.id,
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
    required String currentUserId,
  }) async {
    final rows = await _browseDbProvider.getSlsWithBusinessList(
      currentUserId: currentUserId,
    );

    final polygons = await _polygonDbRepository.getPolygonsByUser(
      currentUserId,
    );

    final currentUser = await _userDbRepository.getById(currentUserId);
    if (currentUser == null) {
      throw StateError('User not found for current user id=$currentUserId');
    }

    final List<SlsWithBusiness> items = [];

    for (final row in rows) {
      final json = Map<String, dynamic>.from(row);
      json['user'] = currentUser.toJson();
      final polygon = polygons.cast<Polygon?>().firstWhere(
        (polygon) => polygon?.id == json['sls_id'],
        orElse: () => null,
      );
      items.add(SlsWithBusiness.fromJson(json, polygon));
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
            : await getBusinessesByBrowseProjects(
              existingProjects.map((project) => project.id).toList(),
              userId,
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
            final businessJson = Map<String, dynamic>.from(
              business.toLocalDbJson(),
            );

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

  Future<void> insertUniqueProjectsFromBusinesses(
    List<TagData> businesses,
    User? currentUser,
  ) async {
    List<Project> uniqueProjects =
        {
          for (var business in businesses)
            business.project.remoteId: business.project.copyWith(
              user: currentUser,
              interactionMode: InteractionMode.browse,
            ),
        }.values.toList();

    final existingProjects = await getProjectsByUser(currentUser?.id ?? '');
    final existingRemoteIds =
        existingProjects.map((project) => project.remoteId).toSet();

    final newProjects =
        uniqueProjects
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

  Future<void> insertUniqueUsersFromBusinesses(List<TagData> businesses) async {
    final uniqueUsers =
        {
          for (var business in businesses)
            if (business.user != null) business.user!.id: business.user!,
        }.values.toList();
    final existingUsers = await getAllUsers();

    final newUsers =
        uniqueUsers
            .where(
              (user) =>
                  !existingUsers.any((existing) => existing.id == user.id),
            )
            .toList();
    if (newUsers.isNotEmpty) {
      await insertUsersBatch(newUsers.map((user) => user).toList());
    }
  }

  Future<List<TagData>> getBusinessesByBrowseProjects(
    List<String> projectIds,
    String userId,
  ) async {
    final businessMaps = await _browseDbProvider.getBusinessesByBrowseProjects(
      projectIds,
    );

    final existingProjects = await getProjectsByUser(userId);
    final existingUsers = await getAllUsers();

    // return list of business data with business details
    return businessMaps.map((map) {
      final project = existingProjects.firstWhere(
        (p) => p.id == map['project_id'],
      );

      final user = existingUsers.firstWhere((u) => u.id == map['user_id']);

      final business = TagData.fromLocalDbJson(map, user, project);
      return business;
    }).toList();
  }

  Future<List<TagData>> getBusinessesBySls(String slsId, String userId) async {
    final existingProjects = await getProjectsByUser(userId);
    final projectIds = existingProjects.map((p) => p.id).toList();

    final businessMaps = await _browseDbProvider.getBusinessesBySls(
      slsId,
      projectIds,
    );
    final existingUsers = await getAllUsers();

    // return list of business data with business details
    return businessMaps.map((map) {
      final project = existingProjects.firstWhere(
        (p) => p.id == map['project_id'],
      );

      final user = existingUsers.firstWhere((u) => u.id == map['user_id']);

      final business = TagData.fromLocalDbJson(map, user, project);
      return business;
    }).toList();
  }

  Future<bool> deleteBusinessesBySlsId(String slsId, String userId) async {
    final existingProjects = await getProjectsByUser(userId);
    final projectIds = existingProjects.map((p) => p.id).toList();
    
    return await _browseDbProvider.deleteBusinessesBySlsId(slsId, projectIds);
  }

  Future<int?> getSlsWithBusinessCountBySlsId(
    String slsId,
    String userId,
  ) async {
    return _browseDbProvider.getSlsWithBusinessCountBySlsId(slsId, userId);
  }

  Future<int?> getBusinessCountBySlsId(
    String slsId,
    List<String> projectIds,
  ) async {
    return _browseDbProvider.getBusinessCountBySlsId(slsId, projectIds);
  }

  Future<bool> hasPolygonBySlsId(String slsId, String userId) async {
    return _browseDbProvider.hasPolygonBySlsId(slsId, userId);
  }

  Future<bool> needToDownloadBusinessFromServer(
    String slsId,
    String userId,
  ) async {
    final slsWithBusinessCount = await getSlsWithBusinessCountBySlsId(
      slsId,
      userId,
    );
    if (slsWithBusinessCount == null) {
      return true;
    }

    List<String> projectIds =
        (await getProjectsByUser(userId)).map((p) => p.id).toList();
    final businessCount = await getBusinessCountBySlsId(slsId, projectIds);
    if (businessCount == null) {
      return true;
    }

    if (slsWithBusinessCount != businessCount) {
      return true;
    }

    final hasPolygon = await hasPolygonBySlsId(slsId, userId);
    return !hasPolygon;
  }
}

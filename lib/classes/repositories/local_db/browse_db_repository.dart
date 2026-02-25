import 'package:kendedes_mobile/classes/providers/local_db/browse_db_provider.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_db_repository.dart';
import 'package:kendedes_mobile/models/interaction_mode.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';

class BrowseDbRepository {
  static final BrowseDbRepository _instance = BrowseDbRepository._internal();
  factory BrowseDbRepository() => _instance;

  BrowseDbRepository._internal();

  late BrowseDbProvider _browseDbProvider;
  late UserDbRepository _userDbRepository;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _browseDbProvider = BrowseDbProvider();
    await _browseDbProvider.init();

    _userDbRepository = UserDbRepository();
    await _userDbRepository.init();
  }

  Future<bool> hasBrowseProject(String userId) async {
    return await _browseDbProvider.hasBrowseProject(userId);
  }

  Future<void> saveBrowseProject({
    required String projectId,
    required String userId,
    String name = 'Browse Mode',
    String? description,
  }) async {
    final now = DateTime.now();

    await _browseDbProvider.insertBrowseProject({
      'id': projectId,
      'name': name,
      'description': description,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
      'type': ProjectType.browse.key,
      'user_id': userId,
      'interaction_mode': InteractionMode.browse.key,
    });
  }

  Future<Project?> getBrowseProject(String userId) async {
    final map = await _browseDbProvider.getBrowseProject(userId);
    if (map == null) return null;

    return Project(
      id: map['id'],
      remoteId: map['remote_id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      type: ProjectType.browse,
      user: null,
      interactionMode: InteractionMode.browse,
    );
  }

  // sls_with_business CRUD
  Future<void> createSlsWithBusiness(SlsWithBusiness item) async {
    await _browseDbProvider.createSlsWithBusiness(item.toJson());
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

  Future<void> insertTagDataBatch(
    String? browseProjectId,
    List<TagData> tags, {
    int chunkSize = 500,
  }) async {
    for (int i = 0; i < tags.length; i += chunkSize) {
      final chunk = tags.sublist(
        i,
        i + chunkSize > tags.length ? tags.length : i + chunkSize,
      );

      final mappedChunk =
          chunk.map((tag) {
            return {
              'id': tag.id,
              'position_lat': tag.positionLat,
              'position_lng': tag.positionLng,
              'has_changed': tag.hasChanged ? 1 : 0,
              'has_sent_to_server': tag.hasSentToServer ? 1 : 0,
              'tag_type': tag.type.name,
              'initial_position_lat': tag.initialPositionLat,
              'initial_position_lng': tag.initialPositionLng,
              'is_deleted': tag.isDeleted ? 1 : 0,
              'created_at': tag.createdAt?.toIso8601String(),
              'updated_at': tag.updatedAt?.toIso8601String(),
              'deleted_at': tag.deletedAt?.toIso8601String(),
              'incremental_id': tag.incrementalId,
              'project_id': tag.project.id,
              'business_name': tag.businessName,
              'business_owner': tag.businessOwner,
              'business_address': tag.businessAddress,
              'building_status': tag.buildingStatus?.key,
              'description': tag.description,
              'sector': tag.sector?.key,
              'note': tag.note,
              'user_id': tag.user?.id,
              'is_locked': tag.isLocked ? 1 : 0,
            };
          }).toList();

      await _browseDbProvider.insertTagDataBatch(mappedChunk);
    }
  }

  Future<void> insertProjectBatch(List<Project> projects) async {
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

    await _browseDbProvider.insertProjectsBatch(dataList);
  }

  Future<List<Project>> getAllProjects() async {
    final maps = await _browseDbProvider.getAllProjects();
    return maps.map((map) {
      return Project.fromServerJson(map);
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

  Future<List<TagData>> getBusinessByBrowseProjectId(String projectId) async {
    final businessMaps = await _browseDbProvider.getBusinessByBrowseProjectId(
      projectId,
    );

    final projectMaps = await _browseDbProvider.getAllProjects();
    final userMaps = await _browseDbProvider.getAllUsers();

    // return list of tag data with business details
    return businessMaps.map((map) {
      final projectMap = projectMaps.firstWhere(
        (p) => p['id'] == map['project_id'],
        orElse: () => {},
      );

      final userMap = userMaps.firstWhere(
        (u) => u['id'] == map['user_id'],
        orElse: () => {},
      );

      final tag = TagData(
        id: map['id'] as String,
        remoteId: map['id'] as String,
        positionLat: map['position_lat'],
        positionLng: map['position_lng'],
        hasChanged: false,
        hasSentToServer: true,
        isLocked: map['is_locked'] == 1,
        type: TagType.auto,
        initialPositionLat: map['position_lat'],
        initialPositionLng: map['position_lng'],
        isDeleted: map['deleted_at'] != null,
        createdAt:
            map['created_at'] != null
                ? DateTime.parse(map['created_at'] as String)
                : null,
        updatedAt:
            map['updated_at'] != null
                ? DateTime.parse(map['updated_at'] as String)
                : null,
        deletedAt:
            map['deleted_at'] != null
                ? DateTime.parse(map['deleted_at'] as String)
                : null,
        incrementalId: 1,
        project: Project.fromServerJson(projectMap),
        businessName: map['business_name'] as String,
        businessOwner: map['business_owner'] as String?,
        businessAddress: map['business_address'] as String?,
        buildingStatus:
            map['building_status'] != null
                ? BuildingStatus.fromKey(
                  map['building_status'].toString().toLowerCase().replaceAll(
                    ' ',
                    '_',
                  ),
                )
                : null,
        description: map['description'] as String,
        sector:
            (() {
              final sectorStr = map['sector']?.toString();
              return sectorStr != null && sectorStr.isNotEmpty
                  ? Sector.fromKey(sectorStr[0].toUpperCase())
                  : null;
            })(),
        note: map['note'] as String?,
        user: userMap.isNotEmpty ? User.fromJson(userMap) : null,
      );
      return tag;
    }).toList();
  }
}

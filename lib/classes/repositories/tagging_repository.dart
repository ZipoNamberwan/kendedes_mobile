import 'package:kendedes_mobile/classes/providers/project_povider.dart';
import 'package:kendedes_mobile/classes/providers/tagging_provider.dart';
import 'package:kendedes_mobile/classes/providers/user_provider.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';

class TaggingRepository {
  static final TaggingRepository _instance = TaggingRepository._internal();
  factory TaggingRepository() => _instance;

  TaggingRepository._internal();

  late TaggingProvider _taggingProvider;
  late ProjectProvider _projectProvider;
  late UserProvider _userProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _taggingProvider = TaggingProvider();
    await _taggingProvider.init();
    _projectProvider = ProjectProvider();
    await _projectProvider.init();
    _userProvider = UserProvider();
    await _userProvider.init();
  }

  Future<List<TagData>> getTaggingInBox({
    required double minLat,
    required double minLng,
    required double maxLat,
    required double maxLng,
  }) async {
    final response = await _taggingProvider.getTaggingInBox(
      minLat,
      minLng,
      maxLat,
      maxLng,
    );
    return response.map((data) => TagData.fromJson(data)).toList();
  }

  Future<TagData> storeTagging(TagData tagData) async {
    final response = await _taggingProvider.storeTagging(tagData.toJson());
    return TagData.fromJson(response);
  }

  Future<TagData> updateTagging(TagData tagData) async {
    final response = await _taggingProvider.updateTagging(
      tagData.id,
      tagData.toJson(),
    );
    return TagData.fromJson(response);
  }

  Future<void> deleteTagging(String taggingId) async {
    await _taggingProvider.deleteTagging(taggingId);
  }

  Future<bool> deleteMultipleTags(List<String> ids) async {
    final response = await _taggingProvider.deleteMultipleTags(ids);
    return response['success'];
  }

  Future<List<String>> uploadMultipleTags(List<TagData> tags) async {
    final List<Map<String, dynamic>> tagJsonList =
        tags.map((tag) => tag.toJson()).toList();
    final response = await _taggingProvider.uploadMultipleTags(tagJsonList);
    return List<String>.from(response['uploaded_ids']);
  }

  // Local Database Operations
  /// Get all tag data by project ID
  Future<List<TagData>> getAllByProjectId(String projectId) async {
    final maps = await _taggingProvider.getAllByProjectId(projectId);

    final ids = maps.map((map) => map['id'] as String).toList();

    final List<TagData> tags = [];

    for (final id in ids) {
      final tag = await getById(id);
      if (tag != null) {
        tags.add(tag);
      }
    }

    return tags;
  }

  /// Insert or update a TagData
  Future<void> insertOrUpdate(TagData tag) async {
    await _taggingProvider.insertOrUpdate({
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
      'building_status': tag.buildingStatus.key,
      'description': tag.description,
      'sector': tag.sector.key,
      'note': tag.note,
      'user_id': tag.user.id,
    });
  }

  /// Delete by ID
  Future<void> deleteById(String id) async {
    await _taggingProvider.deleteById(id);
  }

  /// Delete all by project ID
  Future<void> deleteAllByProjectId(String projectId) async {
    await _taggingProvider.deleteAllByProjectId(projectId);
  }

  /// Get tag data by ID
  Future<TagData?> getById(String id) async {
    final map = await _taggingProvider.getById(id);
    if (map == null) return null;

    final projectMap = await _projectProvider.getByIdFromLocalDb(
      map['project_id'],
    );
    if (projectMap == null) return null;
    final userMap =
        map['user_id'] != null
            ? await _userProvider.getById(map['user_id'])
            : null;

    final project = Project(
      id: projectMap['id'],
      name: projectMap['name'],
      description: projectMap['description'],
      createdAt: DateTime.parse(projectMap['created_at']),
      updatedAt: DateTime.parse(projectMap['updated_at']),
      deletedAt:
          projectMap['deleted_at'] != null
              ? DateTime.parse(projectMap['deleted_at'])
              : null,
      type: ProjectType.values.firstWhere((e) => e.key == projectMap['type']),
      user: null,
    );

    final user =
        userMap != null
            ? User(
              id: userMap['id'],
              email: userMap['email'],
              firstname: userMap['firstname'],
              organization: null,
              roles: [],
            )
            : null;

    return TagData(
      id: map['id'],
      positionLat: map['position_lat'],
      positionLng: map['position_lng'],
      hasChanged: map['has_changed'] == 1,
      hasSentToServer: map['has_sent_to_server'] == 1,
      type: TagType.values.firstWhere((e) => e.name == map['tag_type']),
      initialPositionLat: map['initial_position_lat'],
      initialPositionLng: map['initial_position_lng'],
      isDeleted: map['is_deleted'] == 1,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      incrementalId: map['incremental_id'],
      project: project,
      businessName: map['business_name'],
      businessOwner: map['business_owner'],
      businessAddress: map['business_address'],
      buildingStatus: BuildingStatus.values.firstWhere(
        (e) => e.key == map['building_status'],
      ),
      description: map['description'],
      sector: Sector.values.firstWhere((e) => e.key == map['sector']),
      note: map['note'],
      user:
          user ??
          User(id: '', email: '', firstname: '', organization: null, roles: []),
    );
  }

  /// Update a single column
  Future<void> updateColumn(String id, String columnName, dynamic value) async {
    await _taggingProvider.updateColumn(id, columnName, value);
  }

  Future<void> insertAllToLocalDb(List<TagData> tagList) async {
    final dataList =
        tagList.map((tag) {
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
            'building_status': tag.buildingStatus.key,
            'description': tag.description,
            'sector': tag.sector.key,
            'note': tag.note,
            'user_id': tag.user.id,
          };
        }).toList();

    await _taggingProvider.insertAllToLocalDb(dataList);
  }

  Future<void> deleteByIds(List<String> ids) async {
    await _taggingProvider.deleteByIds(ids);
  }

  Future<Map<String, int>> countSentAndUnsentByProjectId(
    String projectId,
  ) async {
    return await _taggingProvider.countSentAndUnsentByProjectId(projectId);
  }
}

import 'package:kendedes_mobile/classes/providers/local_db/browse_db_provider.dart';
import 'package:kendedes_mobile/models/interaction_mode.dart';
import 'package:kendedes_mobile/models/project.dart';

class BrowseDbRepository {
  static final BrowseDbRepository _instance = BrowseDbRepository._internal();
  factory BrowseDbRepository() => _instance;

  BrowseDbRepository._internal();

  late BrowseDbProvider _browseDbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _browseDbProvider = BrowseDbProvider();
    await _browseDbProvider.init();
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
}

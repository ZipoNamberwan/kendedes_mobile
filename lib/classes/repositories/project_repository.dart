import 'package:kendedes_mobile/classes/providers/project_povider.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class ProjectRepository {
  static final ProjectRepository _instance = ProjectRepository._internal();
  factory ProjectRepository() => _instance;

  ProjectRepository._internal();

  late ProjectProvider _projectProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _projectProvider = ProjectProvider();
    await _projectProvider.init();
  }

  Future<Map<String, dynamic>> getProjectsWithTags(String userId) async {
    final response = await _projectProvider.getProjectsWithTags(userId);
    final projects = <Project>[];
    final tags = <TagData>[];

    for (final projectJson in response) {
      // Parse project without businesses
      final project = Project.fromJson({
        ...projectJson,
        'businesses': null, // ignore businesses
      });
      projects.add(project);

      // Extract businesses separately
      final tagList = projectJson['businesses'] as List<dynamic>? ?? [];
      tags.addAll(
        tagList
            .map((tagJson) => TagData.fromJson(tagJson as Map<String, dynamic>))
            .toList(),
      );
    }

    return {'projects': projects, 'tags': tags};
  }

  Future<Project> createProject(Map<String, dynamic> projectData) async {
    final sentData = {...projectData, 'user': AuthRepository().getUser()?.id};
    final response = await _projectProvider.createProject(sentData);
    return Project.fromJson(response);
  }

  Future<Project> updateProject(
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    final response = await _projectProvider.updateProject(
      projectId,
      projectData,
    );
    return Project.fromJson(response);
  }

  Future<void> deleteProject(String projectId) async {
    await _projectProvider.deleteProject(projectId);
  }
}

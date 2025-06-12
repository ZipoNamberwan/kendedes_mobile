import 'package:kendedes_mobile/classes/services/dio_service.dart';

class ProjectProvider {
  static final ProjectProvider _instance = ProjectProvider._internal();
  factory ProjectProvider() => _instance;

  ProjectProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  Future<List<Map<String, dynamic>>> getProjects(String userId) async {
    final response = await _dioService.dio.get('/users/$userId/projects');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> projectData) async {
    final response = await _dioService.dio.post('/mobile-projects', data: projectData);
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> updateProject(String projectId, Map<String, dynamic> projectData) async {
    final response = await _dioService.dio.put('/mobile-projects/$projectId', data: projectData);
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<void> deleteProject(String projectId) async {
    await _dioService.dio.delete('/mobile-projects/$projectId');
  }
}

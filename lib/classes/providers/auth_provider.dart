import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:kendedes_mobile/classes/services/shared_preference_service.dart';

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;

  AuthProvider._internal();

  late SharedPreferenceService _sharedPreferenceService;
  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _sharedPreferenceService = SharedPreferenceService();
    await _sharedPreferenceService.init();
    _dioService = DioService();
    await _dioService.init();
  }

  bool isTokenExists() {
    return _sharedPreferenceService.getToken() != null &&
        _sharedPreferenceService.getUser() != null;
  }

  String? getToken() {
    return _sharedPreferenceService.getToken();
  }

  Map<String, dynamic>? getUser() {
    return _sharedPreferenceService.getUser();
  }

  Future<void> saveToken(String token) async {
    await _sharedPreferenceService.saveToken(token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _sharedPreferenceService.saveUser(user);
  }

  Future<void> clearToken() async {
    await _sharedPreferenceService.clearToken();
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioService.dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data['data'];
    final token = data['token'];
    final user = data['user'];

    if (token != null) {
      await _sharedPreferenceService.saveToken(token);
      await _sharedPreferenceService.saveUser(user);
    }

    return response.data;
  }

  Future<void> logout() async {
    await _dioService.dio.post('/logout');
    await _sharedPreferenceService.clearToken();
  }
}

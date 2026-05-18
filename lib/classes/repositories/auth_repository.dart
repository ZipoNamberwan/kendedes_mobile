import 'package:kendedes_mobile/classes/providers/auth_provider.dart';
import 'package:kendedes_mobile/models/user.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  AuthRepository._internal();

  late AuthProvider _authProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _authProvider = AuthProvider();
    await _authProvider.init();
  }

  bool isTokenExists() {
    return _authProvider.isTokenExists();
  }

  String? getToken() {
    return _authProvider.getToken();
  }

  User getUser() {
    final userJson = _authProvider.getUser();
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return User(id: '', email: '', firstname: '', roles: []);
  }

  Future<void> clearToken() async {
    await _authProvider.clearToken();
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _authProvider.login(
      email: email,
      password: password,
    );

    return User.fromJson(response['data']['user']);
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String firebaseToken,
  }) async {
    final response = await _authProvider.loginWithGoogle(
      firebaseToken: firebaseToken,
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<User> registerWithGoogle({
    required String email,
    required String name,
    required String organization,
    required String role,
  }) async {
    final response = await _authProvider.registerWithGoogle(
      email: email,
      name: name,
      organization: organization,
      role: role,
    );

    return User.fromJson(response['data']['user']);
  }

  Future<User> changeProfile({
    required String email,
    required String name,
    String? organization,
    String? role,
  }) async {
    final response = await _authProvider.changeProfile(
      email: email,
      name: name,
      organization: organization,
      role: role,
    );

    return User.fromJson(response['data']['user']);
  }

  Future<void> logout() async {
    await _authProvider.logout();
  }

  Future<void> saveToken(String token) async {
    await _authProvider.saveToken(token);
  }

  Future<void> saveUser(User user) async {
    await _authProvider.saveUser(user.toJson());
  }
}

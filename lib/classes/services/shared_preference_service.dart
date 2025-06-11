import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static final SharedPreferenceService _instance =
      SharedPreferenceService._internal();
  factory SharedPreferenceService() => _instance;

  SharedPreferenceService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  late SharedPreferences prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await prefs.setString(_userKey, jsonEncode(user));
  }

  String? getToken() {
    return prefs.getString(_tokenKey);
  }

  Map<String, dynamic>? getUser() {
    String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<void> clearToken() async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

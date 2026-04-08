import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      AppConstants.authLoginEndpoint,
      body: {'email': email, 'password': password},
    );
    final token = response['token'] as String;
    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    await _saveSession(token, user);
    return {'token': token, 'user': user};
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await _apiClient.post(
      AppConstants.authRegisterEndpoint,
      body: {'name': name, 'email': email, 'password': password},
    );
    final token = response['token'] as String;
    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    await _saveSession(token, user);
    return {'token': token, 'user': user};
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(AppConstants.authLogoutEndpoint);
    } catch (_) {
      // Proceed with local logout even if API call fails
    }
    await _clearSession();
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.prefUser);
    if (userJson == null) return null;
    try {
      return User.fromJson(json.decode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefToken) != null;
  }

  Future<void> _saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefToken, token);
    await prefs.setString(AppConstants.prefUser, json.encode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefToken);
    await prefs.remove(AppConstants.prefUser);
  }
}

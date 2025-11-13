import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recicla_ai_grupo_7_frontend/app_config.dart';

class ApiService {
  static const String _loginEndpoint =
      "http://${AppConfig.apiHost}:${AppConfig.apiPort}/auth/login";
  static Future<http.Response> authLogin(String email, String password) async {
    final url = Uri.parse(_loginEndpoint);
    try {
      final reponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return reponse;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  static const String _signupEndpoint =
      "http://${AppConfig.apiHost}:${AppConfig.apiPort}/auth/signup";
  static Future<http.Response> authSignup(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse(_signupEndpoint);
    try {
      final bodyStr = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: bodyStr,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  static const String _authMeEndpoint =
      "http://${AppConfig.apiHost}:${AppConfig.apiPort}/auth/me";
  static Future<http.Response> authMe(String bearerToken) async {
    final url = Uri.parse(_authMeEndpoint);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  static const String _logoutEndpoint =
      "http://${AppConfig.apiHost}:${AppConfig.apiPort}/auth/logout";
  static Future<http.Response> authLogout(String bearerToken) async {
    final url = Uri.parse(_logoutEndpoint);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  static const String _registerMaterialEndpoint =
      "http://${AppConfig.apiHost}:${AppConfig.apiPort}/residue/register_material";

  static Future<http.Response> registerMaterial({
    required String bearerToken,
    required String type,
    required String description,
  }) async {
    final url = Uri.parse(_registerMaterialEndpoint);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode({'type': type, 'description': description}),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to register material: $e');
    }
  }
}

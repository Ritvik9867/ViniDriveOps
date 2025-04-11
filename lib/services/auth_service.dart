import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'YOUR_GOOGLE_APPS_SCRIPT_DEPLOYMENT_URL';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=login'),
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      if (data['success']) {
        await _storage.write(key: 'user_token', value: data['token']);
        await _storage.write(key: 'user_role', value: data['role']);
        await _storage.write(key: 'user_id', value: data['userId']);
      }
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    File? profileImage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=register'),
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': 'driver', // New drivers always register as 'driver'
        }),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'user_token');
    return token != null;
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'user_token');
  }
}
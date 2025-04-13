import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/auth_models.dart';

/// Service responsible for handling authentication operations
class AuthService {
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'YOUR_GOOGLE_APPS_SCRIPT_DEPLOYMENT_URL',
  );
  
  final _storage = const FlutterSecureStorage();
  final _client = http.Client();
  final _connectivity = Connectivity();

  /// Attempts to log in a user with the given credentials
  Future<AuthResponse> login(String phone, String password) async {
    try {
      // Check network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return AuthResponse(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl?action=login'),
        body: json.encode({
          'phone': phone,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

      if (response.statusCode == 401) {
        return AuthResponse(
          success: false,
          message: 'Invalid credentials. Please try again.',
        );
      }

      if (response.statusCode != 200) {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;
      
      // Validate response structure
      if (!responseData.containsKey('success')) {
        throw FormatException('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);
      
      if (authResponse.success && authResponse.data != null) {
        await Future.wait([
          _storage.write(key: 'user_token', value: authResponse.data!.token),
          _storage.write(key: 'user_role', value: authResponse.data!.role),
          _storage.write(key: 'user_id', value: authResponse.data!.id),
          _storage.write(key: 'token_timestamp', value: DateTime.now().toIso8601String()),
        ]);
      }
      
      return authResponse;
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: 'Connection timed out. Please try again.',
      );
    } on FormatException {
      return AuthResponse(
        success: false,
        message: 'Invalid server response. Please try again.',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Registers a new user with the provided information
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Check network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return AuthResponse(
          success: false,
          message: 'No internet connection. Please check your network.',
        );
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl?action=register'),
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': 'driver', // New drivers always register as 'driver'
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

      if (response.statusCode == 409) {
        return AuthResponse(
          success: false,
          message: 'User already exists with this phone number.',
        );
      }

      if (response.statusCode != 200) {
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;
      
      // Validate response structure
      if (!responseData.containsKey('success')) {
        throw FormatException('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);
      
      if (authResponse.success && authResponse.data != null) {
        await Future.wait([
          _storage.write(key: 'user_token', value: authResponse.data!.token),
          _storage.write(key: 'user_role', value: authResponse.data!.role),
          _storage.write(key: 'user_id', value: authResponse.data!.id),
          _storage.write(key: 'token_timestamp', value: DateTime.now().toIso8601String()),
        ]);
      }
      
      return authResponse;
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: 'Connection timed out. Please try again.',
      );
    } on FormatException {
      return AuthResponse(
        success: false,
        message: 'Invalid server response. Please try again.',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Checks if the user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'user_token');
      if (token == null) return false;

      // Check token expiration (assuming 24 hours validity)
      final timestampStr = await _storage.read(key: 'token_timestamp');
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inHours >= 24) {
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the current user's role
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: 'user_role');
    } catch (e) {
      return null;
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Ignore errors during logout
    }
  }

  /// Gets the current authentication token
  Future<String?> getAuthToken() async {
    try {
      final token = await _storage.read(key: 'user_token');
      if (token == null) return null;

      // Check token expiration
      final timestampStr = await _storage.read(key: 'token_timestamp');
      if (timestampStr == null) return null;

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inHours >= 24) {
        await logout();
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  /// Disposes of any resources
  void dispose() {
    _client.close();
  }
}

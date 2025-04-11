import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import './auth_service.dart';

class ApiService {
  static const String _baseUrl = 'YOUR_GOOGLE_APPS_SCRIPT_DEPLOYMENT_URL';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> _authenticatedRequest(
    String endpoint,
    String method,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            Uri.parse('$_baseUrl?action=$endpoint'),
            headers: headers,
          );
          break;
        case 'POST':
          response = await http.post(
            Uri.parse('$_baseUrl?action=$endpoint'),
            headers: headers,
            body: json.encode(body),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    }
  }

  // Upload image to Google Drive
  Future<Map<String, dynamic>> uploadImage(File imageFile, String type) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fileName = path.basename(imageFile.path);

      return await _authenticatedRequest('uploadImage', 'POST', {
        'image': base64Image,
        'fileName': fileName,
        'type': type, // 'od_reading', 'cng_bill', 'complaint', 'payment'
      });
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload image. Please try again.',
      };
    }
  }

  // Submit odometer reading
  Future<Map<String, dynamic>> submitOdometerReading({
    required String imageUrl,
    required double reading,
    required bool isStarting,
  }) async {
    return await _authenticatedRequest('submitOdReading', 'POST', {
      'imageUrl': imageUrl,
      'reading': reading,
      'isStarting': isStarting,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Log a new trip
  Future<Map<String, dynamic>> logTrip({
    required double amount,
    required double tripKm,
    required String paymentMode,
    required String paymentType,
    double? toll,
  }) async {
    return await _authenticatedRequest('logTrip', 'POST', {
      'amount': amount,
      'tripKm': tripKm,
      'paymentMode': paymentMode,
      'paymentType': paymentType,
      'toll': toll,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Submit CNG expense
  Future<Map<String, dynamic>> submitCNGExpense({
    required double amount,
    required String proofImageUrl,
    required String paymentMode,
  }) async {
    return await _authenticatedRequest('submitCNGExpense', 'POST', {
      'amount': amount,
      'proofImageUrl': proofImageUrl,
      'paymentMode': paymentMode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Submit complaint
  Future<Map<String, dynamic>> submitComplaint({
    required String description,
    required String proofImageUrl,
    required String againstDriver,
  }) async {
    return await _authenticatedRequest('submitComplaint', 'POST', {
      'description': description,
      'proofImageUrl': proofImageUrl,
      'againstDriver': againstDriver,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Submit advance repayment
  Future<Map<String, dynamic>> submitAdvanceRepayment({
    required double amount,
    required String screenshotUrl,
  }) async {
    return await _authenticatedRequest('submitAdvanceRepayment', 'POST', {
      'amount': amount,
      'screenshotUrl': screenshotUrl,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Get driver dashboard data
  Future<Map<String, dynamic>> getDriverDashboard({
    String? startDate,
    String? endDate,
  }) async {
    return await _authenticatedRequest('getDriverDashboard', 'POST', {
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  // Get admin dashboard data
  Future<Map<String, dynamic>> getAdminDashboard({
    String? driverId,
    String? startDate,
    String? endDate,
  }) async {
    return await _authenticatedRequest('getAdminDashboard', 'POST', {
      'driverId': driverId,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  // Get all drivers (admin only)
  Future<Map<String, dynamic>> getAllDrivers() async {
    return await _authenticatedRequest('getAllDrivers', 'GET', {});
  }

  // Approve/reject CNG upload or repayment (admin only)
  Future<Map<String, dynamic>> updateApprovalStatus({
    required String itemId,
    required String type,
    required bool approved,
    String? remarks,
  }) async {
    return await _authenticatedRequest('updateApprovalStatus', 'POST', {
      'itemId': itemId,
      'type': type, // 'cng_expense' or 'advance_repayment'
      'approved': approved,
      'remarks': remarks,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Add new advance (admin only)
  Future<Map<String, dynamic>> addAdvance({
    required String driverId,
    required double amount,
    String? remarks,
  }) async {
    return await _authenticatedRequest('addAdvance', 'POST', {
      'driverId': driverId,
      'amount': amount,
      'remarks': remarks,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
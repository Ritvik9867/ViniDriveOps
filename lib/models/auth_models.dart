import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';
part 'auth_models.freezed.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool success,
    String? message,
    UserData? data,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  /// Creates a failure response with a message
  factory AuthResponse.failure(String message) => AuthResponse(
        success: false,
        message: message,
      );

  /// Creates a success response with optional data
  factory AuthResponse.success([UserData? data]) => AuthResponse(
        success: true,
        data: data,
      );
}

@freezed
class UserData with _$UserData {
  const UserData._(); // Required for getters

  const factory UserData({
    required String id,
    required String token,
    required String role,
    required String name,
    required String phone,
    String? email,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  /// Validates if the user data is complete and valid
  bool get isValid =>
      id.isNotEmpty &&
      token.isNotEmpty &&
      role.isNotEmpty &&
      name.isNotEmpty &&
      phone.isNotEmpty &&
      (email?.isEmpty ?? true || (email?.contains('@') ?? false));
}
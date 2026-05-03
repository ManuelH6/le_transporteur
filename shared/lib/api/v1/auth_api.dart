// shared/lib/api/v1/auth_api.dart

import 'dart:convert';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/auth_response.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/utils/api_utils.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? countryCode,
    String genderrole = 'other',
    String signupIntent = 'client',
  }) async {
    final response = await _client.post('/api/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'genderrole': genderrole,
      'signupIntent': signupIntent,
    });
    final data = jsonDecode(response.body);
    final userMap = ApiUtils.extractMap(data);
    if (userMap == null) {
       throw Exception("Impossible de lire les données de l'utilisateur après l'inscription.");
    }
    return User.fromJson(userMap);
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.post('/api/v1/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    final data = jsonDecode(response.body);
    final authResponse = AuthResponse.fromJson(data);
    await _client.saveTokens(authResponse.accessToken, authResponse.refreshToken, authResponse.user);
    return authResponse;
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final response = await _client.post('/api/v1/auth/refresh', {
      'refreshToken': refreshToken,
    });
    final data = jsonDecode(response.body);
    final authResponse = AuthResponse.fromJson(data);
    await _client.saveTokens(authResponse.accessToken, authResponse.refreshToken, authResponse.user);
    return authResponse;
  }

  Future<void> verifyEmail(String email, String token) async {
    await _client.post('/api/v1/auth/verify-email', {
      'email': email,
      'token': token,
    });
  }

  Future<void> resendVerification(String email) async {
    await _client.post('/api/v1/auth/resend-verification', {
      'email': email,
    });
  }

  Future<void> forgotPassword(String email) async {
    await _client.post('/api/v1/auth/forgot-password', {
      'email': email,
    });
  }

  Future<void> resetPassword(String email, String token, String newPassword) async {
    await _client.post('/api/v1/auth/reset-password', {
      'email': email,
      'token': token,
      'newPassword': newPassword,
    });
  }

  Future<void> logout(String? fcmToken) async {
    await _client.post('/api/v1/auth/logout', {
      'fcmToken': fcmToken,
    });
    await _client.clearTokens();
  }
}

// shared/lib/api/v1/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_le_transporteur/models/api_error_response.dart';
import 'package:shared_le_transporteur/models/user.dart';

class ApiClient {
  static const String baseUrl = 'https://letransporteur-production.up.railway.app';
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _accessToken;
  Box? _authBox;

  Future<void> _initBox() async {
    if (_authBox == null || !_authBox!.isOpen) {
      _authBox = await Hive.openBox('auth');
    }
  }

  Future<String?> get token async {
    await _initBox();
    _accessToken = _authBox!.get('accessToken');
    return _accessToken;
  }

  Future<User?> get user async {
    await _initBox();
    final userData = _authBox!.get('user');
    if (userData != null && userData is Map) {
      return User.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  Future<void> saveTokens(String accessToken, String refreshToken, [User? user]) async {
    await _initBox();
    await _authBox!.put('accessToken', accessToken);
    await _authBox!.put('refreshToken', refreshToken);
    if (user != null) {
      await _authBox!.put('user', user.toJson());
    }
    _accessToken = accessToken;
  }

  Future<void> clearTokens() async {
    await _initBox();
    await _authBox!.delete('accessToken');
    await _authBox!.delete('refreshToken');
    await _authBox!.delete('user');
    _accessToken = null;
  }

  Map<String, String> _headers(String? tok) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-Platform': 'mobile',
      'X-Client': 'flutter',
    };
    if (tok != null) {
      headers['Authorization'] = 'Bearer $tok';
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    final t = await token;
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.get(url, headers: _headers(t));
      if (response.statusCode == 401 && !path.contains('/auth/login')) {
        final refreshed = await _attemptRefresh();
        if (refreshed) {
          final newToken = await token;
          return await http.get(url, headers: _headers(newToken));
        }
      }
      return _handleResponse(response, 'GET', path);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) rethrow; // Already handled refresh attempt
      print('[ApiClient] Exception during GET $path: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String path, dynamic body) async {
    final t = await token;
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.post(
        url,
        headers: _headers(t),
        body: jsonEncode(body),
      );
      if (response.statusCode == 401 && !path.contains('/auth/login')) {
        final refreshed = await _attemptRefresh();
        if (refreshed) {
          final newToken = await token;
          return await http.post(url, headers: _headers(newToken), body: jsonEncode(body));
        }
      }
      return _handleResponse(response, 'POST', path);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) rethrow;
      print('[ApiClient] Exception during POST $path: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String path, dynamic body) async {
    final t = await token;
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.put(
        url,
        headers: _headers(t),
        body: jsonEncode(body),
      );
      if (response.statusCode == 401 && !path.contains('/auth/login')) {
        final refreshed = await _attemptRefresh();
        if (refreshed) {
          final newToken = await token;
          return await http.put(url, headers: _headers(newToken), body: jsonEncode(body));
        }
      }
      return _handleResponse(response, 'PUT', path);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) rethrow;
      print('[ApiClient] Exception during PUT $path: $e');
      rethrow;
    }
  }

  Future<http.Response> patch(String path, dynamic body) async {
    final t = await token;
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.patch(
        url,
        headers: _headers(t),
        body: jsonEncode(body),
      );
      if (response.statusCode == 401 && !path.contains('/auth/login')) {
        final refreshed = await _attemptRefresh();
        if (refreshed) {
          final newToken = await token;
          return await http.patch(url, headers: _headers(newToken), body: jsonEncode(body));
        }
      }
      return _handleResponse(response, 'PATCH', path);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) rethrow;
      print('[ApiClient] Exception during PATCH $path: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String path) async {
    final t = await token;
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.delete(url, headers: _headers(t));
      if (response.statusCode == 401 && !path.contains('/auth/login')) {
        final refreshed = await _attemptRefresh();
        if (refreshed) {
          final newToken = await token;
          return await http.delete(url, headers: _headers(newToken));
        }
      }
      return _handleResponse(response, 'DELETE', path);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) rethrow;
      print('[ApiClient] Exception during DELETE $path: $e');
      rethrow;
    }
  }

  Future<bool> _attemptRefresh() async {
    try {
      await _initBox();
      final refreshToken = _authBox!.get('refreshToken');
      if (refreshToken == null) return false;

      print('[ApiClient] Attempting token refresh...');
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: _headers(null),
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        if (accessToken != null) {
          await saveTokens(accessToken, newRefreshToken ?? refreshToken);
          print('[ApiClient] Token refresh successful.');
          return true;
        }
      }
      print('[ApiClient] Token refresh failed: ${response.statusCode}');
      await clearTokens();
      return false;
    } catch (e) {
      print('[ApiClient] Exception during token refresh: $e');
      await clearTokens();
      return false;
    }
  }

  http.Response _handleResponse(http.Response response, String method, String path) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      print('[ApiClient] Error ${response.statusCode} on $method $path');
      print('[ApiClient] Response Body: ${response.body}');

      ApiErrorResponse? errorResponse;
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          errorResponse = ApiErrorResponse.fromJson(data, response.statusCode);
        }
      } catch (_) {
        // Body is not JSON
      }

      if (response.statusCode == 403) {
        throw ApiException(
          'Veuillez valider votre adresse email avant de vous connecter.',
          response.statusCode,
          response.body,
          errorResponse,
        );
      } else if (response.statusCode == 401) {
        String message = 'Email ou mot de passe incorrect.';
        if (!path.contains('/auth/login')) {
          message = 'Votre session a expiré. Veuillez vous reconnecter.';
        }
        throw ApiException(
          message,
          response.statusCode,
          response.body,
          errorResponse,
        );
      } else if (response.statusCode == 409) {
        throw ApiException(
          'Cette adresse email est déjà utilisée par un autre compte.',
          response.statusCode,
          response.body,
          errorResponse,
        );
      } else {
        String message = errorResponse?.message ?? 'Une erreur est survenue (${response.statusCode})';
        if (message.contains('already in use')) {
          message = 'Cette adresse email est déjà utilisée.';
        }
        throw ApiException(
          message,
          response.statusCode,
          response.body,
          errorResponse,
        );
      }
    }
  }

}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String body;
  final ApiErrorResponse? errorResponse;

  ApiException(this.message, this.statusCode, this.body, [this.errorResponse]);

  @override
  String toString() {
    if (errorResponse != null) return errorResponse.toString();
    return 'ApiException: $message ($statusCode): $body';
  }
}

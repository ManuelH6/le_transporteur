// shared/lib/api/v1/admin_api.dart

import 'dart:convert';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/models/commande.dart';

class AdminApi {
  final ApiClient _client = ApiClient();

  /// Fetch dashboard statistics (KPIs, revenue, etc.)
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _client.get('/api/v1/admin/stats');
    return jsonDecode(response.body);
  }

  /// Get list of all users with optional filtering
  Future<List<User>> getAllUsers({String? role, String? query}) async {
    String path = '/api/v1/admin/users';
    final params = <String, String>{};
    if (role != null) params['role'] = role;
    if (query != null) params['q'] = query;
    
    if (params.isNotEmpty) {
      path += '?' + Uri(queryParameters: params).query;
    }
    
    final response = await _client.get(path);
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => User.fromJson(e)).toList();
    }
    return [];
  }

  /// Update a user's role or status
  Future<User> updateUserStatus(String userId, Map<String, dynamic> body) async {
    final response = await _client.patch('/api/v1/admin/users/$userId', body);
    return User.fromJson(jsonDecode(response.body));
  }

  /// Approve or reject a livreur request
  Future<User> reviewLivreurRequest(String userId, {required String status, String? reason}) async {
    final body = {
      'status': status,
      if (reason != null) 'reason': reason,
    };
    final response = await _client.post('/api/v1/admin/users/$userId/review-livreur', body);
    return User.fromJson(jsonDecode(response.body));
  }

  /// Get all orders in the system with filters
  Future<List<Commande>> getAllOrders({String? status}) async {
    String path = '/api/v1/admin/orders';
    if (status != null) path += '?status=$status';
    
    final response = await _client.get(path);
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => Commande.fromJson(e)).toList();
    }
    return [];
  }

  /// Broadcast a notification to all users or a specific role
  Future<void> broadcastNotification({
    required String title,
    required String message,
    String? targetRole,
  }) async {
    final body = {
      'title': title,
      'message': message,
      if (targetRole != null) 'role': targetRole,
    };
    await _client.post('/api/v1/admin/notifications/broadcast', body);
  }

  /// Get system settings
  Future<Map<String, dynamic>> getSystemSettings() async {
    final response = await _client.get('/api/v1/admin/settings');
    return jsonDecode(response.body);
  }

  /// Update system settings (pricing, etc.)
  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    await _client.patch('/api/v1/admin/settings', settings);
  }
  
  /// Get real-time positions of active livreurs
  Future<List<Map<String, dynamic>>> getFleetPositions() async {
    final response = await _client.get('/api/v1/admin/fleet/positions');
    final data = jsonDecode(response.body);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}

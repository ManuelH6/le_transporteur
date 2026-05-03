// shared/lib/api/v1/livreur_api.dart

import 'dart:convert';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/livreur_profile.dart';

class LivreurApi {
  final ApiClient _client = ApiClient();

  /// Updates or creates a delivery profile by userId.
  /// Path: /api/v1/livreur/{userId}/profile (PUT)
  Future<LivreurProfile> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await _client.put('/api/v1/livreur/$userId/profile', data);
    final respData = jsonDecode(response.body);
    return LivreurProfile.fromJson(respData);
  }

  /// Gets the current delivery profile.
  Future<LivreurProfile> getMyProfile() async {
    final response = await _client.get('/api/v1/livreur/me/profile');
    final respData = jsonDecode(response.body);
    return LivreurProfile.fromJson(respData);
  }
}

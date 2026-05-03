// shared/lib/api/v1/user_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'dart:io';

class UserApi {
  final ApiClient _client = ApiClient();

  Future<List<User>> getUsers() async {
    final response = await _client.get('/api/v1/user/');
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => User.fromJson(e)).toList();
    }
    return [];
  }

  Future<User> getUserById(String id) async {
    final response = await _client.get('/api/v1/user/$id');
    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  /// Get current authenticated user profile
  Future<User> getMe() async {
    final user = await _client.user;
    if (user == null) {
      throw Exception('Utilisateur non trouvé localement. Veuillez vous reconnecter.');
    }
    final response = await _client.get('/api/v1/user/${user.id}');
    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  Future<User> updateUser(String id, Map<String, dynamic> body) async {
    final response = await _client.put('/api/v1/user/$id', body);
    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  Future<void> clearRefresh(String id) async {
    await _client.post('/api/v1/user/$id/clear-refresh', {});
  }

  /// Upload profile photo via multipart request
  Future<String> uploadProfilePhoto(String filePath) async {
    final token = await _client.token;
    final user = await _client.user;
    if (user == null) {
      throw Exception('Utilisateur non trouvé localement.');
    }
    final file = File(filePath);
    
    var request = http.MultipartRequest('POST', Uri.parse('${ApiClient.baseUrl}/api/v1/user/me/photo'));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });
    request.files.add(await http.MultipartFile.fromPath('photo', file.path));
    
    var response = await request.send();
    final respBody = await response.stream.bytesToString();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(respBody);
      return data['profileImageUrl'] ?? '';
    } else {
      throw ApiException('Upload failed', response.statusCode, respBody);
    }
  }
}

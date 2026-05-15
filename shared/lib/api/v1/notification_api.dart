import 'dart:convert';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/user_notification.dart';

class NotificationApi {
  final ApiClient _client = ApiClient();

  /// Récupérer la liste des notifications
  Future<List<UserNotification>> getNotifications() async {
    final user = await _client.user;
    if (user == null) throw Exception("Session expirée");

    final response = await _client.get('/api/v1/notifications');
    // ignore: avoid_print
    //print("DEBUG [NotificationApi] Raw Response: ${response.body}");
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => UserNotification.fromJson(e)).toList();
    }
    return [];
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String id) async {
    final user = await _client.user;
    if (user == null) throw Exception("Session expirée");

    await _client.patch('/api/v1/notifications/$id/read', {});
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final user = await _client.user;
    if (user == null) throw Exception("Session expirée");

    await _client.patch('/api/v1/notifications/read-all', {});
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String id) async {
    await _client.delete('/api/v1/notifications/$id');
  }
}

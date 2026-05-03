import 'dart:convert';
import 'package:shared_le_transporteur/api/v1/api_client.dart';

class ReportApi {
  final ApiClient _client = ApiClient();

  /// Gets courier summary in JSON format.
  /// Includes KPIs, leaderboard, courses, etc.
  Future<Map<String, dynamic>> getCourierSummary() async {
    final response = await _client.get('/api/v1/report/couriers/summary/json');
    return jsonDecode(response.body);
  }

  /// Gets periodic courier summary.
  /// period: 'daily', 'week', 'month', 'all'
  /// Gets personal history and stats for the connected user.
  Future<Map<String, dynamic>> getHistoryMe() async {
    final response = await _client.post('/api/v1/report/history/me', {});
    return jsonDecode(response.body);
  }
}

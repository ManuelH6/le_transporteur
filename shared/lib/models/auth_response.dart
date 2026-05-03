// shared/lib/models/auth_response.dart

import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/utils/api_utils.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      };

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userMap = ApiUtils.extractMap(json, preferredKeys: ['user']);
    if (userMap == null) {
      throw Exception("Données utilisateur manquantes dans la réponse d'authentification.");
    }
    return AuthResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: User.fromJson(userMap),
    );
  }
}

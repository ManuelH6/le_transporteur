// shared/lib/models/api_error_response.dart

class ApiErrorResponse {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiErrorResponse({
    required this.message,
    this.errors,
    this.statusCode,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json, [int? statusCode]) {
    return ApiErrorResponse(
      message: json['message'] ?? json['error'] ?? 'Une erreur est survenue',
      errors: _parseErrors(json['errors']),
      statusCode: statusCode,
    );
  }

  static Map<String, dynamic>? _parseErrors(dynamic errors) {
    if (errors == null) return null;
    if (errors is Map<String, dynamic>) return errors;
    if (errors is List) {
      final Map<String, dynamic> map = {};
      for (var err in errors) {
        if (err is Map<String, dynamic>) {
          final path = (err['path'] ?? 'global').toString();
          final msg = (err['msg'] ?? 'Erreur').toString();
          if (map.containsKey(path)) {
            if (map[path] is List) {
              map[path].add(msg);
            } else {
              map[path] = [map[path], msg];
            }
          } else {
            map[path] = msg;
          }
        }
      }
      return map.isEmpty ? null : map;
    }
    return null;
  }

  factory ApiErrorResponse.simple(String message, [int? statusCode]) {
    return ApiErrorResponse(message: message, statusCode: statusCode);
  }

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln(message);
      errors!.forEach((key, value) {
        if (value is List) {
          buffer.writeln('- $key: ${value.join(", ")}');
        } else {
          buffer.writeln('- $key: $value');
        }
      });
      return buffer.toString().trim();
    }
    return message;
  }
}

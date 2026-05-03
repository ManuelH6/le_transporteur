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
      errors: json['errors'] is Map<String, dynamic> ? json['errors'] : null,
      statusCode: statusCode,
    );
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

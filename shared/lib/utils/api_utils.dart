// shared/lib/utils/api_utils.dart

class ApiUtils {
  /// Extracts the main data payload from an API response body.
  /// Handles wrapped responses (e.g., {'data': ...} or {'user': ...}) 
  /// and unwrapped responses.
  static Map<String, dynamic>? extractMap(dynamic body, {List<String> preferredKeys = const ['data', 'user']}) {
    if (body is! Map<String, dynamic>) return null;

    for (final key in preferredKeys) {
      if (body.containsKey(key) && body[key] is Map<String, dynamic>) {
        return body[key] as Map<String, dynamic>;
      }
    }

    // Fallback: if it's already a map but doesn't have the preferred keys, 
    // it might be the data itself (unwrapped).
    return body;
  }
}

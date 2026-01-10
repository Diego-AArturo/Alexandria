import 'dart:convert';

import 'package:http/http.dart' as http;

/// API client para comunicar la app con el backend FastAPI.
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _http = httpClient ?? http.Client(),
        baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = 'http://localhost:8000';

  final http.Client _http;

  /// URL base configurable (util para apuntar a dev/stage/prod).
  final String baseUrl;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    return _decodeAndValidate(uri, response);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    );
    return _decodeAndValidate(uri, response);
  }

  Map<String, dynamic> _decodeAndValidate(Uri uri, http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        uri: uri.toString(),
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        uri: uri.toString(),
        statusCode: response.statusCode,
        body: 'Unexpected payload: ${response.body}',
      );
    }
    return decoded;
  }
}

class ApiException implements Exception {
  ApiException({
    required this.uri,
    required this.statusCode,
    required this.body,
  });

  final String uri;
  final int statusCode;
  final String body;

  @override
  String toString() =>
      'ApiException($statusCode) on $uri: $body';
}

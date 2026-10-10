import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _apiOriginOverride = String.fromEnvironment('API_ORIGIN');

/// Release builds talk to the live site. Debug builds keep the local Laravel server.
/// Override either with `--dart-define=API_ORIGIN=https://example.com`.
String get apiOrigin {
  final override = _apiOriginOverride.trim();
  if (override.isNotEmpty) return override;
  if (kReleaseMode) return 'https://pos360techx.com';
  return 'http://127.0.0.1:8000';
}

class ApiClient {
  ApiClient() {
    dio.options.baseUrl = apiOrigin;
    dio.options.headers['Accept'] = 'application/json';
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 40);
  }

  final Dio dio = Dio();
  String? token;
  String? deviceId;

  Options get _auth => Options(headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        if (deviceId != null) 'X-Device-Id': deviceId,
      });

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await dio.post<Map<String, dynamic>>(path, data: body, options: _auth);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> get(String path, [Map<String, dynamic>? query]) async {
    final response = await dio.get<Map<String, dynamic>>(path, queryParameters: query, options: _auth);
    return response.data ?? {};
  }

  Future<List<int>> bytes(String path, [Map<String, dynamic>? query]) async {
    final response = await dio.get<List<int>>(
      path,
      queryParameters: query,
      options: _auth.copyWith(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }
}

String apiError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
      }
    }
    return error.message ?? 'Request failed';
  }
  return error.toString();
}

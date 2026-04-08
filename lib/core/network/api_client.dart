import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  Future<String?> get _token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefToken);
  }

  Future<Map<String, String>> get _headers async {
    final token = await _token;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Extracts a [List] from various API response shapes:
  /// - Direct list: `[...]`
  /// - Data-wrapped: `{"data": [...]}`
  /// - Nested paginated: `{"data": {"data": [...], "total": ...}}`
  static List<dynamic> extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      final data = response['data'];
      if (data is List) return data;
      if (data is Map) {
        final nested = data['data'];
        if (nested is List) return nested;
      }
    }
    assert(
      false,
      'ApiClient.extractList: unexpected response shape: ${response.runtimeType}',
    );
    return [];
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
        queryParameters: queryParams,
      );
      final response = await _client
          .get(uri, headers: await _headers)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your connection.');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await _client
          .post(
            uri,
            headers: await _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your connection.');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await _client
          .put(
            uri,
            headers: await _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your connection.');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await _client
          .delete(uri, headers: await _headers)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your connection.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message =
        (body is Map ? body['message']?.toString() : null) ?? 'Request failed';
    throw ApiException(message, statusCode: response.statusCode);
  }
}

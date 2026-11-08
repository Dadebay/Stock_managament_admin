// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ApiService {
  ApiService({http.Client? client, AuthStorage? auth})
      : _client = client ?? _sharedClient,
        _auth = auth ?? AuthStorage();

  static final http.Client _sharedClient = http.Client();
  final http.Client _client;
  final AuthStorage _auth;

  // Cache for GET requests (simple in-memory cache)
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Check if cache is valid
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  // Get from cache
  dynamic _getFromCache(String key) {
    if (_isCacheValid(key)) {
      return _cache[key];
    }
    return null;
  }

  // Save to cache
  void _saveToCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Clear cache
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  Future<dynamic> getRequest(
    String endpoint, {
    required bool requiresToken,
    Future<dynamic> Function(dynamic)? handleSuccess,
    bool useCache = true,
  }) async {
    try {
      final token = await _auth.getToken();
      if (requiresToken && (token == null || token.isEmpty)) {
        _handleApiError(401, 'Authentication required');
        return null;
      }
      // Cache entries belong to one session. Never return another user's data.
      final cacheKey = '${token ?? 'public'}|$endpoint';
      // Check cache first for GET requests
      if (useCache) {
        final cachedData = _getFromCache(cacheKey);
        if (cachedData != null) {
          if (handleSuccess != null) {
            await handleSuccess(cachedData);
          }
          return cachedData;
        }
      }

      final headers = <String, String>{
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
      };

      final response = await _client
          .get(
        Uri.parse(endpoint),
        headers: headers,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      // DÜZELTME: Gelen yanıtın ham baytlarını UTF-8 olarak çözüyoruz.
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final responseJson =
            decodedBody.isNotEmpty ? json.decode(decodedBody) : {};

        // Save successful response to cache
        if (useCache) {
          _saveToCache(cacheKey, responseJson);
        }

        if (handleSuccess != null) {
          await handleSuccess(responseJson);
        }
        return responseJson;
      } else {
        // DÜZELTME: Hata durumunda bile doğru karakter setini kullanıyoruz.
        dynamic responseJson;
        try {
          responseJson =
              decodedBody.isNotEmpty ? json.decode(decodedBody) : null;
        } on FormatException {
          // HTML and other malformed responses should not be shown to staff.
        }
        final serverMessage =
            responseJson is Map ? responseJson['message'] : null;
        _handleApiError(response.statusCode,
            serverMessage?.toString() ?? 'anErrorOccurred'.tr);
        return null;
      }
    } on TimeoutException {
      CustomWidgets.showSnackBar(
          'Error', 'Request timeout. Please try again.', Colors.red);
      return null;
    } on SocketException {
      CustomWidgets.showSnackBar(
          'networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      CustomWidgets.showSnackBar(
          'unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<dynamic> handleApiRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    required bool requiresToken,
    required String method,
    Function(dynamic)? handleSuccess,
  }) async {
    try {
      final token = await _auth.getToken();
      if (requiresToken && (token == null || token.isEmpty)) {
        _handleApiError(401, 'Authentication required');
        return null;
      }
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response =
              await _client.get(Uri.parse(endpoint), headers: headers).timeout(
                    const Duration(seconds: 30),
                    onTimeout: () => throw TimeoutException('Request timeout'),
                  );
          break;
        case 'POST':
          response = await _client
              .post(
                Uri.parse(endpoint),
                headers: headers,
                body: jsonEncode(body ?? {}),
              )
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw TimeoutException('Request timeout'),
              );
          break;
        case 'DELETE':
          response = await _client
              .delete(
                Uri.parse(endpoint),
                headers: headers,
              )
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw TimeoutException('Request timeout'),
              );
          break;
        case 'PUT':
          response = await _client
              .put(
                Uri.parse(endpoint),
                headers: headers,
                body: jsonEncode(body ?? {}),
              )
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw TimeoutException('Request timeout'),
              );
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }

      // DÜZELTME: Yanıtı her zaman önce UTF-8 olarak çözüyoruz.
      final decodedBody = utf8.decode(response.bodyBytes);

      if ([200, 201, 204].contains(response.statusCode)) {
        if (method.toUpperCase() != 'GET') clearCache();
        if (response.statusCode == 204) {
          if (handleSuccess != null) {
            await handleSuccess({"statusCode": response.statusCode});
          }
          return {"statusCode": response.statusCode};
        }

        final responseJson =
            decodedBody.isNotEmpty ? json.decode(decodedBody) : null;
        if (handleSuccess != null && responseJson != null) {
          await handleSuccess(responseJson);
        }
        return responseJson ?? response.statusCode;
      } else {
        dynamic errorBody;
        try {
          errorBody = decodedBody.isNotEmpty ? json.decode(decodedBody) : null;
        } on FormatException {
          // HTML and other malformed responses can contain private data.
        }
        final serverMessage = errorBody is Map ? errorBody['message'] : null;
        final message = serverMessage is String
            ? serverMessage
            : serverMessage is List
                ? serverMessage.whereType<String>().join(', ')
                : 'anErrorOccurred'.tr;
        _handleApiError(response.statusCode, message);
        return null;
      }
    } on TimeoutException {
      CustomWidgets.showSnackBar(
          'Error', 'Request timeout. Please try again.', Colors.red);
      return null;
    } on SocketException {
      CustomWidgets.showSnackBar(
          'networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      CustomWidgets.showSnackBar(
          'unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  void _handleApiError(int statusCode, String message) {
    String errorMessage = 'anErrorOccurred'.tr;
    switch (statusCode) {
      case 400:
        errorMessage = message;
        break;
      case 401:
        errorMessage = '${'unauthorized'.tr}: $message';
        break;
      case 403:
        errorMessage = '$message';
        break;
      case 404:
        errorMessage = '${'notFound'.tr}: $message';
        break;
      case 405:
        errorMessage = 'userDoesNotExist'.tr;
        break;
      case 408:
        errorMessage = 'Request timeout. Please try again.';
        break;
      case 426:
        errorMessage = 'Update this app before continuing.';
        break;
      case 429:
        errorMessage = 'Too many requests. Please try again later.';
        break;
      case 500:
        errorMessage = '${'serverError'.tr}: $message';
        break;
      default:
        errorMessage = '${'errorStatus'.tr} $statusCode: $message';
    }
    if (statusCode == 409) {
      CustomWidgets.showSnackBar('Error'.tr, errorMessage, Colors.orange);
    } else {
      CustomWidgets.showSnackBar('Error'.tr, errorMessage, Colors.red);
    }
  }
}

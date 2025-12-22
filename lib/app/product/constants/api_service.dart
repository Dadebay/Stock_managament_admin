// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ApiService {
  final AuthStorage _auth = AuthStorage();

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
      // Check cache first for GET requests
      if (useCache) {
        final cachedData = _getFromCache(endpoint);
        if (cachedData != null) {
          if (handleSuccess != null) {
            await handleSuccess(cachedData);
          }
          return cachedData;
        }
      }

      final token = await _auth.getToken();
      final headers = <String, String>{
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
      };

      final response = await http
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
        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};

        // Save successful response to cache
        if (useCache) {
          _saveToCache(endpoint, responseJson);
        }

        if (handleSuccess != null) {
          await handleSuccess(responseJson);
        }
        return responseJson;
      } else {
        // DÜZELTME: Hata durumunda bile doğru karakter setini kullanıyoruz.
        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        _handleApiError(response.statusCode, responseJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        return null;
      }
    } on TimeoutException {
      CustomWidgets.showSnackBar('Error', 'Request timeout. Please try again.', Colors.red);
      return null;
    } on SocketException {
      CustomWidgets.showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      CustomWidgets.showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
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
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      http.Response response;
      print('\n===== API REQUEST =====');
      print('Method: $method');
      print('Endpoint: $endpoint');
      if (body != null) {
        print('Request Body: $body');
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(endpoint), headers: headers).timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw TimeoutException('Request timeout'),
              );
          break;
        case 'POST':
          response = await http
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
          response = await http
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
          response = await http
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

      print('===== API RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print('Response Body: $decodedBody');
      print('======================\n');
      if ([200, 201, 204].contains(response.statusCode)) {
        if (response.statusCode == 204) {
          if (handleSuccess != null) {
            await handleSuccess({"statusCode": response.statusCode});
          }
          return {"statusCode": response.statusCode};
        }

        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : null;
        if (handleSuccess != null && responseJson != null) {
          await handleSuccess(responseJson);
        }
        return responseJson ?? response.statusCode;
      } else {
        print('\n===== ERROR RESPONSE =====');
        print('Status Code: ${response.statusCode}');

        // DÜZELTME: Hata yanıtını da UTF-8 olarak çözüyoruz.
        try {
          final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
          // Hata mesajı artık bir Map olabilir, bu yüzden toString() kullanmak daha güvenli.
          String errorMessage = responseJson.toString();

          print('Error Response JSON: $responseJson');

          _handleApiError(
            response.statusCode,
            errorMessage,
          );
        } catch (e) {
          print('⚠️ Response is not JSON (possibly HTML error page)');
          print('Parse Error: $e');
          print('Response preview: ${decodedBody.substring(0, decodedBody.length > 500 ? 500 : decodedBody.length)}');

          _handleApiError(
            response.statusCode,
            'Server returned non-JSON response (possibly HTML error page)',
          );
        }
        print('========================\n');
        return null;
      }
    } on TimeoutException {
      CustomWidgets.showSnackBar('Error', 'Request timeout. Please try again.', Colors.red);
      return null;
    } on SocketException {
      CustomWidgets.showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      CustomWidgets.showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
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

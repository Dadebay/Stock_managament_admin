// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ApiService {
  final AuthStorage _auth = AuthStorage();
  Future<dynamic> getRequest(
    String endpoint, {
    required bool requiresToken,
    Future<dynamic> Function(dynamic)? handleSuccess,
  }) async {
    try {
      final token = await _auth.getToken();
      final headers = <String, String>{
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      // DÜZELTME: Gelen yanıtın ham baytlarını UTF-8 olarak çözüyoruz.
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};

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
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(endpoint), headers: headers);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse(endpoint),
            headers: headers,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }

      // DÜZELTME: Yanıtı her zaman önce UTF-8 olarak çözüyoruz.
      final decodedBody = utf8.decode(response.bodyBytes);

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
        // DÜZELTME: Hata yanıtını da UTF-8 olarak çözüyoruz.
        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};
        // Hata mesajı artık bir Map olabilir, bu yüzden toString() kullanmak daha güvenli.
        String errorMessage = responseJson.toString();

        _handleApiError(
          response.statusCode,
          errorMessage,
        );
        return null;
      }
    } on SocketException {
      CustomWidgets.showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    }
  }

  void _handleApiError(int statusCode, String message) {
    String errorMessage = 'anErrorOccurred'.tr;
    switch (statusCode) {
      case 400:
        errorMessage = 'invalidNumber'.tr;
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

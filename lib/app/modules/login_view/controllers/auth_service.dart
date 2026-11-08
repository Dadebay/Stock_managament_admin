// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'package:stock_managament_admin/app/modules/login_view/views/login_view.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'dart:async';

import 'package:http/http.dart' as http;

class AuthStorage {
  final storage = AppStorage();

  Future<bool> logout() async {
    await storage.remove('AccessToken');
    await storage.remove('RefreshToken');
    await storage.remove('isAdmin');
    ApiService.clearCache();
    return storage.read('AccessToken') == null ? true : false;
  }

  /////////////////////////////////////////User Token///////////////////////////////////
  Future<bool> setToken(String token) async {
    ApiService.clearCache();
    await storage.write('AccessToken', token);
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<String?> getToken() async {
    return storage.read('AccessToken');
  }

  Future<bool> removeToken() async {
    await storage.remove('AccessToken');
    return storage.read('AccessToken') == null ? true : false;
  }

/////////////////////////////////////////User Refresh Token///////////////////////////////////

  Future<bool> setRefreshToken(String token) async {
    await storage.write('RefreshToken', token);
    return storage.read('RefreshToken') != null;
  }

  Future<String?> getRefreshToken() async {
    return storage.read('RefreshToken');
  }

  Future<bool> getAdminStatus() async {
    return storage.read('isAdmin') ?? false;
  }

  Future<bool> setAdmin(bool token) async {
    await storage.write('isAdmin', token);
    return storage.read('isAdmin') == null ? false : true;
  }

  Future<bool> removeRefreshToken() async {
    await storage.remove('RefreshToken');
    return storage.read('RefreshToken') == null ? true : false;
  }
}

class SignInService {
  final AuthStorage _auth = AuthStorage();

  Future<bool> updateAdminStatus(String userName) async {
    await _auth.setAdmin(false);
    final data = await ApiService()
        .getRequest(ApiConstants.users, requiresToken: true, useCache: false);
    final users = data is Map ? data['results'] : data;
    if (users is! List) return false;
    final isAdmin = users.whereType<Map>().any(
        (user) => user['username'] == userName && user['is_superuser'] == true);
    await _auth.setAdmin(isAdmin);
    return isAdmin;
  }

  Future<dynamic> logOut(BuildContext context) async {
    final token = await _auth.getToken();
    await _auth.logout();
    if (token != null && token.isNotEmpty) {
      unawaited(_revokeToken(token));
    }
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginView()));
    }
  }

  Future<void> _revokeToken(String token) async {
    try {
      await http.get(Uri.parse(ApiConstants.logOut), headers: {
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Local sign-out must succeed even when the server is unreachable.
    }
  }

  Future login({required String username, required String password}) async {
    final response = await ApiService().handleApiRequest(
      endpoint: ApiConstants.authUrl,
      method: 'POST',
      body: <String, dynamic>{
        'username': username,
        'password': password,
      },
      requiresToken: false,
      handleSuccess: (responseJson) async {
        if (responseJson is Map && responseJson['access'] is String) {
          await _auth.setToken(responseJson['access'] as String);
          if (responseJson['refresh'] is String) {
            await _auth.setRefreshToken(responseJson['refresh'] as String);
          } else {
            await _auth.removeRefreshToken();
          }
        }
        return responseJson;
      },
    );
    return response is Map && response['access'] is String ? response : null;
  }
}

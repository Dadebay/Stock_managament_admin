// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class AuthStorage {
  final storage = GetStorage();

  Future<bool> logout() async {
    await storage.remove('AccessToken');
    await storage.remove('RefreshToken');
    return storage.read('AccessToken') == null ? true : false;
  }

  /////////////////////////////////////////User Token///////////////////////////////////
  Future<bool> setToken(String token) async {
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
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<String?> getRefreshToken() async {
    return storage.read('RefreshToken');
  }

  Future<bool> removeRefreshToken() async {
    await storage.remove('RefreshToken');
    return storage.read('RefreshToken') == null ? true : false;
  }
}

class SignInService {
  final AuthStorage _auth = AuthStorage();

  Future login({required String username, required String password}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.authUrl,
      method: 'POST',
      body: <String, dynamic>{
        'username': username,
        'password': password,
      },
      requiresToken: false,
      handleSuccess: (responseJson) async {
        if (responseJson['access'] != null) {
          await _auth.setToken(responseJson['access']);
          _auth.getToken().then((value) {
            print('Access Token: $value');
          });
          await _auth.setRefreshToken(responseJson['refresh']);
        }
        return responseJson;
      },
    );
  }
}

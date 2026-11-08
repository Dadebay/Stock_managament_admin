import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(AppStorage.init);
  setUp(() async {
    await (await SharedPreferences.getInstance()).clear();
    ApiService.clearCache();
  });

  test('cached responses never cross staff sessions', () async {
    final auth = AuthStorage();
    final requests = <String>[];
    final client = MockClient((request) async {
      final authorization = request.headers['Authorization']!;
      requests.add(authorization);
      return http.Response('{"session":"$authorization"}', 200);
    });
    final api = ApiService(client: client, auth: auth);

    await auth.setToken('first');
    final first =
        await api.getRequest('https://example.test/stock', requiresToken: true);
    await auth.setToken('second');
    final second =
        await api.getRequest('https://example.test/stock', requiresToken: true);

    expect(first['session'], 'Bearer first');
    expect(second['session'], 'Bearer second');
    expect(requests, ['Bearer first', 'Bearer second']);
    client.close();
  });

  test('a successful write invalidates the cached inventory', () async {
    final auth = AuthStorage();
    await auth.setToken('staff');
    var revision = 1;
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        revision = 2;
        return http.Response('{"ok":true}', 201);
      }
      return http.Response('{"revision":$revision}', 200);
    });
    final api = ApiService(client: client, auth: auth);

    expect(
        (await api.getRequest('https://example.test/stock',
            requiresToken: true))['revision'],
        1);
    await api.handleApiRequest(
        endpoint: 'https://example.test/stock',
        requiresToken: true,
        method: 'POST',
        body: {'quantity': 2});
    expect(
        (await api.getRequest('https://example.test/stock',
            requiresToken: true))['revision'],
        2);
    client.close();
  });

  test('offline local sign-out clears tokens and admin role', () async {
    final auth = AuthStorage();
    await auth.setToken('staff');
    await auth.setRefreshToken('refresh');
    await auth.setAdmin(true);

    expect(await auth.logout(), isTrue);
    expect(await auth.getToken(), isNull);
    expect(await auth.getRefreshToken(), isNull);
    expect(await auth.getAdminStatus(), isFalse);
  });

  test('missing client balance is not displayed as zero', () {
    final client = ClientModel.fromJson({
      'id': 1,
      'name': 'Client',
      'address': '',
      'phone': null,
    });
    expect(client.sumPrice, isNull);
    expect(client.phone, isEmpty);
  });
}

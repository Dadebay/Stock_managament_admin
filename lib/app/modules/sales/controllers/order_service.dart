import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderService {
  void _printSection(String title) {
    print('\n========== $title ==========');
  }

  void _printMap(String title, Map<String, dynamic> map) {
    print('$title:');
    map.forEach((key, value) {
      print('  - $key: $value');
    });
  }

  String? _normalizeClientPhone(String? phone) {
    if (phone == null) return null;
    final normalized = phone.trim();
    if (normalized.isEmpty || normalized == '+993') return null;
    return normalized;
  }

  String? _normalizeOptionalText(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _extractHtmlErrorSummary(String html) {
    final titleMatch =
        RegExp(r'<title>(.*?)</title>', dotAll: true).firstMatch(html);
    final exceptionTypeMatch =
        RegExp(r'Exception Type:</th>\\s*<td>(.*?)</td>', dotAll: true)
            .firstMatch(html);
    final exceptionValueMatch =
        RegExp(r'Exception Value:</th>\\s*<td><pre>(.*?)</pre>', dotAll: true)
            .firstMatch(html);

    final title = titleMatch?.group(1)?.replaceAll(RegExp(r'\\s+'), ' ').trim();
    final exceptionType =
        exceptionTypeMatch?.group(1)?.replaceAll(RegExp(r'\\s+'), ' ').trim();
    final exceptionValue =
        exceptionValueMatch?.group(1)?.replaceAll(RegExp(r'\\s+'), ' ').trim();

    return 'title=$title | exceptionType=$exceptionType | exceptionValue=$exceptionValue';
  }

  static const int pageSize = 30;

  Future<OrdersPage> getOrders({int page = 1, String? search, String? status}) async {
    final uri = Uri.parse(ApiConstants.order).replace(queryParameters: {
      'page': '$page',
      'page_size': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    });
    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);

    if (data is Map && data['results'] != null) {
      final results = (data['results'] as List).map((item) => OrderModel.fromJson(item)).toList();
      final count = data['count'] ?? results.length;
      return OrdersPage(
        orders: results,
        page: page,
        totalPages: count == 0 ? 1 : (count / pageSize).ceil(),
        count: count,
        stats: OrderStats.fromJson(data['stats'] as Map<String, dynamic>?),
      );
    } else if (data is List) {
      final results = data.map((item) => OrderModel.fromJson(item)).toList();
      return OrdersPage(orders: results, page: 1, totalPages: 1, count: results.length, stats: OrderStats.fromJson(null));
    } else {
      return OrdersPage(orders: [], page: 1, totalPages: 1, count: 0, stats: OrderStats.fromJson(null));
    }
  }

  Future<List<ProductModel>> getOrderProduct(int id) async {
    final data = await ApiService().getRequest(
        "${ApiConstants.getOrderProducts}$id/",
        requiresToken: true);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.product != null)
          .toList();
    } else {
      return [];
    }
  }

  Future<OrderModel?> createOrder(
      {required OrderModel model,
      required List<Map<String, int>> products}) async {
    print('\n===== CREATE ORDER REQUEST =====');
    print('Endpoint: ${ApiConstants.order}');

    // Discount değerini kontrol et
    final discountValue = double.tryParse(model.discount.toString()) ?? 0.0;
    print('Discount value: $discountValue');

    final body = <String, dynamic>{
      'status': model.status,
      'gaplama': model.gaplama,
      'date': model.date,
      'datetime': model.date,
      'name': model.name,
      'clientName': model.clientDetailModel!.name,
      'clientAddress': model.clientDetailModel!.address,
      'clientPhone': model.clientDetailModel!.phone,
      'discount': discountValue,
      'coupon': model.coupon,
      'description': model.description,
      "count": int.parse(model.count.toString()),
      'products': products,
    };

    print('Request body: $body');
    print('Products: $products');
    print('==============================\n');

    final responseJson = await ApiService().handleApiRequest(
      endpoint: ApiConstants.order,
      method: 'POST',
      body: body,
      requiresToken: true,
    );

    print('\n===== CREATE ORDER RESPONSE =====');
    print('Response: $responseJson');
    print('Response type: ${responseJson.runtimeType}');
    print('=================================\n');

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      return OrderModel.fromJson(responseJson);
    } else {
      print('⚠️ Response is null or not a Map<String, dynamic>');
      return null;
    }
  }

  Future<OrderModel?> editOrderManually({required OrderModel model}) async {
    final AuthStorage auth = AuthStorage();

    final token = await auth.getToken();
    final url = Uri.parse("${ApiConstants.order}${model.id}/");
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final normalizedClientName =
        _normalizeOptionalText(model.clientDetailModel?.name);
    final normalizedClientAddress =
        _normalizeOptionalText(model.clientDetailModel?.address);
    final normalizedClientPhone =
        _normalizeClientPhone(model.clientDetailModel?.phone);

    final rawBody = {
      'status': int.parse(model.status),
      'gaplama': model.gaplama,
      'date': model.date,
      'datetime': model.date,
      'name': model.name,
      'client': model.clientID,
      'clientName': normalizedClientName,
      'clientAddress': normalizedClientAddress,
      'clientPhone': normalizedClientPhone,
      'discount': double.tryParse(model.discount),
      'coupon': model.coupon,
      'description': model.description,
      "count": model.count,
      "totalsum": model.totalsum,
      "totalchykdajy": model.totalchykdajy,
    };
    final body = json.encode(rawBody);

    _printSection('EDIT ORDER REQUEST START');
    print('Request method: PUT');
    print('Request URL: $url');
    print('Order ID: ${model.id}');
    print('Token exists: ${token != null && token.isNotEmpty}');
    print('Token length: ${token?.length ?? 0}');
    _printMap('Request headers', headers);
    _printMap('Request body (raw map)', rawBody);
    print('Request body (json): $body');

    try {
      final response = await http.put(url, headers: headers, body: body);

      _printSection('EDIT ORDER RESPONSE RECEIVED');
      print('Status code: ${response.statusCode}');
      print('Reason phrase: ${response.reasonPhrase}');
      print('Response headers: ${response.headers}');
      if (response.body.length > 3000) {
        print('Response body length: ${response.body.length}');
        print(
            'Response body preview (first 3000 chars): ${response.body.substring(0, 3000)}');
      } else {
        print('Response body (raw): ${response.body}');
      }

      final contentType = response.headers['content-type'] ?? '';
      if (response.statusCode >= 500 && contentType.contains('text/html')) {
        print(
            'Server returned HTML error page. Parsed summary: ${_extractHtmlErrorSummary(response.body)}');
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
        print('Response body type (decoded): ${decoded.runtimeType}');
        print('Response body (decoded): $decoded');
      } catch (decodeError, decodeStack) {
        print('Response decode error: $decodeError');
        print('Response decode stack: $decodeStack');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decoded is Map<String, dynamic>) {
          final updatedOrder = OrderModel.fromJson(decoded);
          _printSection('EDIT ORDER SUCCESS');
          print('Updated order id from response: ${updatedOrder.id}');
          return updatedOrder;
        }

        print(
            'Edit success status but response JSON is not Map<String, dynamic>.');
        return null;
      }

      _printSection('EDIT ORDER FAILED');
      print('Non-success response. UI should not treat this as saved.');
      return null;
    } catch (error, stackTrace) {
      _printSection('EDIT ORDER EXCEPTION');
      print('Error: $error');
      print('StackTrace: $stackTrace');
      return null;
    } finally {
      _printSection('EDIT ORDER REQUEST END');
    }
  }

  Future<bool> deleteOrder({required int orderId}) async {
    final response = await ApiService().handleApiRequest(
      endpoint: "${ApiConstants.order}$orderId/",
      method: 'DELETE',
      requiresToken: true,
    );

    // DEĞİŞİKLİK: Yanıtı kontrol et.
    // Yanıt null değilse ve 'success': true içeriyorsa veya doğrudan bir Map ise başarılıdır.
    if (response != null && response is Map && response['success'] == true) {
      return true;
    }
    // Eski handleApiRequest uyumluluğu için
    if (response != null && response is Map && response['statusCode'] == 204) {
      return true;
    }

    return false;
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderService {
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

  static const int pageSize = 30;

  Future<OrdersPage> getOrders(
      {int page = 1, String? search, String? status}) async {
    final uri = Uri.parse(ApiConstants.order).replace(queryParameters: {
      'page': '$page',
      'page_size': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    });
    final data =
        await ApiService().getRequest(uri.toString(), requiresToken: true);

    if (data is Map && data['results'] != null) {
      final results = (data['results'] as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();
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
      return OrdersPage(
          orders: results,
          page: 1,
          totalPages: 1,
          count: results.length,
          stats: OrderStats.fromJson(null));
    } else {
      return OrdersPage(
          orders: [],
          page: 1,
          totalPages: 1,
          count: 0,
          stats: OrderStats.fromJson(null));
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
    // Discount değerini kontrol et
    final discountValue = double.tryParse(model.discount.toString()) ?? 0.0;

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

    final responseJson = await ApiService().handleApiRequest(
      endpoint: ApiConstants.order,
      method: 'POST',
      body: body,
      requiresToken: true,
    );

    if (responseJson is Map<String, dynamic>) {
      return OrderModel.fromJson(responseJson);
    }
    // A successful empty response still means the order was accepted.
    if (responseJson is int &&
        (responseJson == 200 || responseJson == 201 || responseJson == 204)) {
      return model;
    }
    return null;
  }

  Future<OrderModel?> editOrderManually({required OrderModel model}) async {
    final AuthStorage auth = AuthStorage();

    final token = await auth.getToken();
    if (token == null || token.isEmpty) return null;
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

    try {
      final response = await http
          .put(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        ApiService.clearCache();
        if (response.bodyBytes.isEmpty) return model;
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return decoded is Map<String, dynamic>
            ? OrderModel.fromJson(decoded)
            : model;
      }
      return null;
    } catch (_) {
      return null;
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

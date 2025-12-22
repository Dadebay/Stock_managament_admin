import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderService {
  // final OrderController orderController = Get.find();
  Future<List<OrderModel>> getOrders() async {
    final data = await ApiService().getRequest(ApiConstants.order, requiresToken: true);

    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => OrderModel.fromJson(item)).toList();
    } else if (data is List) {
      return (data).map((item) => OrderModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  Future<List<ProductModel>> getOrderProduct(int id) async {
    final data = await ApiService().getRequest("${ApiConstants.getOrderProducts}$id/", requiresToken: true);
    if (data is List) {
      return (data).map((item) => ProductModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  Future<OrderModel?> createOrder({required OrderModel model, required List<Map<String, int>> products}) async {
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
    final body = json.encode({
      'status': int.parse(model.status),
      'gaplama': model.gaplama,
      'date': model.date,
      'datetime': model.date,
      'name': model.name,
      'clientName': model.clientDetailModel?.name,
      'clientAddress': model.clientDetailModel?.address,
      'clientPhone': model.clientDetailModel?.phone,
      'discount': double.tryParse(model.discount),
      'coupon': model.coupon,
      'description': model.description,
      "count": model.count,
      "totalsum": model.totalsum,
      "totalchykdajy": model.totalchykdajy,
    });
    final response = await http.put(url, headers: headers, body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final updatedOrder = OrderModel.fromJson(jsonResponse);
      Get.back();

      return updatedOrder;
    } else {
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

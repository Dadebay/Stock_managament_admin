import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderService {
  final OrderController orderController = Get.find();
  Future<List<OrderModel>> getOrders() async {
    final data = await ApiService().getRequest(ApiConstants.order, requiresToken: true);
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => OrderModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => OrderModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future<List<SearchModel>> getOrderProduct(int id) async {
    final data = await ApiService().getRequest(ApiConstants.order + "$id/", requiresToken: true);
    if (data is Map && data['product_detail'] != null) {
      return (data['product_detail'] as List).map((item) => SearchModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => SearchModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future createOrder({required OrderModel model, required List<Map<String, dynamic>> products}) async {
    final body = <String, dynamic>{
      'status': model.status,
      'gaplama': model.gaplama,
      'date': model.date,
      'datetime': model.date,
      'name': model.name,
      'clientName': model.clientDetailModel!.name,
      'clientAddress': model.clientDetailModel!.address,
      'clientPhone': model.clientDetailModel!.phone,
      'discount': double.tryParse(model.discount.toString()),
      'coupon': model.coupon,
      'description': model.description,
      "count": int.parse(model.count.toString()),
      'products': products,
    };
    print(body);
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.order,
      method: 'POST',
      body: body,
      requiresToken: true,
      handleSuccess: (responseJson) {
        print(responseJson);
        if (responseJson.isNotEmpty) {
          orderController.addOrder(OrderModel.fromJson(responseJson));
          Get.back();
          CustomWidgets.showSnackBar('success'.tr, 'Order added successfully'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Order not added'.tr, Colors.red);
        }
      },
    );
  }

  Future<OrderModel?> editOrderManually({required OrderModel model}) async {
    final AuthStorage _auth = AuthStorage();

    final token = await _auth.getToken();
    final url = Uri.parse(ApiConstants.order + "${model.id}/");
    print(url);
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
      // 'products': model.products
    });
    print(body);
    print(model.products);

    final response = await http.put(url, headers: headers, body: body);
    print(body);
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final updatedOrder = OrderModel.fromJson(jsonResponse);
      Get.back();

      return updatedOrder;
    } else {
      return null;
    }
  }

  Future deleteOrder({required OrderModel model}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.order + "${model.id}/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          orderController.deleteOrder(model: model);

          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }
}

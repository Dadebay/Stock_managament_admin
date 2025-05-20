import 'package:get/get.dart';
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
      'discount': int.parse(model.discount.toString()),
      'coupon': model.coupon,
      'description': model.description,
      "count": int.parse(model.count.toString()),
      'products': products,
    };

    return ApiService().handleApiRequest(
      endpoint: ApiConstants.order,
      method: 'POST',
      body: body,
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          print(responseJson);
          print(responseJson);
          print(responseJson);
          print(responseJson);
          print(responseJson);
          print(OrderModel.fromJson(responseJson));
          orderController.addOrder(OrderModel.fromJson(responseJson));
          Get.back();
          CustomWidgets.showSnackBar('success'.tr, 'Order added successfully'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Order not added'.tr, Colors.red);
        }
      },
    );
  }

  Future editOrder({required OrderModel model}) async {
    String apiDate = model.date;
    if (model.date.contains(',')) {
      apiDate = model.date.split(',')[0].trim();
    } else if (model.date.length > 10) {
      apiDate = model.date.substring(0, 10);
    }

    final body = <String, dynamic>{
      'id': model.id,
      'status': model.status,
      'gaplama': model.gaplama,
      'date': apiDate,
      'datetime': model.date,
      'name': model.name,
      'clientName': model.clientDetailModel!.name,
      'clientAddress': model.clientDetailModel!.address,
      'clientPhone': model.clientDetailModel!.phone,
      'discount': int.tryParse(model.discount.toString().replaceAll('%', '').trim()) ?? 0,
      'coupon': model.coupon,
      'description': model.description,
      "count": model.count,
    };

    return ApiService().handleApiRequest(
      endpoint: ApiConstants.order + "${model.id}/",
      method: 'PUT',
      body: body,
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          final updatedOrder = OrderModel.fromJson(responseJson);
          orderController.editOrderInList(updatedOrder);
          Get.back();

          CustomWidgets.showSnackBar('success'.tr, 'Order updated successfully'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Order not updated'.tr, Colors.red);
        }
      },
    );
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

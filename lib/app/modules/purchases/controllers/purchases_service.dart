import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class PurchasesService {
  final PurchasesController purchasesController = Get.find();

  Future<List<PurchasesModel>> getPurchases() async {
    final data = await ApiService().getRequest(ApiConstants.purchases, requiresToken: true);
    if (data is Map && data['data'] != null) {
      return (data['data'] as List).map((item) => PurchasesModel.fromJson(item)).toList();
    } else if (data is List) {
      return (data).map((item) => PurchasesModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  Future<List<ProductModelPurchases>> getPurchasesByID(int id) async {
    final data = await ApiService().getRequest(ApiConstants.getPurchasesID + "$id/", requiresToken: true);
    if (data is Map) {
      return (data as List).map((item) => ProductModelPurchases.fromJson(item)).toList();
    } else if (data is List) {
      return (data).map((item) => ProductModelPurchases.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  Future<PurchasesModel?> editOrderManually({required PurchasesModel model}) async {
    final AuthStorage _auth = AuthStorage();

    final token = await _auth.getToken();
    final url = Uri.parse(ApiConstants.purchases + "${model.id}/");
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final body =
        json.encode({'title': model.title, 'date': model.date, 'source': model.source, 'cost': double.tryParse(model.cost) ?? 0, 'description': model.description, 'products': model.products});
    final response = await http.put(url, headers: headers, body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final updatedOrder = PurchasesModel.fromJson(jsonResponse);
      purchasesController.editClient(updatedOrder);
      Get.back();

      CustomWidgets.showSnackBar("Success", "Purchase updated successfully", Colors.green);

      return updatedOrder;
    } else {
      return null;
    }
  }

  Future addPurchase({required PurchasesModel model, required List<Map<String, dynamic>> products}) async {
    final body = <String, dynamic>{
      'title': model.title,
      'date': model.date,
      'source': model.source,
      'cost': double.parse(double.parse(model.cost).toStringAsFixed(2)),
      'description': model.description,
      "count": int.parse(products.length.toString()),
      'products': products,
    };
    print(body);
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.purchases,
      method: 'POST',
      body: body,
      requiresToken: true,
      handleSuccess: (responseJson) {
        print(responseJson);
        if (responseJson.isNotEmpty) {
          purchasesController.addClient(PurchasesModel.fromJson(responseJson));
          getPurchases();

          Get.back();
          CustomWidgets.showSnackBar('success'.tr, 'Purchases added successfully'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Purchases not added'.tr, Colors.red);
        }
      },
    );
  }

  Future deletePurchases({required int id}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.purchases + "$id/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          purchasesController.deleteProduct(id);

          CustomWidgets.showSnackBar('success'.tr, 'Product Deleted'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Product Not Deleted'.tr, Colors.red);
        }
      },
    );
  }
}

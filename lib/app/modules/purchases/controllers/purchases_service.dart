import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class PurchasesService {
  static const int pageSize = 30;

  final PurchasesController purchasesController = Get.find();

  Future<PurchasesPage> getPurchases({int page = 1, String? search}) async {
    final uri = Uri.parse(ApiConstants.purchases).replace(queryParameters: {
      'page': '$page',
      'page_size': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);

    if (data is Map && data['results'] != null) {
      final results = (data['results'] as List).map((item) => PurchasesModel.fromJson(item)).toList();
      final count = data['count'] ?? results.length;
      return PurchasesPage(
        purchases: results,
        page: page,
        totalPages: count == 0 ? 1 : (count / pageSize).ceil(),
        count: count,
        summ: double.tryParse('${data['summ'] ?? 0}') ?? 0.0,
        totalProductCount: int.tryParse('${data['total_product_count'] ?? 0}') ?? 0,
      );
    } else if (data is Map && data['data'] != null) {
      final results = (data['data'] as List).map((item) => PurchasesModel.fromJson(item)).toList();
      return PurchasesPage(
        purchases: results,
        page: 1,
        totalPages: 1,
        count: results.length,
        summ: double.tryParse('${data['summ'] ?? 0}') ?? 0.0,
        totalProductCount: int.tryParse('${data['total_product_count'] ?? 0}') ?? PurchasesController.totalCountOf(results),
      );
    } else if (data is List) {
      final results = data.map((item) => PurchasesModel.fromJson(item)).toList();
      return PurchasesPage(
        purchases: results,
        page: 1,
        totalPages: 1,
        count: results.length,
        summ: PurchasesController.totalCostOf(results),
        totalProductCount: PurchasesController.totalCountOf(results),
      );
    } else {
      return PurchasesPage(purchases: [], page: 1, totalPages: 1, count: 0, summ: 0, totalProductCount: 0);
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
      CustomWidgets.showSnackBar("Success", "Purchase updated successfully", Colors.green);
      await Future.delayed(const Duration(milliseconds: 100));
      Get.back();

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
      handleSuccess: (responseJson) async {
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

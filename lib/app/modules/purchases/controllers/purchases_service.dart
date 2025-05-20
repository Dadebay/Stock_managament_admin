import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class PurchasesService {
  final PurchasesController purchasesController = Get.find();

  Future<List<PurchasesModel>> getPurchases() async {
    final data = await ApiService().getRequest(ApiConstants.purchases, requiresToken: true);
    if (data is Map && data['data'] != null) {
      return (data['data'] as List).map((item) => PurchasesModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => PurchasesModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future<List<SearchModel>> getPurchasesByID(int id) async {
    final data = await ApiService().getRequest(ApiConstants.purchases + "$id/", requiresToken: true);
    if (data is Map && data['product_detail'] != null) {
      return (data['product_detail'] as List).map((item) => SearchModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => SearchModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future addPurchase({required PurchasesModel model, required List<Map<String, dynamic>> products}) async {
    final body = <String, dynamic>{
      'title': model.title,
      'date': model.date,
      'source': model.source,
      'cost': double.parse(model.cost.toString()),
      'description': model.description,
      "count": int.parse(model.count.toString()),
      'products': products,
    };

    return ApiService().handleApiRequest(
      endpoint: ApiConstants.purchases,
      method: 'POST',
      body: body,
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          purchasesController.addClient(PurchasesModel.fromJson(responseJson));
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

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ProductsService {
  final SeacrhViewController searchViewController = Get.find();

  Future<List<ProductModel>> getProducts() async {
    final data = await ApiService().getRequest(ApiConstants.products, requiresToken: true);
    if (data != null && data['results'] != null) {
      print(data);
      return (data['results'] as List).map((item) => ProductModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future<ProductModel?> getProductByID(String id) async {
    final data = await ApiService().getRequest('${ApiConstants.products}/$id/', requiresToken: true);
    if (data != null && data['results'] != null) {
      print(data);
      return ProductModel.fromJson(data['results']);
    } else {
      return null;
    }
  }

  Future deleteProduct({required int id}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.products + "$id/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          searchViewController.deleteProduct(id);

          CustomWidgets.showSnackBar('success'.tr, 'Product Deleted'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Product Not Deleted'.tr, Colors.red);
        }
      },
    );
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_controller.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class FourInOnePageService {
  final FourInOnePageController fourInOnePageController = Get.find<FourInOnePageController>();

  Future<List<FourInOneModel>> getData({required String url}) async {
    final data = await ApiService().getRequest(url, requiresToken: true);
    if (data != null && data['results'] != null) {
      return (data['results'] as List).map((item) => FourInOneModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future addFourInOne({required FourInOneModel model, String? location, required String url, required String key}) async {
    return ApiService().handleApiRequest(
      endpoint: url,
      method: 'POST',
      body: location != null
          ? <String, dynamic>{
              'name': model.name,
              'notes': model.notes,
              'address': model.address,
            }
          : <String, dynamic>{
              'name': model.name,
              'notes': model.notes,
            },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          final model = FourInOneModel.fromJson(responseJson);
          fourInOnePageController.addFourInOne(key, model);
          Get.back();

          CustomWidgets.showSnackBar('success'.tr, 'Added Successfully '.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot add please try again '.tr, Colors.red);
        }
        Get.back();
      },
    );
  }

  Future editFourInOne({required FourInOneModel model, String? location, required String key, required String url}) async {
    return ApiService().handleApiRequest(
      endpoint: url + "${model.id}/",
      method: 'PUT',
      body: location != null
          ? <String, dynamic>{
              'name': model.name,
              'notes': model.notes,
              'address': model.address,
            }
          : <String, dynamic>{
              'name': model.name,
              'notes': model.notes,
            },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          final model = FourInOneModel.fromJson(responseJson);
          fourInOnePageController.editFourInOne(key, model);
          Get.back();

          CustomWidgets.showSnackBar('success'.tr, 'Edited succesfully'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot edit please try again'.tr, Colors.red);
        }
      },
    );
  }

  Future deleteFourInOne({required FourInOneModel model, required String url, required String key}) async {
    return ApiService().handleApiRequest(
      endpoint: url + "${model.id}/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          fourInOnePageController.deleteFourInOne(key, model.id!);
          CustomWidgets.showSnackBar('success'.tr, 'Deleted Successfully'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot delete please try again'.tr, Colors.red);
        }
      },
    );
  }
}

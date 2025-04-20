import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_controller.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class FourInOnePageService {
  final FourInOnePageController expencesController = Get.find<FourInOnePageController>();

  Future<List<FourInOneModel>> getData({required String url}) async {
    print(url);
    final data = await ApiService().getRequest(url, requiresToken: true);
    if (data != null && data['results'] != null) {
      return (data['results'] as List).map((item) => FourInOneModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future addFourInOne({required FourInOneModel model, required BuildContext context}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.expences,
      method: 'POST',
      body: <String, dynamic>{
        'name': model.name,
        'notes': model.notes,
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          Navigator.of(context).pop();
          final model = FourInOneModel.fromJson(responseJson);
          // expencesController.addExpences(model);
          CustomWidgets.showSnackBar('success'.tr, 'Expences added'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot add expence please try again '.tr, Colors.red);
        }
      },
    );
  }

  Future editFourInOne({required FourInOneModel model, required BuildContext context}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.expences + "${model.id}/",
      method: 'PUT',
      body: <String, dynamic>{
        'name': model.name,
        'notes': model.notes,
        // 'date': model.date,
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        print(responseJson);
        if (responseJson.isNotEmpty) {
          Navigator.of(context).pop();
          final model = FourInOneModel.fromJson(responseJson);
          // expencesController.editExpences(model);
          CustomWidgets.showSnackBar('success'.tr, 'Expences added'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot add expence please try again '.tr, Colors.red);
        }
      },
    );
  }

  Future deleteExpence({required FourInOneModel model}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.expences + "${model.id}/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        // expencesController.deleteExpences(model);
        if (responseJson.isNotEmpty) {
          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }
}

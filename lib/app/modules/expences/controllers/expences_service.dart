import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ExpencesService {
  final ExpencesController expencesController = Get.find<ExpencesController>();

  Future<List<ExpencesModel>> getExpences() async {
    final data = await ApiService().getRequest(ApiConstants.expences, requiresToken: true);
    if (data != null && data['results'] != null) {
      return (data['results'] as List).map((item) => ExpencesModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future addExpence({required ExpencesModel model, required BuildContext context}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.expences,
      method: 'POST',
      body: <String, dynamic>{
        'name': model.name,
        'cost': model.cost,
        'notes': model.note,
        // 'date': model.date,
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          Navigator.of(context).pop();
          final model = ExpencesModel.fromJson(responseJson);
          expencesController.addExpences(model);
          CustomWidgets.showSnackBar('success'.tr, 'Expences added'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot add expence please try again '.tr, Colors.red);
        }
      },
    );
  }

  Future editExpence({required ExpencesModel model, required BuildContext context}) async {
    final ExpencesController expencesController = Get.find<ExpencesController>();

    return ApiService().handleApiRequest(
      endpoint: ApiConstants.expences + "${model.id}/",
      method: 'PUT',
      body: <String, dynamic>{
        'name': model.name,
        'cost': model.cost,
        'notes': model.note,
        // 'date': model.date,
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        print(responseJson);
        if (responseJson.isNotEmpty) {
          Navigator.of(context).pop();
          final model = ExpencesModel.fromJson(responseJson);
          expencesController.editExpences(model);
          CustomWidgets.showSnackBar('success'.tr, 'Expences added'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot add expence please try again '.tr, Colors.red);
        }
      },
    );
  }

  Future deleteExpence({required ExpencesModel model}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.expences + "${model.id}/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        expencesController.deleteExpences(model);
        if (responseJson.isNotEmpty) {
          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }
}

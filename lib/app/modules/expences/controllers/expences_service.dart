import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ExpencesService {
  final ExpencesController expencesController = Get.find<ExpencesController>();

  Future<List<ExpencesModel>> getExpences() async {
    final data = await ApiService().getRequest(ApiConstants.expences, requiresToken: true);
    if (data is Map && data['data'] != null) {
      return (data['data'] as List).map((item) => ExpencesModel.fromJson(item)).toList().toList();
    } else if (data is List) {
      return (data).map((item) => ExpencesModel.fromJson(item)).toList().toList();
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
        'date': model.date,
        'notes': model.note,
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
        'date': model.date,
        'notes': model.note,
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        (responseJson);
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
          CustomWidgets.showSnackBar("deleted", "${model.name} " + "Expence deleted".tr, ColorConstants.redColor);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot delete item please try again '.tr, Colors.red);
        }
      },
    );
  }
}

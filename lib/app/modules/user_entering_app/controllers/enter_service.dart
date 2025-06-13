import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_controller.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class EnterService {
  final EnterController clientsController = Get.find();
  Future<List<EnterModel>> getClients() async {
    final uri = Uri.parse("${ApiConstants.users}");
    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);
    print(data);
    print(data);
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => EnterModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => EnterModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future addClient({required EnterModel model}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.register,
      method: 'POST',
      body: <String, dynamic>{
        'username': model.username,
        'password': model.password,
        'is_superuser': model.isSuperUser,
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          clientsController.addClient(model);
          Get.back();

          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }

  Future editClients({required EnterModel model}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.users + "${model.id}/",
      method: 'PUT',
      body: <String, dynamic>{
        'username': model.username,
        'password': model.password,
        'is_superuser': model.isSuperUser,
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          clientsController.editClient(EnterModel.fromJson(responseJson));
          Get.back();

          CustomWidgets.showSnackBar('success'.tr, 'Edited succesfully'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Cannot edit please try again'.tr, Colors.red);
        }
      },
    );
  }

  Future deleteClient({required int id}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.users + "$id/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ClientsService {
  final ClientsController clientsController = Get.find();
  Future<List<ClientModel>> getClients() async {
    final data = await ApiService().getRequest(ApiConstants.clients, requiresToken: true);
    if (data != null && data['results'] != null) {
      return (data['results'] as List).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future addClient({required ClientModel model}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.clients,
      method: 'POST',
      body: <String, dynamic>{
        'name': model.name,
        'address': model.address,
        'phone': "+993${model.phone}",
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          clientsController.addClient(ClientModel.fromJson(responseJson));
          Get.back();

          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }

  Future editClients({required ClientModel model}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.clients + "${model.id}/",
      method: 'PUT',
      body: <String, dynamic>{
        'name': model.name,
        'address': model.address,
        'phone': model.phone.contains("+993") ? model.phone : "+993${model.phone}",
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        if (responseJson.isNotEmpty) {
          clientsController.editClient(ClientModel.fromJson(responseJson));
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
      endpoint: ApiConstants.clients + "$id/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          clientsController.deleteClient(id);

          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }
}

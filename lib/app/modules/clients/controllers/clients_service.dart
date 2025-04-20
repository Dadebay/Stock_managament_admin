import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ClientsService {
  Future<List<ClientModel>> getClients() async {
    final data = await ApiService().getRequest(ApiConstants.clients, requiresToken: true);
    if (data != null && data['results'] != null) {
      return (data['results'] as List).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future addClient({required String name, required String address, required String phone, required BuildContext context}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.clients,
      method: 'POST',
      body: <String, dynamic>{
        'name': name,
        'address': address,
        'phone': "+993$phone",
      },
      requiresToken: true,
      handleSuccess: (responseJson) {
        print(responseJson);
        if (responseJson.isNotEmpty) {
          Navigator.of(context).pop();
          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
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
        print("object");
        print(responseJson);
        await getClients();

        if (responseJson.isNotEmpty) {
          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }
}

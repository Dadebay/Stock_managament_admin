import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ClientsService {
  static const int pageSize = 30;

  final ClientsController clientsController = Get.find();

  Future<ClientsPage> getClients({int page = 1, int size = pageSize, String? search}) async {
    final uri = Uri.parse(ApiConstants.clients).replace(queryParameters: {
      'page': '$page',
      'page_size': '$size',
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);

    if (data is Map && data['results'] != null) {
      final results = (data['results'] as List).map((item) => ClientModel.fromJson(item)).toList();
      final count = data['count'] ?? results.length;
      return ClientsPage(
        clients: results,
        page: page,
        totalPages: count == 0 ? 1 : (count / size).ceil(),
        count: count,
      );
    } else if (data is List) {
      final results = data.map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
      return ClientsPage(clients: results, page: 1, totalPages: 1, count: results.length);
    } else {
      return ClientsPage(clients: [], page: 1, totalPages: 1, count: 0);
    }
  }

  /// Pulls every client in as few requests as possible (server max page size), for the Excel export only.
  Future<List<ClientModel>> getAllClientsForExport() async {
    const exportPageSize = 1000;
    final List<ClientModel> all = [];
    int page = 1;
    while (true) {
      final result = await getClients(page: page, size: exportPageSize);
      all.addAll(result.clients);
      if (page >= result.totalPages || result.clients.isEmpty) break;
      page++;
    }
    return all;
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
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          clientsController.editClient(ClientModel.fromJson(responseJson));
          CustomWidgets.showSnackBar('success'.tr, 'Edited succesfully'.tr, Colors.green);
          await Future.delayed(const Duration(milliseconds: 100));
          Get.back();
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
          CustomWidgets.showSnackBar('success'.tr, 'clientAdded'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'clientNotAdded'.tr, Colors.red);
        }
      },
    );
  }
}

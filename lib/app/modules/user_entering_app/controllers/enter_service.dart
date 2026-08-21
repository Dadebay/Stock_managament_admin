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
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          clientsController.editClient(EnterModel.fromJson(responseJson));
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

class LogService {
  static const int pageSize = 30;

  Future<LogsPage> fetchLogs({int page = 1}) async {
    final uri = Uri.parse(ApiConstants.logs).replace(queryParameters: {
      'page': '$page',
      'page_size': '$pageSize',
    });
    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);

    if (data is Map && data['results'] != null) {
      return LogsPage(
        logs: (data['results'] as List).map((e) => LogModel.fromJson(e)).toList(),
        page: data['page'] ?? page,
        totalPages: data['total_pages'] ?? 1,
        count: data['count'] ?? (data['results'] as List).length,
      );
    } else if (data is List) {
      return LogsPage(logs: data.map((e) => LogModel.fromJson(e)).toList(), page: 1, totalPages: 1, count: data.length);
    } else {
      return LogsPage(logs: [], page: 1, totalPages: 1, count: 0);
    }
  }
}

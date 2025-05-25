import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/product/constants/api_constants.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart' as api_service_file;

class HomeService {
  final api_service_file.ApiService _apiService = api_service_file.ApiService();

  Future<List<OrderModel>> getOrdersData() async {
    final data = await _apiService.getRequest(ApiConstants.order, requiresToken: true);
    print(data);
    if (data is Map && data['data'] != null && data['data'] is List) {
      return (data['data'] as List).map((item) => OrderModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => OrderModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getChartPageData() async {
    final response = await _apiService.getRequest(
      ApiConstants.getData,
      requiresToken: true,
    );
    if (response != null && response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return null;
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderController extends GetxController {
  var orders = <OrderModel>[].obs;

  var isLoading = true.obs;
  var pageLoading = true.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalCount = 0.obs;

  final OrderService _orderService = OrderService();

  // Toplamlar için Rx değişkenleri (şu anki sayfadaki siparişlerden hesaplanır)
  var sumCost = 0.0.obs;
  var sumPrice = 0.0.obs;
  var sumProductCount = 0.obs;

  String _search = '';
  String _status = '';

  @override
  void onInit() {
    super.onInit();
    fetchOrders(page: 1);
  }

  Future<void> fetchOrders({int page = 1}) async {
    try {
      pageLoading(true);
      final result = await _orderService.getOrders(
          page: page, search: _search, status: _status);
      orders.assignAll(result.orders);
      currentPage.value = result.page;
      totalPages.value = result.totalPages < 1 ? 1 : result.totalPages;
      totalCount.value = result.count;
      sumPrice.value = result.stats.totalSum;
      sumCost.value = result.stats.totalCost;
      sumProductCount.value = result.stats.count;
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      isLoading(false);
      pageLoading(false);
    }
  }

  void filterByStatus(String status) {
    _status = status;
    Get.back();
    fetchOrders(page: 1);
  }

  void clearFilter() {
    _status = '';
    Get.back();
    fetchOrders(page: 1);
  }

  void onSearchTextChanged(String word) {
    _search = word.trim();
    fetchOrders(page: 1);
  }

  Future<void> createNewOrder(
      {required OrderModel model,
      required List<Map<String, int>> products}) async {
    try {
      final newOrder =
          await _orderService.createOrder(model: model, products: products);
      print(newOrder);
      if (newOrder != null) {
        // Refetch page 1 so both the list and the shipped-order totals stay accurate.
        await fetchOrders(page: 1);
        CustomWidgets.showSnackBar(
            'success'.tr, 'Order added successfully'.tr, Colors.green);
        await Future.delayed(const Duration(milliseconds: 100));
        Get.back();
      } else {
        CustomWidgets.showSnackBar(
            'error'.tr, 'Order not added'.tr, Colors.red);
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
          'error'.tr, 'An error occurred: $e'.tr, Colors.red);
    }
  }

  Future<void> deleteOrderFromUI({required OrderModel model}) async {
    try {
      final bool success = await _orderService.deleteOrder(orderId: model.id);

      if (success) {
        // Refetch the current page so both the list and the shipped-order totals stay accurate.
        await fetchOrders(page: currentPage.value);

        Get.back();
        CustomWidgets.showSnackBar(
            'success'.tr, 'Order deleted successfully'.tr, Colors.green);
      } else {
        CustomWidgets.showSnackBar('error'.tr,
            'Failed to delete order. Please try again.'.tr, Colors.red);
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
          'error'.tr, 'An error occurred: $e'.tr, Colors.red);
    }
  }

  void editOrderInList(OrderModel updatedOrder) {
    int displayIndex = orders.indexWhere((o) => o.id == updatedOrder.id);
    if (displayIndex != -1) {
      orders[displayIndex] = updatedOrder;
    }
    // Status/amount edits can change the shipped-order totals - refresh them from the server.
    fetchOrders(page: currentPage.value);
  }

  // Bu metot OrderProductsView'de kullanıldığı için kalmalı
  dynamic getProductSortValue(SearchModel model, String key) {
    switch (key) {
      case 'name':
        return model.name;
      case 'count':
        return model.count;
      case 'price':
        return double.tryParse(model.price) ?? 0.0;
      case 'cost':
        return double.tryParse(model.cost) ?? 0.0;
      case 'brends':
        return model.brend?.name ?? '';
      case 'category':
        return model.category?.name ?? '';
      case 'location':
        return model.location?.name ?? '';
      default:
        return '';
    }
  }
}

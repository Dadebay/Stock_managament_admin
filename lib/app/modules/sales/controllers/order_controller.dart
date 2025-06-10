import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderController extends GetxController {
  RxList<OrderModel> allOrders = <OrderModel>[].obs;
  RxList<OrderModel> searchResult = <OrderModel>[].obs;

  RxDouble sumCost = 0.0.obs;
  RxDouble sumPrice = 0.0.obs;
  RxInt sumProductCount = 0.obs;

  dynamic filterByStatus(String status) {
    List<OrderModel> orderCardList = [];
    if (searchResult.isEmpty) {
      searchResult.assignAll(allOrders);
    }
    for (var element in allOrders) {
      if (element.status.toString().toLowerCase() == status.toLowerCase()) {
        orderCardList.add(element);
      }
    }
    Get.back();
    allOrders.assignAll(orderCardList);
    update();
  }

  dynamic clearFilter() {
    allOrders.assignAll(searchResult);
    Get.back();
    update();
  }

  void addOrder(OrderModel model) {
    allOrders.insert(0, model);
    calculateTotals();
  }

  dynamic deleteOrder({required OrderModel model}) async {
    allOrders.remove(model);
    if (searchResult.isNotEmpty) {
      searchResult.remove(model);
    }
    update();
    Get.back();
  }

  void calculateTotals() {
    double totalSell = 0;
    double totalCost = 0;
    int totalCount = 0;
    for (var product in allOrders) {
      final sell = double.tryParse(product.totalsum) ?? 0.0;
      final cost = double.tryParse(product.totalchykdajy) ?? 0.0;
      final count = product.count ?? 0;
      totalSell += sell * count;
      totalCost += cost * count;
      totalCount += count;
    }
    sumPrice.value = totalSell;
    sumCost.value = totalCost;
    sumProductCount.value = totalCount;
  }

  dynamic getProductSortValue(SearchModel model, String key) {
    switch (key) {
      case 'count':
        return model.count;
      case 'price':
        return model.price;
      case 'cost':
        return model.cost;
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

  void onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      searchResult.assignAll(allOrders);
      return;
    }
    List<String> searchTerms = word.trim().toLowerCase().split(' ');
    searchResult.value = allOrders.where((product) {
      final productNameString = (product.name).toLowerCase();
      final clientPhoneString = (product.clientDetailModel?.phone?.toString() ?? "").toLowerCase();
      final clientNameString = (product.clientDetailModel?.name.toString() ?? "").toLowerCase();
      return searchTerms.every((term) {
        bool termFoundInProduct = false;
        if (productNameString.contains(term)) termFoundInProduct = true;
        if (!termFoundInProduct && clientPhoneString.isNotEmpty && clientPhoneString.contains(term)) termFoundInProduct = true;
        if (!termFoundInProduct && clientNameString.isNotEmpty && clientNameString.contains(term)) termFoundInProduct = true;
        return termFoundInProduct;
      });
    }).toList();
  }

  void editOrderInList(OrderModel updatedOrder) {
    int index = allOrders.indexWhere((o) => o.id.toString() == updatedOrder.id.toString());
    if (index != -1) {
      allOrders[index] = updatedOrder;
    }
    int searchIndex = searchResult.indexWhere((o) => o.id == updatedOrder.id);
    if (searchIndex != -1) {
      searchResult[searchIndex] = updatedOrder;
    }
    calculateTotals(); // Toplamları yeniden hesapla
    update(); // UI'ı güncellemek için
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SalesController extends GetxController {
  RxList filteredOrderedProducts = [].obs;
  RxList getAllOrders = [].obs;
  final HomeController homeController = Get.put(HomeController());
  RxBool loadingDataOrders = false.obs;
  RxList orderCardList = [].obs;
  RxList orderedCardsSearchResult = [].obs;
  RxDouble sumCost = 0.0.obs;
  RxDouble sumPrice = 0.0.obs;
  RxDouble sumProductCount = 0.0.obs;

  filterProductsMine(String filterName, String filterSearchName) {
    filteredOrderedProducts.clear();
    orderCardList = getAllOrders;
    loadingDataOrders.value = true;
    for (var element in orderCardList) {
      if (element[filterName].toString().toLowerCase() == filterSearchName.toLowerCase()) {
        filteredOrderedProducts.add(element);
      }
    }

    orderCardList = filteredOrderedProducts;
    Get.back();
    Get.back();
    loadingDataOrders.value = false;
  }
}

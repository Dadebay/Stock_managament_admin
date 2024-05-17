import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SeacrhViewController extends GetxController {
  RxList searchResult = [].obs;
  RxList productsList = [].obs;
  RxList collectAllProducts = [].obs;
  RxList filteredProductsList = [].obs;
  RxBool loadingData = false.obs;
  RxBool showInGrid = false.obs;
  RxDouble sumSell = 0.0.obs;
  RxDouble sumCost = 0.0.obs;
  RxInt sumCount = 0.obs;
  RxInt sumQuantity = 0.obs;
  getClientStream() async {
    loadingData.value = true;
    sumCost.value = 0.0;
    sumSell.value = 0.0;
    sumQuantity.value = 0;
    sumCount.value = 0;
    productsList.clear();
    await FirebaseFirestore.instance.collection('products').orderBy('date', descending: true).get().then((value) {
      for (var element in value.docs) {
        productsList.add(element);
        collectAllProducts.add(element);
        countAllPricesNSells(element);
      }
    });
    sumCount.value = productsList.length;

    loadingData.value = false;
    searchResult.clear();
  }

  clearFilter() {
    sumCost.value = 0.0;
    sumSell.value = 0.0;
    sumQuantity.value = 0;
    sumCount.value = 0;
    productsList.clear();

    for (var element in collectAllProducts) {
      countAllPricesNSells(element);
      productsList.add(element);
    }
    sumCount.value = collectAllProducts.length;
  }

  countAllPricesNSells(QueryDocumentSnapshot<Map<String, dynamic>> element) {
    final String cost = element['cost'] ?? '0.0';
    final String sell = element['sell_price'] ?? '0.0';
    double a = double.tryParse(cost.replaceAll(',', '.')) ?? 0.0;
    a *= int.parse(element['quantity'].toString());
    sumCost.value += a;

    double b = double.tryParse(sell.replaceAll(',', '.')) ?? 0.0;
    b *= int.parse(element['quantity'].toString());
    sumSell.value += b;
    sumQuantity.value += int.parse(element['quantity'].toString());
  }

  onSearchTextChanged(String word) async {
    loadingData.value = true;
    searchResult.clear();
    List fullData = [];
    List<String> words = word.toLowerCase().trim().split(' ');
    fullData = productsList.where((p) {
      bool result = true;
      for (final word in words) {
        if (!p['name'].toLowerCase().contains(word)) {
          result = false;
        }
      }
      return result;
    }).toList();
    searchResult.value = fullData.toSet().toList();
    loadingData.value = false;
  }

  filterProductsMine(String filterName, String filterSearchName) {
    filteredProductsList.clear();
    sumCost.value = 0.0;
    sumSell.value = 0.0;
    sumQuantity.value = 0;
    sumCount.value = 0;
    print(productsList.length);
    productsList = collectAllProducts;
    loadingData.value = true;
    print(filteredProductsList.length);

    for (var element in productsList) {
      if (element[filterName].toString().toLowerCase() == filterSearchName.toLowerCase()) {
        print(element['name']);
        filteredProductsList.add(element);
        countAllPricesNSells(element);
      }
    }

    productsList = filteredProductsList;
    sumCount.value = productsList.length;
    print(filteredProductsList.length);
    Get.back();
    Get.back();
    loadingData.value = false;
  }
}

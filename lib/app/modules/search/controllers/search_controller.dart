import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/data/models/product_model.dart';

class SeacrhViewController extends GetxController {
  RxList searchResult = [].obs;
  RxList productsList = [].obs;
  RxList collectAllProducts = [].obs;
  RxList filteredProductsList = [].obs;
  RxBool loadingData = false.obs;
  RxBool showInGrid = false.obs;

  getClientStream() async {
    loadingData.value = true;
    await FirebaseFirestore.instance.collection('products').orderBy('date', descending: true).get().then((value) {
      for (var element in value.docs) {
        productsList.add(element);
        collectAllProducts.add(element);
      }
      // productsList.value = value.docs;
      // collectAllProducts.value = value.docs;
    });
    loadingData.value = false;
    searchResult.clear();
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
    productsList = collectAllProducts;
    loadingData.value = true;
    print('------------------------------');
    for (var element in productsList) {
      if (element[filterName].toString().toLowerCase() == filterSearchName.toLowerCase()) {
        filteredProductsList.add(element);
      }
    }

    productsList = filteredProductsList;
    Get.back();
    Get.back();
    loadingData.value = false;
  }
}

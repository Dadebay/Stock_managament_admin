// ignore_for_file: unused_local_variable

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';

class PurchasesController extends GetxController {
  RxList<PurchasesModel> purchasesMainList = <PurchasesModel>[].obs;
  RxList<PurchasesModel> searchResult = <PurchasesModel>[].obs;
  RxDouble sumCost = 0.0.obs;
  void onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      searchResult.assignAll(purchasesMainList);
      update();
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    searchResult.value = purchasesMainList.where((product) {
      final name = product.title.toLowerCase();
      final price = product.source.toLowerCase();
      final desc = product.description.toLowerCase();

      return words.every((w) => name.contains(w) || price.contains(w) || desc.contains(w));
    }).toList();
    update();
  }

  void deleteProduct(int id) {
    purchasesMainList.removeWhere((element) => element.id == id);
    calculateTotals();
  }

  void addClient(PurchasesModel model) {
    purchasesMainList.insert(0, model);
    calculateTotals();
  }

  void calculateTotals() {
    double totalCost = 0;
    for (var product in purchasesMainList) {
      final cost = double.tryParse(product.cost) ?? 0.0;
      totalCost += cost;
    }
    sumCost.value = totalCost;
  }
}

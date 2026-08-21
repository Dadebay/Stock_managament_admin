import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';

class PurchasesController extends GetxController {
  RxList<PurchasesModel> purchases = <PurchasesModel>[].obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt totalCount = 0.obs;
  RxDouble summ = 0.0.obs;
  RxInt totalProductCount = 0.obs;
  RxBool pageLoading = true.obs;
  RxBool isCreatingPurchase = false.obs;

  /// null => every year is shown.
  final RxnString selectedYear = RxnString();

  /// Dates arrive as 'YYYY-MM-DD' strings, so take the year off the front
  /// instead of parsing — malformed rows just fall out of the year buckets.
  static String yearOf(PurchasesModel model) => model.date.length >= 4 ? model.date.substring(0, 4) : '';

  /// Years present in [list], newest first.
  List<String> availableYears(List<PurchasesModel> list) {
    final years = list.map(yearOf).where((year) => year.isNotEmpty).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<PurchasesModel> applyYearFilter(List<PurchasesModel> list) {
    final year = selectedYear.value;
    if (year == null) return list;
    return list.where((model) => yearOf(model) == year).toList();
  }

  static double totalCostOf(List<PurchasesModel> list) {
    double total = 0;
    for (final model in list) {
      total += double.tryParse(model.cost) ?? 0.0;
    }
    return total;
  }

  static int totalCountOf(List<PurchasesModel> list) {
    int total = 0;
    for (final model in list) {
      total += model.count;
    }
    return total;
  }

  void editClient(PurchasesModel updatedModel) {
    final index = purchases.indexWhere((element) {
      return element.id.toString() == updatedModel.id.toString();
    });
    if (index != -1) {
      int oldCount = purchases[index].count;
      purchases[index] = updatedModel;
      if (purchases[index].count.toString() == '0') {
        purchases[index].count = oldCount;
      }
    }
  }

  void deleteProduct(int id) {
    purchases.removeWhere((element) => element.id == id);
  }

  void addClient(PurchasesModel model) {
    purchases.insert(0, model);
  }
}

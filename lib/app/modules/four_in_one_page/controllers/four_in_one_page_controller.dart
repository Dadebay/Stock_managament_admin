import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';

class FourInOnePageController extends GetxController {
  final RxMap<String, RxList<FourInOneModel>> fourInOneDataMap = <String, RxList<FourInOneModel>>{}.obs;

  void addListData(String key, List<FourInOneModel> categories) {
    final existingList = fourInOneDataMap[key] ?? <FourInOneModel>[].obs;
    final existingIds = existingList.map((e) => e.id).toSet();
    final newItems = categories.where((item) => !existingIds.contains(item.id)).toList();
    existingList.addAll(newItems);
    fourInOneDataMap[key] = existingList;
    update();
  }

  void clearData(String key) {
    fourInOneDataMap[key]?.clear();
  }

  void addFourInOne(String key, FourInOneModel model) {
    fourInOneDataMap[key]?.add(model);
  }

  void editFourInOne(String key, FourInOneModel model) {
    final list = fourInOneDataMap[key];
    if (list == null) return;
    int index = list.indexWhere((element) => element.id == model.id);
    if (index != -1) {
      list[index] = model;
    }
  }

  void deleteFourInOne(String key, int id) {
    fourInOneDataMap[key]?.removeWhere((element) => element.id == id);
  }
}

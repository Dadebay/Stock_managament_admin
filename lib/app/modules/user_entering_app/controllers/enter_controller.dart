import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';

class EnterController extends GetxController {
  RxList<EnterModel> clients = <EnterModel>[].obs;
  RxList<EnterModel> searchResult = <EnterModel>[].obs;
  RxInt currentPage = 1.obs;
  onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      update();
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    searchResult.value = clients.where((client) {
      final name = client.name.toLowerCase();
      final phone = client.phone.toLowerCase();
      final address = client.address.toLowerCase();
      return words.every((word) => name.contains(word.toLowerCase()) || phone.contains(word.toLowerCase()) || address.contains(word.toLowerCase()));
    }).toList();
  }

  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Clients'];
    sheet.appendRow(['Name', 'Number', 'Address', 'Order Count', 'Sum Price']);
    for (var client in clients) {
      sheet.appendRow([client.name.toString(), client.phone.toString(), client.address.toString(), client.orderCount.toString(), client.sumPrice.toString()]);
    }
    excel.save(fileName: "${DateTime.now().toString().substring(0, 19)}_clients.xlsx");
  }

  void addClient(EnterModel model) {
    clients.insert(0, model);
    searchResult.insert(0, model);

    update();
  }

  void deleteClient(int id) {
    clients.removeWhere((item) => item.id == id);
    searchResult.removeWhere((item) => item.id == id);
    update();
  }

  void editClient(EnterModel model) {
    final index = clients.indexWhere((item) => item.id == model.id);
    if (index == -1) {
      return;
    }

    clients[index] = model;

    final searchIndex = searchResult.indexWhere((item) => item.id == model.id);
    if (searchIndex != -1) {
      searchResult[searchIndex] = model;
    }

    clients.refresh();
    update();
  }
}

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
      final name = client.username!.toLowerCase();
      final phone = client.password!.toLowerCase();
      return words.every((word) => name.contains(word.toLowerCase()) || phone.contains(word.toLowerCase()));
    }).toList();
  }

  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Clients'];
    sheet.appendRow(['Username', 'Password', 'Admin']);
    for (var client in clients) {
      sheet.appendRow([client.username.toString(), client.password.toString(), client.isSuperUser.toString()]);
    }
    excel.save(fileName: "${DateTime.now().toString().substring(0, 19)}_users.xlsx");
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

import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';

class ExpencesController extends GetxController {
  RxList<ExpencesModel> expencesList = <ExpencesModel>[].obs;
  RxList<ExpencesModel> searchResult = <ExpencesModel>[].obs;
  RxDouble totalPrice = 0.0.obs;

  onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      update();
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    searchResult.value = expencesList.where((expences) {
      final name = expences.name.toLowerCase();
      final phone = expences.cost.toLowerCase();
      final note = expences.note.toLowerCase();
      return words.every((word) => name.contains(word.toLowerCase()) || phone.contains(word.toLowerCase()) || note.contains(word.toLowerCase()));
    }).toList();
  }

  addExpences(ExpencesModel model) {
    expencesList.insert(0, model);
    update();
  }

  deleteExpences(ExpencesModel model) {
    expencesList.remove(model);
    update();
  }

  editExpences(ExpencesModel model) {
    final index = expencesList.indexWhere((item) => item.id == model.id);
    expencesList[index] = model;
    expencesList.refresh();
  }

  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Expences'];
    sheet.appendRow(['Expences Name', 'Date', 'Cost', 'Note']);
    for (var expence in expencesList) {
      sheet.appendRow([expence.name.toString(), expence.date.toString(), expence.cost.toString(), expence.note.toString()]);
    }
    excel.save(fileName: "${DateTime.now().toString().substring(0, 19)}_expences.xlsx");
  }
}

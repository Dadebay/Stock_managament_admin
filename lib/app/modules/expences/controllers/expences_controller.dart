import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/product/excel_export.dart';

class ExpencesController extends GetxController {
  RxList<ExpencesModel> expencesList = <ExpencesModel>[].obs;
  RxList<ExpencesModel> searchResult = <ExpencesModel>[].obs;
  RxDouble totalPrice = 0.0.obs;

  /// Total cost grouped by year, sorted from oldest to newest.
  /// Recomputed from [expencesList] so a new year (e.g. 2027) shows up automatically.
  Map<int, double> get totalByYear {
    final Map<int, double> map = {};
    for (final expence in expencesList) {
      final date = DateTime.tryParse(expence.date ?? '');
      if (date == null) continue;
      final cost = double.tryParse(expence.cost.toString()) ?? 0.0;
      map[date.year] = (map[date.year] ?? 0) + cost;
    }
    final sortedEntries = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(sortedEntries);
  }

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
    await downloadExcel(excel, '${excelTimestamp()}_expences.xlsx');
  }
}

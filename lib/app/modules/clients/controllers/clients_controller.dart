import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/data/models/client_model.dart';

class ClientsController extends GetxController {
  RxList clients = [].obs;
  RxList searchResult = [].obs;
  RxBool loadData = false.obs;
  clearFilter() {
    clients.clear();
    getAllClients();
  }

  onSearchTextChanged(String word) async {
    searchResult.clear();
    List fullData = [];
    loadData.value = true;
    List<String> words = word.trim().split(' ');
    fullData = clients.where((p) {
      bool result = true;
      for (final word in words) {
        if (!p['number'].contains(word)) {
          result = false;
        }
      }
      return result;
    }).toList();

    searchResult.value = fullData.toSet().toList();

    loadData.value = false;
  }

  getAllClients() async {
    loadData.value = true;
    clients.clear();
    await FirebaseFirestore.instance.collection('clients').get().then((value) async {
      for (var element in value.docs) {
        Client clinet = Client(
            address: element['address'],
            orderCount: int.parse(element['order_count'].toString()),
            name: element['name'],
            number: element['number'],
            sumPrice: double.parse(element['sum_price'].toString()));

        clients.add({'name': clinet.name, 'number': clinet.number, 'address': clinet.address, 'order_count': clinet.orderCount, 'sum_price': clinet.sumPrice});
      }
    });
    loadData.value = false;
  }
}

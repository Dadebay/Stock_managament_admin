import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stock_managament_admin/app/data/models/client_model.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

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

  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Clients']; // Customize the sheet name
    sheet.appendRow([
      const TextCellValue('Name'),
      const TextCellValue('Number'),
      const TextCellValue('Address'),
      const TextCellValue('Order Count '),
      const TextCellValue('Sum Price'),
      const TextCellValue('Doc Id'),
    ]);

    for (var client in clients) {
      sheet.appendRow([
        TextCellValue(client['name'].toString()),
        TextCellValue(client['number'].toString()),
        TextCellValue(client['address'].toString()),
        TextCellValue(client['order_count'].toString()),
        TextCellValue(client['sum_price'].toString()),
        TextCellValue(client['docID'].toString()),
      ]);
    }
    var fileBytes = excel.save(fileName: "${DateTime.now().toString().substring(0, 19)}_clients.xlsx");
  }

  addClient({required String clientName, required String clientAddress, required String clientPhoneNumber}) async {
    bool valueAddClient = false;

    for (var element in clients) {
      if (element['number'] == clientPhoneNumber) {
        valueAddClient = true;
      }
    }
    if (valueAddClient == false) {
      await FirebaseFirestore.instance.collection('clients').add({
        'address': clientAddress,
        'name': clientName,
        'number': clientPhoneNumber,
        'sum_price': '0.0',
        'order_count': 0,
        'date': DateTime.now().toString().substring(0, 19),
      }).then((value) {
        clients
            .add({'name': clientName, 'number': clientPhoneNumber, "docID": value.id, 'address': clientAddress, 'order_count': 0, 'sum_price': 0, 'date': DateTime.now().toString().substring(0, 19)});
        clients.sort((a, b) {
          return a['date'].compareTo(b['date']);
        });
        Get.back();
        Get.back();

        showSnackBar("Done", "Client succesfully added", Colors.green);
      });
    }
  }

  getAllClients() async {
    loadData.value = true;
    clients.clear();
    await FirebaseFirestore.instance.collection('clients').orderBy('date', descending: true).get().then((value) async {
      for (var element in value.docs) {
        Client clinet = Client(
            address: element['address'],
            orderCount: int.parse(element['order_count'].toString()),
            name: element['name'],
            date: element['date'],
            number: element['number'],
            sumPrice: double.parse(element['sum_price'].toString()));

        clients
            .add({'name': clinet.name, 'number': clinet.number, 'date': clinet.date, 'address': clinet.address, 'order_count': clinet.orderCount, "docID": element.id, 'sum_price': clinet.sumPrice});
      }
    });
    loadData.value = false;
  }

  getDownloadDirectory() {}
}

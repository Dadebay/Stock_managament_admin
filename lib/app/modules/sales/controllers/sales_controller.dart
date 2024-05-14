import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:stock_managament_admin/app/data/models/product_model.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class SalesController extends GetxController {
  RxList filteredOrderedProducts = [].obs;
  RxList getAllOrders = [].obs;
  final HomeController homeController = Get.put(HomeController());
  RxBool loadingDataOrders = false.obs;
  RxList orderCardList = [].obs;
  RxList orderedCardsSearchResult = [].obs;
  RxList selectedProductsToOrder = [].obs;
  RxDouble sumCost = 0.0.obs;
  RxDouble sumPrice = 0.0.obs;
  RxDouble sumProductCount = 0.0.obs;

  onSearchTextChanged(String word) async {
    loadingDataOrders.value = true;
    orderedCardsSearchResult.clear();
    List fullData = [];
    List<String> words = word.toLowerCase().trim().split(' ');
    fullData = orderCardList.where((p) {
      bool result = true;
      for (final word in words) {
        if (!p['client_number'].toLowerCase().contains(word)) {
          result = false;
        }
      }
      return result;
    }).toList();
    orderedCardsSearchResult.value = fullData.toSet().toList();
    loadingDataOrders.value = false;
  }

  getData() async {
    loadingDataOrders.value = true;
    orderCardList.clear();
    sumCost.value = 0.0;
    sumPrice.value = 0.0;
    sumProductCount.value = 0.0;
    await FirebaseFirestore.instance.collection('sales').orderBy("date", descending: true).get().then((value) {
      for (var element in value.docs) {
        if (element['status'].toString().toLowerCase() == 'shipped') {
          sumCost.value += double.parse(element['sum_cost'].toString());
          sumPrice.value += double.parse(element['sum_price'].toString());
          sumProductCount.value += double.parse(element['product_count'].toString());
        }

        orderCardList.add(element);
        getAllOrders.add(element);
      }
      loadingDataOrders.value = false;
    });
  }

  filterProductsMine(String filterName, String filterSearchName) {
    filteredOrderedProducts.clear();
    orderCardList = getAllOrders;
    loadingDataOrders.value = true;
    for (var element in orderCardList) {
      if (element[filterName].toString().toLowerCase() == filterSearchName.toLowerCase()) {
        filteredOrderedProducts.add(element);
      }
    }

    orderCardList = filteredOrderedProducts;
    Get.back();
    Get.back();
    loadingDataOrders.value = false;
  }

  addProduct({required ProductModel product, required int count}) {
    selectedProductsToOrder.add({'product': product, 'count': count});
  }

  upgradeCount(String id, int count) {
    for (var element in selectedProductsToOrder) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count.toString();
      }
    }

    selectedProductsToOrder.refresh();
  }

  decreaseCount(String id, int count) {
    for (var element in selectedProductsToOrder) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count;
        selectedProductsToOrder.removeWhere((element) => element['count'].toString() == '0');
        print(selectedProductsToOrder);
        selectedProductsToOrder.refresh();
      }
    }
    selectedProductsToOrder.refresh();
  }

  sumbitSale({required List<TextEditingController> textControllers, required String status}) async {
    double sumCost = 0.0;
    double sumPrice = 0.0;
    homeController.agreeButton.value = !homeController.agreeButton.value;

    for (var element in selectedProductsToOrder) {
      final ProductModel product = element['product'];
      sumCost += double.parse(product.cost.toString()).toDouble() * int.parse(element['count'].toString());
      sumPrice += double.parse(product.sellPrice.toString()).toDouble() * int.parse(element['count'].toString());
      int.parse(product.quantity.toString()) - int.parse(element['count'].toString());
      await FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': int.parse(product.quantity.toString()) - int.parse(element['count'].toString())});
    }
    double discountPrice = textControllers[7].text == "" ? 0.0 : double.parse(textControllers[7].text.toString());
    if (discountPrice >= sumPrice) {
      showSnackBar("Error", "A discount price cannot be greater than the sum price.", Colors.red);
    } else {
      await FirebaseFirestore.instance.collection('sales').add({
        'client_address': textControllers[4].text,
        'client_name': textControllers[3].text,
        'client_number': textControllers[2].text,
        'coupon': textControllers[5].text,
        'date': textControllers[0].text,
        'discount': textControllers[7].text,
        'note': textControllers[6].text,
        'package': textControllers[1].text,
        'status': status,
        'product_count': selectedProductsToOrder.length.toString(),
        'sum_price': sumPrice.toString(),
        'sum_cost': sumCost.toString(),
      }).then((value) async {
        for (var element in selectedProductsToOrder) {
          final ProductModel product = element['product'];
          await FirebaseFirestore.instance.collection('sales').doc(value.id).collection('products').add({
            'brand': product.brandName,
            'category': product.category,
            'cost': product.cost,
            'gramm': product.gramm,
            'image': product.image,
            'location': product.location,
            'date': product.date,
            'material': product.material,
            'name': product.name,
            'note': product.note,
            'package': product.package,
            'quantity': element['count'],
            'sell_price': product.sellPrice,
          });
        }
      });
      homeController.agreeButton.value = !homeController.agreeButton.value;

      showSnackBar("Done", "Your purchase submitted ", Colors.green);
    }
  }
}

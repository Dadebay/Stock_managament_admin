import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class ProductsPageController extends GetxController {
  RxInt page = 0.obs;
  RxInt limit = 20.obs;
  RxBool agreeButton = false.obs;
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('products');
  RxString filteredName = "".obs;
  RxString filteredNameToSearch = "".obs;
  RxBool isFiltered = false.obs;
  RxBool loadingData = false.obs;
  RxBool showInGrid = false.obs;
  RxList productsListHomeView = [].obs;

  @override
  void onInit() async {
    super.onInit();
    getData();
  }

  getData() {
    print("geldi data alyar ----------------------------------------------------------------");
    loadingData.value = true;
    collectionReference.limit(limit.value).get().then((value) {
      productsListHomeView.value = value.docs;
    });
    loadingData.value = false;
  }

  Future<void> onRefreshController() async {
    productsListHomeView.clear();
    loadingData.value = true;
    await FirebaseFirestore.instance.collection('products').orderBy("date", descending: true).limit(limit.value).get().then((value) {
      productsListHomeView.value = value.docs;
    });
    isFiltered.value = false;
    loadingData.value = false;
  }

  Future<void> onLoadingController() async {
    int length = productsListHomeView.length;
    loadingData.value = true;
    print(length);

    if (isFiltered.value == true) {
      collectionReference
          .where(filteredName.value.toLowerCase(), isEqualTo: filteredNameToSearch.value.toLowerCase())
          .startAfterDocument(productsListHomeView.last)
          .limit(limit.value)
          .get()
          .then((value) {
        productsListHomeView.addAll(value.docs);
        if (length == productsListHomeView.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      });
    } else {
      collectionReference.orderBy("date", descending: true).startAfterDocument(productsListHomeView.last).limit(limit.value).get().then((value) {
        productsListHomeView.addAll(value.docs);
        if (length == productsListHomeView.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      });
    }
    print(productsListHomeView.length);
    loadingData.value = false;
  }

  filterProducts(String filterName, String filterSearchName) {
    filteredName.value = filterName;
    filteredNameToSearch.value = filterSearchName;
    productsListHomeView.clear();
    loadingData.value = true;

    FirebaseFirestore.instance.collection('products').where(filterName.toLowerCase(), isEqualTo: filterSearchName).get().then((value) {
      if (value.docs.isEmpty) {
        productsListHomeView.clear();
      } else {
        productsListHomeView.addAll(value.docs);
      }
      Get.back();
      Get.back();
      loadingData.value = false;
      isFiltered.value = true;
    });
  }
}

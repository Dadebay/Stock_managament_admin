import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FourInOnePageController extends GetxController {
  // ignore: non_constant_identifier_names
  List four_in_one_names = [
    {'name': 'brands', 'pageView': "Brands", "countName": 'brand'},
    {'name': 'categories', 'pageView': "Categories", "countName": 'category'},
    {'name': 'locations', 'pageView': "Locations", "countName": 'location'},
    {'name': 'materials', 'pageView': "Materials", "countName": 'material'},
  ];
  findData() async {
    double sumProductCount = 0.0;

    for (int j = 0; j < four_in_one_names.length; j++) {
      String categoryName = four_in_one_names[j]['name'];
      String productCategoryName = four_in_one_names[j]['countName'];
      FirebaseFirestore.instance.collection(categoryName).get().then((value) async {
        for (var element in value.docs) {
          FirebaseFirestore.instance.collection('products').get().then((product) {
            for (int i = 0; i < product.docs.length; i++) {
              if (product.docs[i][productCategoryName].toString().toLowerCase() == element['name'].toString().toLowerCase()) {
                sumProductCount += product.docs[i]['quantity'].toDouble();
              }
            }

            FirebaseFirestore.instance.collection(categoryName).doc(element.id).update({'quantity': sumProductCount});
            sumProductCount = 0.0;
          });
        }
      });
    }
  }
}

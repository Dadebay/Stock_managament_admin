import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class PurchasesController extends GetxController {
  RxList filteredOrderedProducts = [].obs;
  RxList purchasesSaveProductsList = [].obs;
  RxBool loadingDataOrders = false.obs;
  RxList purchasesMainList = [].obs;
  RxDouble sumCost = 0.0.obs;
  final SalesController salesController = Get.put(SalesController());
  getData() async {
    loadingDataOrders.value = true;
    purchasesMainList.clear();
    sumCost.value = 0.0;
    await FirebaseFirestore.instance.collection('purchases').orderBy("date", descending: true).get().then((value) {
      for (var element in value.docs) {
        sumCost.value += double.parse(element['cost'].toString());
        purchasesMainList.add(element);
        purchasesSaveProductsList.add(element);
      }
      loadingDataOrders.value = false;
    });
  }

  sumbitSale({required List<TextEditingController> textControllers}) async {
    double sumCost = 0.0;
    //purchases edilen harytlar sanyny kopletyar
    for (var element in salesController.selectedProductsToOrder) {
      final ProductModel product = element['product'];
      sumCost += double.parse(product.cost.toString()).toDouble() * int.parse(element['count'].toString());
      await FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': int.parse(product.quantity.toString()) + int.parse(element['count'].toString())});
    }

    // create purchase edyar
    await FirebaseFirestore.instance.collection('purchases').add({
      'date': textControllers[0].text,
      'title': textControllers[1].text,
      'source': textControllers[2].text,
      'note': textControllers[3].text,
      'product_count': salesController.selectedProductsToOrder.length.toString(),
      'cost': sumCost.toString(),
    }).then((value) async {
      // tazeden create edilen purchase list gosyar
      print("----------------------111111---------------------------------------");
      await FirebaseFirestore.instance.collection('purchases').doc(value.id).get().then((valueMine) {
        purchasesMainList.add(valueMine);
        print("----------------------2222222---------------------------------------");
      });
      // her purchase edilen products purchase dannylaryny gosyar
      for (var element in salesController.selectedProductsToOrder) {
        final ProductModel product = element['product'];
        //her product icindaki PURCHASE table dolduryar
        await FirebaseFirestore.instance.collection('products').doc(product.documentID).collection('purchases').add({
          'date': textControllers[0].text,
          'title': textControllers[1].text,
          'source': textControllers[2].text,
          'note': textControllers[3].text,
          'product_count': element['count'].toString(),
          'cost': sumCost.toString(),
          'purchase_id': value.id,
        });
        print("----------------------333333333---------------------------------------");

        //her purchase icindaki productlar dolduryar
        await FirebaseFirestore.instance.collection('purchases').doc(value.id).collection('products').add({
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
        print("----------------------4444444---------------------------------------");
      }
      Get.back();
      CustomWidgets.showSnackBar("Done", "Succesfully created Purchase", Colors.green);
    });
  }
}

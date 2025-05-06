import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SeacrhViewController extends GetxController {
  RxList<ProductModel> searchResult = <ProductModel>[].obs;
  RxList<ProductModel> productsList = <ProductModel>[].obs;
  RxBool showInGrid = false.obs;

  RxDouble sumSell = 0.0.obs;
  RxDouble sumCost = 0.0.obs;
  RxInt sumCount = 0.obs;

  Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);

  void onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      searchResult.assignAll(productsList);
      update();
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    searchResult.value = productsList.where((product) {
      final name = product.name.toLowerCase() ?? '';
      final price = product.price.toLowerCase() ?? '';
      final category = product.category!.name.toLowerCase() ?? '';
      final brand = product.brend!.name.toLowerCase() ?? '';

      return words.every((w) => name.contains(w) || price.contains(w) || category.contains(w) || brand.contains(w));
    }).toList();
    update();
  }

  Future<void> pickImage() async {
    try {
      var fileInfo = await ImagePickerWeb.getImageInfo;
      if (fileInfo != null && fileInfo.data != null && fileInfo.fileName != null) {
        selectedImageBytes.value = fileInfo.data;

        CustomWidgets.showSnackBar("Success", "Image selected: ", Colors.green);
      }
    } catch (e) {
      print("Error picking image: $e");
      CustomWidgets.showSnackBar("Error", "Could not pick image: $e", Colors.red);
    }
  }

  void deleteProduct(int id) {
    productsList.removeWhere((product) => product.id == id);
    searchResult.removeWhere((product) => product.id == id);
    update();
  }
}

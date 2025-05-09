import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SearchViewController extends GetxController {
  RxList<SearchModel> searchResult = <SearchModel>[].obs;
  RxList<SearchModel> productsList = <SearchModel>[].obs;
  RxBool showInGrid = false.obs;

  RxDouble sumSell = 0.0.obs;
  RxDouble sumCost = 0.0.obs;
  RxInt sumCount = 0.obs;

  Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  void clearSelectedImage() {
    selectedImageBytes.value = null;
  }

  RxList<Map<String, dynamic>> selectedProductsToOrder = <Map<String, dynamic>>[].obs;

  void addOrUpdateProduct({required SearchModel product, required int count}) {
    final index = selectedProductsToOrder.indexWhere(
      (element) => element['product'].id.toString() == product.id.toString(),
    );
    if (index != -1) {
      selectedProductsToOrder[index]['count'] = count;
    } else {
      selectedProductsToOrder.add({'product': product, 'count': count});
    }
    selectedProductsToOrder.refresh();
  }

  void decreaseCount(String id, int count) {
    for (int i = 0; i < selectedProductsToOrder.length; i++) {
      final product = selectedProductsToOrder[i]['product'];
      if (product.id.toString() == id) {
        if (count <= 0) {
          selectedProductsToOrder.removeAt(i);
        } else {
          selectedProductsToOrder[i]['count'] = count;
        }
        break;
      }
    }
    selectedProductsToOrder.refresh();
  }

  int getProductCount(String id) {
    for (var element in selectedProductsToOrder) {
      final SearchModel product = element['product'];
      if (product.id.toString() == id) {
        return element['count'] ?? 0;
      }
    }
    return 0;
  }

  Future<void> addNewProduct({
    required Map<String, String> productData,
    String? imageFileName,
  }) async {
    try {
      final SearchModel? newProduct = await SearchService().createProductWithImage(fields: productData, imageFileName: imageFileName, imageBytes: selectedImageBytes.value);

      if (newProduct != null) {
        final updatedList = await SearchService().getProducts();
        productsList.assignAll(updatedList);
        selectedImageBytes.value = null;
        Get.back();
        CustomWidgets.showSnackBar("Başarılı", "Ürün başarıyla eklendi", Colors.green);
      } else {
        CustomWidgets.showSnackBar("Hata", "Ürün eklenemedi. Sunucudan veri dönmedi.", Colors.red);
      }
    } catch (e) {
      print("Ürün ekleme hatası: $e");
      CustomWidgets.showSnackBar("Hata", "Ürün eklenemedi: $e", Colors.red);
    }
  }

  void onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      searchResult.assignAll(productsList);
      update();
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    searchResult.value = productsList.where((product) {
      final name = product.name.toLowerCase();
      final price = product.price.toLowerCase();

      return words.every((w) => name.contains(w) || price.contains(w));
    }).toList();
    update();
  }

  void updateProductLocally(SearchModel updatedProduct) {
    final indexInProducts = productsList.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInProducts != -1) {
      productsList[indexInProducts] = updatedProduct;
    }

    final indexInSearch = searchResult.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInSearch != -1) {
      searchResult[indexInSearch] = updatedProduct;
    }
    calculateTotals();
    update();
  }

  void calculateTotals() {
    double totalSell = 0;
    double totalCost = 0;
    int totalCount = 0;

    for (var product in productsList) {
      final sell = double.tryParse(product.price) ?? 0.0;
      final cost = double.tryParse(product.cost) ?? 0.0;
      final count = product.count ?? 0;

      totalSell += sell * count;
      totalCost += cost * count;
      totalCount += count;
    }

    sumSell.value = totalSell;
    sumCost.value = totalCost;
    sumCount.value = totalCount;
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

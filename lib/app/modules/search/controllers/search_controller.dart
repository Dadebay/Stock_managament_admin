import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SearchViewController extends GetxController {
  RxList<SearchModel> searchResult = <SearchModel>[].obs;
  RxList<SearchModel> productsList = <SearchModel>[].obs;
  RxList<SearchModel> historyList = <SearchModel>[].obs;
  RxBool showInGrid = false.obs;
  RxString selectedCategory = 'All'.obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxBool isLoading = true.obs;

  RxDouble sumSell = 0.0.obs;
  RxDouble sumCost = 0.0.obs;
  RxInt sumCount = 0.obs;
  String _currentSearchText = '';
  String _activeFilterType = '';
  String _activeFilterValue = '';

  // Paginated browsing mode (the main "Gözleg" tab, when no filter/picker needs the full catalog).
  RxList<SearchModel> pageItems = <SearchModel>[].obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt totalCount = 0.obs;
  RxBool pageLoading = true.obs;
  String _pagedSearchText = '';

  Future<void> loadProductsPage({int page = 1}) async {
    pageLoading.value = true;
    try {
      final result = await SearchService().getProducts(page: page, search: _pagedSearchText);
      pageItems.assignAll(result.products);
      currentPage.value = result.page;
      totalPages.value = result.totalPages < 1 ? 1 : result.totalPages;
      totalCount.value = result.count;
    } finally {
      pageLoading.value = false;
    }
  }

  void onPagedSearchTextChanged(String word) {
    _pagedSearchText = word.trim();
    loadProductsPage(page: 1);
  }

  // Catalog-wide totals for the bottom stats bar in paginated mode - computed
  // from the *entire* product catalog, not just the currently loaded page.
  RxInt catalogProductCount = 0.obs;
  RxInt catalogStockCount = 0.obs;
  RxDouble catalogTotalCost = 0.0.obs;
  RxDouble catalogTotalSell = 0.0.obs;
  RxBool catalogTotalsLoaded = false.obs;

  Future<void> loadCatalogTotals() async {
    final all = await SearchService().getAllProducts();
    int stock = 0;
    double cost = 0;
    double sell = 0;
    for (final product in all) {
      stock += product.count;
      cost += (double.tryParse(product.cost) ?? 0) * product.count;
      sell += (double.tryParse(product.price) ?? 0) * product.count;
    }
    catalogProductCount.value = all.length;
    catalogStockCount.value = stock;
    catalogTotalCost.value = cost;
    catalogTotalSell.value = sell;
    catalogTotalsLoaded.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize categories when the controller is created
    historyList.listen((products) {
      final uniqueCategories = <CategoryModel>[];
      final categoryNames = <String>{};
      for (var product in products) {
        if (product.category != null && !categoryNames.contains(product.category!.name)) {
          uniqueCategories.add(product.category!);
          categoryNames.add(product.category!.name);
        }
      }
      categories.assignAll(uniqueCategories);
    });
  }

  Future<void> loadProducts() async {
    try {
      print('===== LOAD PRODUCTS: Ürünler yüklenmeye başladı =====');
      isLoading.value = true;
      final products = await SearchService().getAllProducts();
      print('===== LOAD PRODUCTS: ${products.length} ürün yüklendi =====');

      // İlk ürünün tarih bilgisini kontrol et
      if (products.isNotEmpty) {
        print('===== İLK ÜRÜN TARİH BİLGİSİ: createdAT = ${products[0].createdAT} =====');
      }

      // Tarihe göre sırala (en yeni en üstte, tarih olmayanlar en altta)
      final sortedProducts = products.toList();
      sortedProducts.sort((a, b) {
        try {
          // Her iki ürünün tarih bilgisini kontrol et
          final bool aHasDate = a.createdAT.isNotEmpty;
          final bool bHasDate = b.createdAT.isNotEmpty;

          // İkisinde de tarih yoksa, sıralama değiştirme
          if (!aHasDate && !bHasDate) return 0;

          // Sadece a'da tarih yoksa, a'yı alta gönder
          if (!aHasDate) return 1;

          // Sadece b'de tarih yoksa, b'yi alta gönder
          if (!bHasDate) return -1;

          // Her ikisinde de tarih varsa, tarihe göre sırala (en yeni üstte)
          DateTime dateA = DateTime.parse(a.createdAT);
          DateTime dateB = DateTime.parse(b.createdAT);
          return dateB.compareTo(dateA);
        } catch (e) {
          // Tarih parse hatası varsa, bu ürünü alta gönder
          print('===== TARİH PARSE HATASI: ${e.toString()} =====');
          return 1;
        }
      });

      historyList.assignAll(sortedProducts);
      productsList.assignAll(sortedProducts);
      searchResult.assignAll(sortedProducts);
      calculateTotals();
      isLoading.value = false;
      print('===== LOAD PRODUCTS: Tamamlandı =====');
    } catch (e) {
      print('===== LOAD PRODUCTS HATASI: $e =====');
      isLoading.value = false;
    }
  }

/*************  ✨ Windsurf Command ⭐  *************/
  /// Filter the products by the given category name
  /// and update the UI accordingly by calling
  /// [onSearchTextChanged] with the current search text.
  ///

/*******  29e92759-1f69-4682-84fe-0c698289ded1  *******/ void filterByCategory(String categoryName) {
    selectedCategory.value = categoryName;
    onSearchTextChanged(_currentSearchText);
  }

  void _filterAndSearchProducts() {
    List<SearchModel> GeciciListe = productsList.toList();
    if (_activeFilterType.isNotEmpty && _activeFilterValue.isNotEmpty) {
      GeciciListe = GeciciListe.where((product) {
        switch (_activeFilterType) {
          case 'category':
            return product.category?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          case 'brends':
            return product.brend?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          case 'location':
            return product.location?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          case 'material':
            return product.material?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          default:
            return true;
        }
      }).toList();
    }
    if (_currentSearchText.isNotEmpty) {
      List<String> words = _currentSearchText.trim().toLowerCase().split(' ');
      GeciciListe = GeciciListe.where((product) {
        final name = product.name.toLowerCase();
        final price = product.price.toLowerCase();
        return words.every((w) => name.contains(w) || price.contains(w));
      }).toList();
    }
    productsList.assignAll(GeciciListe);
  }

  Future<void> applyFilter(String filterType, String filterValue) async {
    if (historyList.isEmpty) {
      // Paginated browsing mode only had the current page loaded - pull the
      // full catalog now that a filter that needs it is actually being used.
      await loadProducts();
    }
    _activeFilterType = filterType;
    _activeFilterValue = filterValue;
    if (_currentSearchText.isEmpty) {
      searchResult.assignAll(productsList);
    }
    _filterAndSearchProducts();
  }

  void clearFilter() {
    _activeFilterType = '';
    _activeFilterValue = '';
    productsList.assignAll(historyList);
    Get.back();
  }

  Rx<String?> selectedImageFileName = Rx<String?>(null);
  Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  void clearSelectedImage() {
    selectedImageBytes.value = null;
    selectedImageFileName.value = null;
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
    required Uint8List? selectedImageBytes,
    required String? selectedImageFileName,
  }) async {
    try {
      print('===== ADD NEW PRODUCT BAŞLADI =====');
      final HomeController homeController = Get.find();
      homeController.agreeButton.value = true;

      final SearchModel? newProduct = await SearchService().createProductWithImage(
        fields: productData,
        imageBytes: selectedImageBytes, // Controller'daki byte'ları kullan
        imageFileName: selectedImageFileName, // Controller'daki dosya adını kullan
      );
      homeController.agreeButton.value = false;

      if (newProduct != null) {
        print('===== ÜRÜN BAŞARIYLA EKLENDİ, ID: ${newProduct.id} =====');

        // Yeni ürünü mevcut listelere ekle
        historyList.insert(0, newProduct);
        productsList.insert(0, newProduct);
        searchResult.insert(0, newProduct);
        pageItems.insert(0, newProduct);
        calculateTotals();
        if (catalogTotalsLoaded.value) loadCatalogTotals();

        clearSelectedImage();
        Get.back();

        CustomWidgets.showSnackBar("Başarılı", "Ürün başarıyla eklendi", Colors.green);

        print('===== NAVBAR SAYFASINA GERİ DÖNÜLÜYOR =====');
        print('===== LİSTEDE ŞİMDİ ${historyList.length} ÜRÜN VAR =====');
      } else {
        print('===== ÜRÜN EKLENEMEDİ: newProduct null =====');
        CustomWidgets.showSnackBar("Hata", "Ürün eklenemedi. Sunucudan veri dönmedi.", Colors.red);
      }
    } catch (e) {
      print('===== ÜRÜN EKLEME HATASI: $e =====');
      CustomWidgets.showSnackBar("Hata", "Ürün eklenemedi: $e", Colors.red);
    }
  }

  Future<void> refreshProducts() async {
    try {
      print('===== REFRESH PRODUCTS: Ürünler çekiliyor... =====');
      final products = await SearchService().getAllProducts();
      print('===== REFRESH PRODUCTS: ${products.length} ürün çekildi =====');
      print('===== ÖNCEKİ historyList: ${historyList.length} =====');
      print('===== ÖNCEKİ productsList: ${productsList.length} =====');
      print('===== ÖNCEKİ searchResult: ${searchResult.length} =====');

      historyList.assignAll(products);
      productsList.assignAll(products);
      searchResult.assignAll(products);
      calculateTotals();

      print('===== SONRAKİ historyList: ${historyList.length} =====');
      print('===== SONRAKİ productsList: ${productsList.length} =====');
      print('===== SONRAKİ searchResult: ${searchResult.length} =====');
    } catch (e) {
      print('===== REFRESH PRODUCTS HATASI: $e =====');
    }
  }

  void onSearchTextChanged(String word) {
    _currentSearchText = word;
    List<SearchModel> filteredList = historyList.toList(); // Start with the full history list

    // Apply category filter
    if (selectedCategory.value != 'All') {
      filteredList = filteredList.where((product) {
        return product.category?.name == selectedCategory.value;
      }).toList();
    }

    // Apply text search filter
    if (word.isNotEmpty) {
      List<String> words = word.trim().toLowerCase().split(' ');
      filteredList = filteredList.where((product) {
        final name = product.name.toLowerCase();
        final price = product.price.toLowerCase().toString();
        final cost = product.cost.toLowerCase().toString();
        return words.every((w) => name.contains(w) || price.contains(w.toString()) || cost.contains(w.toString()));
      }).toList();
    }

    searchResult.assignAll(filteredList);
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

    final indexInHistory = historyList.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInHistory != -1) {
      historyList[indexInHistory] = updatedProduct;
    }

    final indexInPage = pageItems.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInPage != -1) {
      pageItems[indexInPage] = updatedProduct;
    }

    calculateTotals();
    if (catalogTotalsLoaded.value) loadCatalogTotals();

    productsList.refresh();
    searchResult.refresh();
    historyList.refresh();
    pageItems.refresh();
    update();
  }

  void calculateTotals() {
    double totalSell = 0;
    double totalCost = 0;
    int totalCount = 0;
    sumSell.value = 0;
    sumCost.value = 0;
    sumCount.value = 0;
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
      final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await file.readAsBytes();
        selectedImageBytes.value = bytes;
        selectedImageFileName.value = file.name;
        CustomWidgets.showSnackBar("Success", "Image selected: ${file.name}", Colors.green);
      }
    } catch (e) {
      CustomWidgets.showSnackBar("Error", "Could not pick image: $e", Colors.red);
    }
  }

  void deleteProduct(int id) {
    productsList.removeWhere((product) => product.id == id);
    searchResult.removeWhere((product) => product.id == id);
    historyList.removeWhere((product) => product.id == id);
    pageItems.removeWhere((product) => product.id == id);
    calculateTotals();
    if (catalogTotalsLoaded.value) loadCatalogTotals();

    update();
  }
}

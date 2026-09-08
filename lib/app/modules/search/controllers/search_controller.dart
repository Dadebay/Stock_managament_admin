import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/image_compressor.dart';
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
    logState('loadProductsPage: start page=$page');
    try {
      final result = await SearchService().getProducts(page: page, search: _pagedSearchText);
      pageItems.assignAll(result.products);
      currentPage.value = result.page;
      totalPages.value = result.totalPages < 1 ? 1 : result.totalPages;
      totalCount.value = result.count;
    } catch (error) {
      debugPrint('[SEARCH] loadProductsPage failed: $error');
      rethrow;
    } finally {
      pageLoading.value = false;
      logState('loadProductsPage: done');
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
      isLoading.value = true;
      logState('loadProducts: start');
      final products = await SearchService().getAllProducts();
      debugPrint('[SEARCH] loadProducts: ${products.length} items');

      // İlk ürünün tarih bilgisini kontrol et

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
          debugPrint('[SEARCH] date parse failed: $e');
          return 1;
        }
      });

      historyList.assignAll(sortedProducts);
      productsList.assignAll(sortedProducts);
      searchResult.assignAll(sortedProducts);
      calculateTotals();
      isLoading.value = false;
      logState('loadProducts: done');
    } catch (e) {
      debugPrint('[SEARCH] loadProducts failed: $e');
      isLoading.value = false;
      logState('loadProducts: failed');
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
    final HomeController homeController = Get.find();
    homeController.agreeButton.value = true;
    logState('addNewProduct: start');
    try {
      final SearchModel? newProduct =
          await SearchService().createProductWithImage(
        fields: productData,
        imageBytes: selectedImageBytes,
        imageFileName: selectedImageFileName,
      );

      if (newProduct == null) {
        CustomWidgets.showSnackBar(
            "Hata", "Ürün eklenemedi. Sunucudan veri dönmedi.", Colors.red);
        return;
      }

      logState('addNewProduct: created id=${newProduct.id}');
      _insertNewProduct(newProduct);
      logState('addNewProduct: lists updated');

      clearSelectedImage();
      Get.back();
      CustomWidgets.showSnackBar(
          "Başarılı", "Ürün başarıyla eklendi", Colors.green);
    } on ProductCreatedButUnreadable {
      // The product exists on the server, only its response could not be
      // parsed: close the form and pull the fresh list instead of leaving the
      // user on a spinner.
      clearSelectedImage();
      Get.back();
      CustomWidgets.showSnackBar(
          "Başarılı", "Ürün eklendi, liste yenileniyor", Colors.green);
      if (fullCatalogLoaded) {
        await refreshProducts();
      } else {
        await loadProductsPage(page: currentPage.value);
      }
    } catch (e) {
      debugPrint('Add product failed: $e');
      CustomWidgets.showSnackBar("Hata", "Ürün eklenemedi: $e", Colors.red);
    } finally {
      // Always release the shared loading flag; otherwise every AgreeButton in
      // the app keeps spinning until the page is reloaded.
      homeController.agreeButton.value = false;
      logState('addNewProduct: done (agreeButton=false)');
    }
  }

  /// Dumps every flag the search screen uses to decide between the list and a
  /// spinner. Call it from anywhere a spinner is shown or a list changes.
  void logState(String tag) {
    debugPrint('[SEARCH] $tag | isLoading=${isLoading.value} '
        'pageLoading=${pageLoading.value} history=${historyList.length} '
        'products=${productsList.length} pageItems=${pageItems.length} '
        'page=${currentPage.value}/${totalPages.value} '
        'totalCount=${totalCount.value} '
        'catalogTotals=${catalogTotalsLoaded.value}');
  }

  /// True once the whole catalog has been pulled into [historyList]. The
  /// search screen switches to its full-catalog layout as soon as that list is
  /// filled, so the paginated screen must not populate it on its own.
  bool get fullCatalogLoaded => historyList.isNotEmpty;

  /// Shows a freshly created product without switching the screen out of
  /// paginated mode.
  void _insertNewProduct(SearchModel newProduct) {
    if (fullCatalogLoaded) {
      historyList.insert(0, newProduct);
      productsList.insert(0, newProduct);
      searchResult.insert(0, newProduct);
      calculateTotals();
    }
    pageItems.insert(0, newProduct);
    totalCount.value = totalCount.value + 1;
    if (catalogTotalsLoaded.value) loadCatalogTotals();
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
      final count = product.count;

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
      // Downscale on pick: the server (nginx) rejects large bodies, and a full
      // resolution photo is far bigger than the catalogue needs.
      final XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (file != null) {
        final original = await file.readAsBytes();
        // Re-encode to WebP in the browser: nginx rejects bodies over its
        // limit and the API stores WebP anyway.
        final compressed = await compressImageForUpload(original, file.name);
        selectedImageBytes.value = compressed.bytes;
        selectedImageFileName.value = compressed.fileName;
        final kb = (compressed.bytes.lengthInBytes / 1024).round();
        CustomWidgets.showSnackBar(
            "Success", "Image selected: ${compressed.fileName} ($kb KB)", Colors.green);
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

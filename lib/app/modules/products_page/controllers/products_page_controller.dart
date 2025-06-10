import 'package:get/get.dart';

class ProductsPageController extends GetxController {
  RxInt page = 0.obs;
  RxInt limit = 20.obs;
  RxBool agreeButton = false.obs;
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
    loadingData.value = true;

    loadingData.value = false;
  }

  Future<void> onRefreshController() async {
    productsListHomeView.clear();
    loadingData.value = true;

    isFiltered.value = false;
    loadingData.value = false;
  }

  Future<void> onLoadingController() async {
    int length = productsListHomeView.length;
    loadingData.value = true;
    loadingData.value = false;
  }

  filterProducts(String filterName, String filterSearchName) {
    filteredName.value = filterName;
    filteredNameToSearch.value = filterSearchName;
    productsListHomeView.clear();
    loadingData.value = true;
  }
}

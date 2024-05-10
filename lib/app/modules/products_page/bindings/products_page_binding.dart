import 'package:get/get.dart';

import '../controllers/products_page_controller.dart';

class ProductsPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsPageController>(
      () => ProductsPageController(),
    );
  }
}

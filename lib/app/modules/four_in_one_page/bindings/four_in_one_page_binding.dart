import 'package:get/get.dart';

import '../controllers/four_in_one_page_controller.dart';

class FourInOnePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FourInOnePageController>(
      () => FourInOnePageController(),
    );
  }
}

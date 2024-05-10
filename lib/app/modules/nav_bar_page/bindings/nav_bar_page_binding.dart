import 'package:get/get.dart';

import '../controllers/nav_bar_page_controller.dart';

class NavBarPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavBarPageController>(
      () => NavBarPageController(),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/expences_controller.dart';

class ExpencesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpencesController>(
      () => ExpencesController(),
    );
  }
}

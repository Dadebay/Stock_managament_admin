import 'package:get/get.dart';

import '../controllers/enter_controller.dart';

class EnterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnterController>(
      () => EnterController(),
    );
  }
}

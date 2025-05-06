import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/products_page/views/web_add_product_page.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class RightSideButtons extends StatelessWidget {
  final SeacrhViewController searchViewController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: Colors.black,
          heroTag: "add_product",
          onPressed: () => Get.to(() => const WebAddProductPage()),
          child: const Icon(
            IconlyLight.plus,
            color: Colors.amber,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.w),
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            heroTag: "filter",
            onPressed: () => DialogsUtils.filterDialogSearchView(),
            child: const Icon(
              IconlyLight.filter2,
              color: Colors.amber,
            ),
          ),
        ),
        FloatingActionButton(
          heroTag: "viewChange",
          backgroundColor: Colors.black,
          onPressed: () {
            searchViewController.showInGrid.value = !searchViewController.showInGrid.value;
          },
          child: Obx(() {
            return Icon(
              searchViewController.showInGrid.value ? IconlyLight.paper : IconlyLight.category,
              color: Colors.amber,
            );
          }),
        ),
      ],
    );
  }
}

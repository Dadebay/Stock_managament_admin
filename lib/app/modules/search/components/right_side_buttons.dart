import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/views/web_add_product_page.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class RightSideButtons extends StatelessWidget {
  final SearchViewController searchViewController = Get.find();
  final bool isAdmin;

  RightSideButtons({super.key, required this.isAdmin});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isAdmin
            ? _action(
                icon: IconlyLight.plus,
                onTap: () => Get.to(() => const WebAddProductPage()),
              )
            : const SizedBox.shrink(),
        if (isAdmin) const SizedBox(height: 10),
        _action(
          icon: IconlyLight.filter2,
          onTap: DialogsUtils.filterDialogSearchView,
        ),
        const SizedBox(height: 10),
        Obx(() => _action(
              icon: searchViewController.showInGrid.value
                  ? IconlyLight.paper
                  : IconlyLight.category,
              onTap: () => searchViewController.showInGrid.value =
                  !searchViewController.showInGrid.value,
            )),
      ],
    );
  }

  Widget _action({required IconData icon, required VoidCallback onTap}) =>
      SizedBox(
        width: 42,
        height: 42,
        child: Material(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          elevation: 3,
          shadowColor: const Color(0xFF0F172A).withValues(alpha: .22),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Icon(icon, color: const Color(0xFFFACC15), size: 20),
          ),
        ),
      );
}

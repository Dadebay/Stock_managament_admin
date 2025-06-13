import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class BottomPriceSheet extends StatelessWidget {
  BottomPriceSheet({super.key});
  final SearchViewController searchViewController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const Divider(color: Colors.black, thickness: 1),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomWidgets.textWidgetPrice("countProducts".tr + '  ', searchViewController.productsList.length.toString()),
              CustomWidgets.textWidgetPrice("inStock".tr + ' :   ', searchViewController.sumCount.value.toString()),
              CustomWidgets.textWidgetPrice("costPrice".tr + ' :    ', '${searchViewController.sumCost.value.toStringAsFixed(0)} \$'),
              CustomWidgets.textWidgetPrice("sellPrice".tr + ' :   ', '${searchViewController.sumSell.value.toStringAsFixed(0)} \$'),
            ],
          )
        ],
      ),
    );
  }
}

class BottomPriceSheetPurchases extends StatelessWidget {
  BottomPriceSheetPurchases({super.key});
  final PurchasesController purchasesController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const Divider(color: Colors.black, thickness: 1),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomWidgets.textWidgetPrice('cost'.tr + ' :   ', purchasesController.sumCost.value.toStringAsFixed(2) + ' \$'),
            ],
          )
        ],
      ),
    );
  }
}

class BottomPriceSheetSalesView extends StatelessWidget {
  BottomPriceSheetSalesView({super.key});
  final OrderController salesController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          const Divider(color: Colors.black, thickness: 1),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomWidgets.textWidgetPrice("orderCount".tr + '   ', salesController.sumProductCount.value.toString()),
              CustomWidgets.textWidgetPrice("sellPrice".tr + ' :   ', '${salesController.sumPrice.toStringAsFixed(0)} \$'),
              CustomWidgets.textWidgetPrice("cost".tr + ' :    ', '${salesController.sumCost.value.toStringAsFixed(0)} \$'),
            ],
          )
        ],
      ),
    );
  }
}

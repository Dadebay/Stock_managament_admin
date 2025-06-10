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
              CustomWidgets.textWidgetPrice('Products:   ', searchViewController.productsList.length.toString()),
              CustomWidgets.textWidgetPrice('In Stock :   ', searchViewController.sumCount.value.toString()),
              CustomWidgets.textWidgetPrice('Sum Sell :   ', '${searchViewController.sumSell.value.toStringAsFixed(0)} \$'),
              CustomWidgets.textWidgetPrice('Sum Cost :    ', '${searchViewController.sumCost.value.toStringAsFixed(0)} \$'),
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
      child: Column(
        children: [
          const Divider(color: Colors.black, thickness: 1),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomWidgets.textWidgetPrice('Sum Cost :   ', purchasesController.sumCost.value.toStringAsFixed(2) + ' \$'),
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
              CustomWidgets.textWidgetPrice('Products :   ', salesController.sumProductCount.value.toString()),
              CustomWidgets.textWidgetPrice('Sum Sell :   ', '${salesController.sumPrice.toStringAsFixed(0)} \$'),
              CustomWidgets.textWidgetPrice('Sum Cost :    ', '${salesController.sumCost.value.toStringAsFixed(0)} \$'),
            ],
          )
        ],
      ),
    );
  }
}

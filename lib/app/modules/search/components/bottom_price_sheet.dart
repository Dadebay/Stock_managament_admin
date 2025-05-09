import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_controller.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/app/product/widgets/widgets.dart';

class BottomPriceSheet extends StatelessWidget {
  BottomPriceSheet({super.key});
  final SearchViewController searchViewController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.black, thickness: 1),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomWidgets.textWidgetPrice('Products :   ', searchViewController.sumCount.value.toString()),
            CustomWidgets.textWidgetPrice('Sum Sell :   ', '${searchViewController.sumSell.value.toStringAsFixed(0)} \$'),
            CustomWidgets.textWidgetPrice('Sum Cost :    ', '${searchViewController.sumCost.value.toStringAsFixed(0)} \$'),
          ],
        )
      ],
    );
  }
}

class BottomPriceSheetPurchases extends StatelessWidget {
  BottomPriceSheetPurchases({super.key});
  final PurchasesController purchasesController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.black, thickness: 1),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomWidgets.textWidgetPrice('Sum Cost :   ', purchasesController.sumCost.value.toStringAsFixed(2) + ' \$'),
          ],
        )
      ],
    );
  }
}

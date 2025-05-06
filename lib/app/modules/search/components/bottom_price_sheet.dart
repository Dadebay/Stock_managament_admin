import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/app/product/widgets/widgets.dart';

class BottomPriceSheet extends StatelessWidget {
  BottomPriceSheet({super.key});
  final SeacrhViewController searchViewController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.black, thickness: 1),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomWidgets.textWidgetPrice('Products :   ', searchViewController.sumCount.value.toString()),
            // CustomWidgets.textWidgetPrice('In Stock :   ', searchViewController.sumQuantity.value.toString()),
            CustomWidgets.textWidgetPrice('In Stock :   ', '-'),
            CustomWidgets.textWidgetPrice('Sum Sell :   ', '${searchViewController.sumSell.value.toStringAsFixed(0)} \$'),
            CustomWidgets.textWidgetPrice('Sum Cost :    ', '${searchViewController.sumCost.value.toStringAsFixed(0)} \$'),
          ],
        )
      ],
    );
  }
}

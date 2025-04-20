import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:stock_managament_admin/app/data/models/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/views/create_order.dart';
import 'package:stock_managament_admin/app/product/cards/ordered_card.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/widgets/widgets.dart';

import '../controllers/sales_controller.dart';

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  TextEditingController controller = TextEditingController();
  final SalesController salesController = Get.put(SalesController());

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    salesController.getData();
  }

  Future<dynamic> filter() {
    return Get.defaultDialog(
        title: 'Filter by',
        content: Container(
          width: Get.size.width / 5,
          height: Get.size.height / 2,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: ListView.builder(
            itemCount: StringConstants.statusList.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  salesController.filterProductsMine('status', StringConstants.statusList[index]['statusName']!);
                },
                title: Text(StringConstants.statusList[index]['name'].toString()),
                trailing: const Icon(IconlyLight.arrowRightCircle),
              );
            },
          ),
        ));
  }

  // ignore: non_constant_identifier_names
  Expanded MainBody() {
    return Expanded(
      child: Obx(() {
        if (salesController.loadingDataOrders.value == true) {
          return CustomWidgets.spinKit();
        } else if (salesController.orderedCardsSearchResult.isEmpty && controller.text.isNotEmpty) {
          return CustomWidgets.emptyData();
        } else if (salesController.orderCardList.isEmpty && salesController.loadingDataOrders.value == false) {
          return CustomWidgets.emptyData();
        } else {
          return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              itemCount: controller.text.isNotEmpty ? salesController.orderedCardsSearchResult.length : salesController.orderCardList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final order = controller.text.isEmpty
                    ? OrderModel(
                        orderID: salesController.orderCardList[index].id,
                        clientAddress: salesController.orderCardList[index]['client_address'],
                        clientName: salesController.orderCardList[index]['client_name'],
                        clientNumber: salesController.orderCardList[index]['client_number'],
                        coupon: salesController.orderCardList[index]['coupon'].toString(),
                        date: salesController.orderCardList[index]['date'],
                        discount: salesController.orderCardList[index]['discount'].toString(),
                        note: salesController.orderCardList[index]['note'],
                        package: salesController.orderCardList[index]['package'],
                        status: salesController.orderCardList[index]['status'],
                        sumCost: salesController.orderCardList[index]['sum_cost'].toString(),
                        sumPrice: salesController.orderCardList[index]['sum_price'].toString(),
                        products: salesController.orderCardList[index]['product_count'])
                    : OrderModel(
                        orderID: salesController.orderedCardsSearchResult[index].id,
                        clientAddress: salesController.orderedCardsSearchResult[index]['client_address'],
                        clientName: salesController.orderedCardsSearchResult[index]['client_name'],
                        clientNumber: salesController.orderedCardsSearchResult[index]['client_number'],
                        coupon: salesController.orderedCardsSearchResult[index]['coupon'].toString(),
                        date: salesController.orderedCardsSearchResult[index]['date'],
                        discount: salesController.orderedCardsSearchResult[index]['discount'].toString(),
                        note: salesController.orderedCardsSearchResult[index]['note'],
                        package: salesController.orderedCardsSearchResult[index]['package'],
                        status: salesController.orderedCardsSearchResult[index]['status'],
                        sumCost: salesController.orderedCardsSearchResult[index]['sum_cost'].toString(),
                        sumPrice: salesController.orderedCardsSearchResult[index]['sum_price'].toString(),
                        products: salesController.orderedCardsSearchResult[index]['product_count']);
                return Row(
                  children: [
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        "${index + 1}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 20.sp),
                      ),
                    ),
                    Expanded(child: OrderedCard(order: order))
                  ],
                );
              });
        }
      }),
    );
  }

  Padding searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          leading: const Icon(
            IconlyLight.search,
            color: Colors.black,
          ),
          title: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'search'.tr, border: InputBorder.none),
            onChanged: (String value) {
              salesController.onSearchTextChanged(value);
            },
          ),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            onPressed: () {
              controller.clear();
              salesController.onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: ScrollToHide(
            scrollController: _scrollController,
            height: 60, // Initial height of the bottom navigation bar.
            hideDirection: Axis.vertical,
            child: Column(
              children: [
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Obx(() {
                  return Row(
                    children: [
                      CustomWidgets.textWidgetPrice('Sold Products :   ', salesController.sumProductCount.value.toString()),
                      CustomWidgets.textWidgetPrice('Sum Price :   ', '${salesController.sumPrice.value.toStringAsFixed(2)} \$'),
                      CustomWidgets.textWidgetPrice('Sum Cost :    ', '${salesController.sumCost.value.toStringAsFixed(2)}  \$'),
                    ],
                  );
                })
              ],
            )),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "add_product",
              onPressed: () {
                Get.to(() => const CreateOrderView());
              },
              child: const Icon(IconlyLight.plus),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.w),
              child: FloatingActionButton(
                heroTag: "filter",
                onPressed: () {
                  filter();
                },
                child: const Icon(IconlyLight.filter2),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            searchWidget(),
            // CustomWidgets().topWidgetTextPart(addMorePadding: true, names: StringConstants.topPartNames, ordersView: true, clientView: false, purchasesView: false),
            MainBody()
          ],
        ));
  }
}

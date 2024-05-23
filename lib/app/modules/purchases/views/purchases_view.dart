import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:stock_managament_admin/app/data/models/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/create_purchase_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

import '../../../../constants/cards/purchase_card.dart';
import '../controllers/purchases_controller.dart';

class PurchasesView extends StatefulWidget {
  const PurchasesView({super.key});

  @override
  State<PurchasesView> createState() => _PurchasesViewState();
}

class _PurchasesViewState extends State<PurchasesView> {
  final PurchasesController purchasesController = Get.put(PurchasesController());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    purchasesController.getData();
  }

  // ignore: non_constant_identifier_names
  Widget MainBody() {
    return Expanded(
      child: Obx(() {
        if (purchasesController.loadingDataOrders.value == true) {
          return spinKit();
        } else if (purchasesController.purchasesMainList.isEmpty && purchasesController.loadingDataOrders.value == false) {
          return emptyData();
        } else {
          return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              itemCount: purchasesController.purchasesMainList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final purchases = PurchasesModel(
                    title: purchasesController.purchasesMainList[index]['title'].toString(),
                    date: purchasesController.purchasesMainList[index]['date'].toString(),
                    note: purchasesController.purchasesMainList[index]['note'].toString(),
                    cost: purchasesController.purchasesMainList[index]['cost'].toString(),
                    productsCount: purchasesController.purchasesMainList[index]['product_count'].toString(),
                    source: purchasesController.purchasesMainList[index]['source'].toString(),
                    purchasesID: purchasesController.purchasesMainList[index].id);

                return Row(
                  children: [
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        "${index + 1}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20.sp),
                      ),
                    ),
                    Expanded(
                        child: PurchaseCard(
                      showInProductProfil: false,
                      purchasesModel: purchases,
                    ))
                  ],
                );
              });
        }
      }),
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
            child: Wrap(
              children: [
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sum Cost :",
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                      ),
                      Text(
                        '${purchasesController.sumCost.value}  \$',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                      ),
                    ],
                  );
                })
              ],
            )),
        floatingActionButton: FloatingActionButton(
          heroTag: "add_purchase",
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
              return const CreatePurchasesView();
            }));
          },
          child: const Icon(IconlyLight.plus),
        ),
        body: Column(
          children: [topWidgetPurchases(false), MainBody()],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/data/models/product_model.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_admin/app/modules/products_page/views/web_add_product_page.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_controller.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_admin/app/modules/sales/views/select_order_products.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/cards/product_card.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class CreatePurchasesView extends StatefulWidget {
  const CreatePurchasesView({super.key});

  @override
  State<CreatePurchasesView> createState() => _CreatePurchasesViewState();
}

class _CreatePurchasesViewState extends State<CreatePurchasesView> {
  List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  final SalesController salesController = Get.put(SalesController());
  List<TextEditingController> textControllers = List.generate(4, (_) => TextEditingController());
  final PurchasesController purchasesController = Get.put(PurchasesController());
  final HomeController homeController = Get.put(HomeController());
  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    salesController.selectedProductsToOrder.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'Create Purchase'.tr),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        shrinkWrap: true,
        children: [
          CustomTextField(
              onTap: () {
                DateTime? selectedDateTime;
                showDateTimePicker(BuildContext context) async {
                  final result = await showDateTimePickerWidget(context: context);
                  if (result != null) {
                    setState(() {
                      selectedDateTime = result;
                      textControllers[0].text = DateFormat('yyyy-MM-dd , HH:mm').format(selectedDateTime!);
                    });
                  }
                }

                showDateTimePicker(context);
              },
              labelName: "date",
              borderRadius: true,
              controller: textControllers[0],
              focusNode: focusNodes[0],
              requestfocusNode: focusNodes[1],
              unFocus: false,
              readOnly: true),
          CustomTextField(labelName: "Title", borderRadius: true, controller: textControllers[1], focusNode: focusNodes[1], requestfocusNode: focusNodes[2], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Source", borderRadius: true, controller: textControllers[2], focusNode: focusNodes[2], requestfocusNode: focusNodes[3], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Note", borderRadius: true, controller: textControllers[3], focusNode: focusNodes[3], requestfocusNode: focusNodes[0], unFocus: false, readOnly: true),
          selectedProductsView(),
          SizedBox(
            height: 20.h,
          ),
          AgreeButton(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                  return const SelectOrderProducts(purchaseView: true);
                }));
              },
              text: 'selectProducts'),
          AgreeButton(
              onTap: () {
                if (homeController.agreeButton.value == false) {
                  homeController.agreeButton.value = !homeController.agreeButton.value;
                  if (salesController.selectedProductsToOrder.isEmpty) {
                    showSnackBar('errorTitle', 'selectMoreProducts', Colors.red);
                  } else {
                    purchasesController.sumbitSale(textControllers: textControllers);
                  }
                } else {
                  showSnackBar("Please wait", "Please wait while we create purchase data in our server", Colors.purple);
                }
              },
              text: 'agree'),
          SizedBox(
            height: 30.h,
          )
        ],
      ),
    );
  }

  Obx selectedProductsView() {
    return Obx(() {
      return salesController.selectedProductsToOrder.isEmpty
          ? const SizedBox.shrink()
          : Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h, left: 10.w, bottom: 10.h),
                  child: Text(
                    "selectedProducts".tr,
                    style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 22.sp),
                  ),
                ),
                ListView.builder(
                  itemCount: salesController.selectedProductsToOrder.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductModel product = salesController.selectedProductsToOrder[index]['product'];
                    return ProductCard(
                      product: product,
                      addCounterWidget: true,
                      disableOnTap: false,
                      purchaseView: false,
                    );
                  },
                ),
              ],
            );
    });
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/views/search_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class CreateOrderView extends StatefulWidget {
  const CreateOrderView({super.key});

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  List<FocusNode> focusNodes = List.generate(9, (_) => FocusNode());
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  final SalesController salesController = Get.put(SalesController());
  String selectedStatus = "Preparing"; // Set an initial value
  List<TextEditingController> textControllers = List.generate(9, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    // salesController.selectedProductsToOrder.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'createOrder'.tr),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        shrinkWrap: true,
        children: [
          CustomTextField(
            labelName: "date",
            controller: textControllers[0],
            focusNode: focusNodes[0],
            requestfocusNode: focusNodes[1],
          ),
          Container(
            margin: EdgeInsets.only(top: 15.h),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            decoration: BoxDecoration(
                borderRadius: context.border.highBorderRadius, // Add border radius
                border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
                items: <String>["Preparing", "Ready to ship", "Shipped", "Canceled", "Refund"].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          CustomTextField(
            labelName: "package",
            controller: textControllers[1],
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
          ),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  PhoneNumberTextField(
                    mineFocus: focusNodes[2],
                    controller: textControllers[2],
                    requestFocus: focusNodes[3],
                    style: false,
                    unFocus: true,
                  ),
                  CustomTextField(
                    labelName: "userName",
                    controller: textControllers[3],
                    focusNode: focusNodes[3],
                    requestfocusNode: focusNodes[4],
                  ),
                ],
              )),
          CustomTextField(
            labelName: "clientAddress",
            controller: textControllers[4],
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[5],
          ),
          CustomTextField(
            labelName: "Coupon",
            controller: textControllers[5],
            focusNode: focusNodes[5],
            requestfocusNode: focusNodes[6],
          ),
          CustomTextField(
            labelName: "Discount",
            controller: textControllers[7],
            focusNode: focusNodes[6],
            requestfocusNode: focusNodes[7],
          ),
          CustomTextField(
            labelName: "note",
            maxLine: 3,
            controller: textControllers[6],
            focusNode: focusNodes[7],
            requestfocusNode: focusNodes[0],
          ),
          // selectedProductsView(),
          AgreeButton(
              onTap: () {
                Get.to(() => const SearchView(selectableProducts: true));
              },
              text: 'selectProducts'),
          AgreeButton(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // if (salesController.selectedProductsToOrder.isEmpty) {
                  //   CustomWidgets.showSnackBar('errorTitle', 'selectMoreProducts', Colors.red);
                  // } else {
                  //   // salesController.sumbitSale(textControllers: textControllers, status: selectedStatus);
                  //   Navigator.of(context).pop();
                  // }
                } else {
                  CustomWidgets.showSnackBar('errorTitle', 'loginErrorFillBlanks', Colors.red);
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

  // Obx selectedProductsView() {
  //   return Obx(() {
  //     return salesController.selectedProductsToOrder.isEmpty
  //         ? const SizedBox.shrink()
  //         : Wrap(
  //             children: [
  //               Padding(
  //                 padding: EdgeInsets.only(top: 10.h, left: 10.w, bottom: 10.h),
  //                 child: Text(
  //                   "selectedProducts".tr,
  //                   style: TextStyle(color: Colors.black, fontSize: 22.sp),
  //                 ),
  //               ),
  //               ListView.builder(
  //                 itemCount: salesController.selectedProductsToOrder.length,
  //                 shrinkWrap: true,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   final SearchModel product = salesController.selectedProductsToOrder[index];
  //                   return SearchCard(
  //                     product: product,
  //                     disableOnTap: false,
  //                     addCounterWidget: false,
  //                   );
  //                 },
  //               ),
  //             ],
  //           );
  //   });
  // }
}

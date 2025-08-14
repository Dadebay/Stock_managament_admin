import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/search/views/search_view.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderCreateView extends StatefulWidget {
  const OrderCreateView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<OrderCreateView> createState() => _OrderCreateViewState();
}

class _OrderCreateViewState extends State<OrderCreateView> {
  List<FocusNode> focusNodes = List.generate(9, (_) => FocusNode());
  final SearchViewController _searchController = Get.find<SearchViewController>();

  String selectedStatus = "Preparing"; // Set an initial value
  List<TextEditingController> textControllers = List.generate(9, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    _searchController.selectedProductsToOrder.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'createOrder'.tr),
      body: ListView(
        padding: Get.size.width > 1000 ? EdgeInsets.symmetric(horizontal: Get.size.width / 5) : context.padding.horizontalMedium,
        children: [
          CustomTextField(
            onTap: () {
              DateTime? selectedDateTime;
              showDateTimePicker(BuildContext context) async {
                final result = await CustomWidgets.showDateTimePickerWidget(context: context);
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
            controller: textControllers[0],
            focusNode: focusNodes[0],
            requestfocusNode: focusNodes[1],
          ),
          Container(
            margin: EdgeInsets.only(top: 15.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorConstants.greyColor.withOpacity(.5), width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                focusColor: Colors.transparent,
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
            isNumberOnly: true,
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
          selectedProductsView(),
          AgreeButton(
              onTap: () {
                Get.to(() => SearchView(selectableProducts: true, addCounterWidget: true, isAdmin: widget.isAdmin));
              },
              text: 'selectProducts'),
          submitOrder(),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  final OrderController _orderController = Get.find<OrderController>();

  AgreeButton submitOrder() {
    return AgreeButton(
        onTap: () async {
          int key = 0;
          for (var status in StringConstants.statusMapping) {
            if (status['name'] == selectedStatus) {
              key = int.parse(status['sortName'].toString());
            }
          }
          if (_formKey.currentState!.validate()) {
            List<Map<String, int>> products = [];
            _searchController.selectedProductsToOrder.forEach(
              (element) {
                products.add({'id': element['product'].id, 'count': element['count']});
              },
            );
            final OrderModel model = OrderModel(
              id: 0,
              status: key.toString(),
              date: textControllers[0].text.substring(0, 10),
              gaplama: textControllers[1].text,
              coupon: textControllers[5].text,
              discount: textControllers[7].text,
              description: textControllers[6].text,
              name: "${textControllers[3].text} - ${textControllers[2].text}",
              clientID: 0,
              clientDetailModel: ClientDetailModel(
                id: 0,
                name: textControllers[3].text,
                address: textControllers[4].text,
                phone: textControllers[2].text,
                description: textControllers[6].text,
                ordercount: '',
                sumprice: '',
              ),
              products: [],
              count: _searchController.selectedProductsToOrder.length,
              totalsum: '',
              totalchykdajy: '',
            );
            await _orderController.createNewOrder(model: model, products: products);
          } else {
            CustomWidgets.showSnackBar('errorTitle', 'loginErrorFillBlanks', Colors.red);
          }
        },
        text: 'agree');
  }

  Obx selectedProductsView() {
    return Obx(() {
      return _searchController.selectedProductsToOrder.isEmpty
          ? const SizedBox.shrink()
          : Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h, left: 10.w, bottom: 10.h),
                  child: Text(
                    "selectedProducts".tr,
                    style: TextStyle(color: Colors.black, fontSize: 22.sp),
                  ),
                ),
                ListView.builder(
                  itemCount: _searchController.selectedProductsToOrder.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final SearchModel product = _searchController.selectedProductsToOrder[index]['product'];
                    return SearchCard(
                        product: product, disableOnTap: false, addCounterWidget: true, isAdmin: widget.isAdmin, whcihPage: '', counter: _searchController.selectedProductsToOrder.length - index);
                  },
                ),
              ],
            );
    });
  }
}

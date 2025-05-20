import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/modules/search/views/search_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class CreatePurchasesView extends StatefulWidget {
  const CreatePurchasesView({super.key});

  @override
  State<CreatePurchasesView> createState() => _CreatePurchasesViewState();
}

class _CreatePurchasesViewState extends State<CreatePurchasesView> {
  List<FocusNode> focusNodes = List.generate(5, (_) => FocusNode());
  final SearchViewController _searchController = Get.find<SearchViewController>();
  List<TextEditingController> textControllers = List.generate(5, (_) => TextEditingController());
  final PurchasesController purchasesController = Get.put(PurchasesController());
  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'Create Purchase'.tr),
      body: ListView(
        padding: Get.size.width > 1000 ? EdgeInsets.symmetric(horizontal: Get.size.width / 5) : context.padding.horizontalMedium,
        shrinkWrap: true,
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
          CustomTextField(
            labelName: "Title",
            controller: textControllers[1],
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
          ),
          CustomTextField(
            labelName: "Source",
            controller: textControllers[2],
            focusNode: focusNodes[2],
            requestfocusNode: focusNodes[3],
          ),
          CustomTextField(
            labelName: "Cost",
            maxLine: 1,
            controller: textControllers[3],
            focusNode: focusNodes[3],
            requestfocusNode: focusNodes[4],
          ),
          CustomTextField(
            labelName: "Description",
            maxLine: 5,
            controller: textControllers[4],
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[0],
          ),
          selectedProductsView(),
          AgreeButton(onTap: () => Get.to(() => SearchView(selectableProducts: true, whichPage: 'purhcase')), text: 'selectProducts'),
          AgreeButton(
              onTap: () async {
                List<Map<String, int>> products = [];
                _searchController.selectedProductsToOrder.forEach(
                  (element) {
                    products.add({'id': element['product'].id, 'count': element['count']});
                  },
                );
                print(products);
                final PurchasesModel model = PurchasesModel(
                  title: textControllers[1].text,
                  date: textControllers[0].text.substring(0, 10),
                  source: textControllers[2].text,
                  description: textControllers[4].text,
                  id: 0,
                  cost: textControllers[3].text,
                  count: 0,
                  products: [],
                );
                await PurchasesService().addPurchase(model: model, products: products);
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
      if (_searchController.selectedProductsToOrder.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "selectedProducts".tr,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.sp),
                  ),
                  Text(
                    _searchController.selectedProductsToOrder.length.toString(),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.sp),
                  ),
                ],
              ),
            ),
            ListView.builder(
              itemCount: _searchController.selectedProductsToOrder.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return SearchCard(
                  product: _searchController.selectedProductsToOrder[index]['product'],
                  disableOnTap: false,
                  addCounterWidget: true,
                  whcihPage: 'purhcase',
                );
              },
            ),
          ],
        );
      }
    });
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_service.dart';
import 'package:stock_managament_admin/app/modules/sales/views/order_card.dart';
import 'package:stock_managament_admin/app/modules/sales/views/order_create.dart';
import 'package:stock_managament_admin/app/modules/search/components/bottom_price_sheet.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  TextEditingController searchController = TextEditingController();
  final OrderController orderController = Get.put(OrderController());

  dynamic _rightSideButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.isAdmin
            ? FloatingActionButton(
                heroTag: "add_product",
                backgroundColor: ColorConstants.blackColor,
                onPressed: () {
                  Get.to(() => OrderCreateView(isAdmin: widget.isAdmin));
                },
                child: Icon(
                  IconlyLight.plus,
                  color: Colors.amber,
                ),
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.w),
          child: FloatingActionButton(
            backgroundColor: ColorConstants.blackColor,
            heroTag: "filter",
            onPressed: () => DialogsUtils.orderFilterDialog(),
            child: const Icon(
              IconlyLight.filter2,
              color: Colors.amber,
            ),
          ),
        ),
      ],
    );
  }

  SearchWidget _searchWidget() {
    return SearchWidget(
      controller: searchController,
      onChanged: (value) {
        orderController.onSearchTextChanged(value);
      },
      onClear: () {
        searchController.clear();
        orderController.searchResult.clear();
      },
    );
  }

  ListviewTopText<OrderModel> _topText(List<OrderModel> displayList) {
    return ListviewTopText<OrderModel>(
      names: StringConstants.orderNamesList,
      listToSort: displayList,
      setSortedList: (newList) {
        if (searchController.text.isNotEmpty) {
          orderController.searchResult.assignAll(newList);
        } else {
          orderController.allOrders.assignAll(newList);
        }
      },
      getSortValue: (model, key) {
        switch (key) {
          case 'name':
            return model.name.toLowerCase() ?? '';
          case 'date':
            return model.date;
          case 'count':
            return model.count ?? 0;
          case 'totalsum':
            return double.tryParse(model.totalsum.replaceAll(',', '.')) ?? 0.0;
          case 'totalchykdajy':
            return double.tryParse(model.totalchykdajy.replaceAll(',', '.')) ?? 0.0;
          case 'status':
            return model.status;
          default:
            return '';
        }
      },
    );
  }

  ListView listViewStyle(List<OrderModel> list) {
    return ListView.builder(
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return OrderCardView(order: list[index], isAdmin: widget.isAdmin, index: list.length - index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<OrderModel>>(
        future: OrderService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return CustomWidgets.emptyData();
          }
          orderController.allOrders.assignAll(snapshot.data!);
          orderController.searchResult.assignAll(snapshot.data!);
          orderController.calculateTotals();
          return Obx(() {
            final isSearching = searchController.text.isNotEmpty;
            final hasResult = orderController.searchResult.isNotEmpty;
            final displayList = (isSearching) ? (hasResult ? orderController.searchResult.toList() : <OrderModel>[]) : orderController.allOrders.toList();
            return Stack(
              children: [
                Column(
                  children: [
                    _searchWidget(),
                    _topText(displayList),
                    Expanded(
                        child: displayList.isEmpty && isSearching
                            ? Center(child: Text("No results found for '${searchController.text}'"))
                            : displayList.isEmpty
                                ? CustomWidgets.emptyData()
                                : listViewStyle(displayList))
                  ],
                ),
                Positioned(
                  bottom: 70.0,
                  right: 20.0,
                  child: _rightSideButtons(),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: BottomPriceSheetSalesView(),
                )
              ],
            );
          });
        },
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/create_purchase_view.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchase_card.dart';
import 'package:stock_managament_admin/app/modules/search/components/bottom_price_sheet.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

class PurchasesView extends StatefulWidget {
  const PurchasesView({super.key});

  @override
  State<PurchasesView> createState() => _PurchasesViewState();
}

class _PurchasesViewState extends State<PurchasesView> {
  final PurchasesController purchasesController = Get.put(PurchasesController());
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<PurchasesModel>>(
        future: PurchasesService().getPurchases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return CustomWidgets.emptyData();
          }
          purchasesController.purchasesMainList.assignAll(snapshot.data!.toList());
          purchasesController.calculateTotals();
          return Obx(() {
            final isSearching = searchController.text.isNotEmpty;
            final hasResult = purchasesController.searchResult.isNotEmpty;
            final displayList = (isSearching) ? (hasResult ? purchasesController.searchResult.toList() : <PurchasesModel>[]) : purchasesController.purchasesMainList.toList();
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
                                : ListView.builder(
                                    itemCount: displayList.length,
                                    padding: context.padding.onlyBottomHigh,
                                    itemBuilder: (context, index) {
                                      return PurchaseCard(
                                        purchasesModel: displayList[index],
                                        showInProductProfil: false,
                                        index: displayList.length - index,
                                      );
                                    },
                                  )),
                  ],
                ),
                Positioned(
                  bottom: 70.0,
                  right: 20.0,
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    heroTag: "add_purchase",
                    onPressed: () {
                      Get.to(() => CreatePurchasesView());
                    },
                    child: const Icon(
                      IconlyLight.plus,
                      color: Colors.amber,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: BottomPriceSheetPurchases(),
                )
              ],
            );
          });
        },
      ),
    );
  }

  Widget _topText(List<PurchasesModel> displayList) {
    return ListviewTopText<PurchasesModel>(
      names: StringConstants.topPartNamesPurchases,
      listToSort: displayList,
      setSortedList: (newList) {
        if (searchController.text.isNotEmpty && purchasesController.searchResult.isNotEmpty) {
          purchasesController.searchResult.assignAll(newList);
        } else {
          purchasesController.purchasesMainList.assignAll(newList);
        }
      },
      getSortValue: (model, key) {
        switch (key) {
          case 'title':
            return model.title;
          case 'date':
            return model.date;
          case 'source':
            return model.source;
          case 'count':
            return model.count;
          case 'cost':
            return model.cost;
          default:
            return '';
        }
      },
    );
  }

  SearchWidget _searchWidget() {
    return SearchWidget(
      controller: searchController,
      onChanged: (value) {
        purchasesController.onSearchTextChanged(value);
      },
      onClear: () {
        searchController.clear();
        purchasesController.searchResult.clear();
      },
    );
  }
}

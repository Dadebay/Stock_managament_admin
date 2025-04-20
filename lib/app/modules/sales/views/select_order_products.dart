import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/widgets.dart';

class SelectOrderProducts extends StatefulWidget {
  const SelectOrderProducts({required this.purchaseView});
  final bool purchaseView;
  @override
  State<SelectOrderProducts> createState() => _SelectOrderProductsState();
}

class _SelectOrderProductsState extends State<SelectOrderProducts> {
  final SalesController salesController = Get.put(SalesController());
  final SeacrhViewController seacrhViewController = Get.put(SeacrhViewController());
  TextEditingController controller = TextEditingController();
  List _searchResult = [];
  @override
  void initState() {
    super.initState();
    if (seacrhViewController.productsList.isEmpty) {
      seacrhViewController.getClientStream();
    }
  }

  onSearchTextChanged(String word) async {
    salesController.loadingDataOrders.value = true;
    _searchResult.clear();
    List fullData = [];
    List<String> words = word.toLowerCase().trim().split(' ');
    fullData = seacrhViewController.productsList.where((p) {
      bool result = true;
      for (final word in words) {
        if (!p['name'].toLowerCase().contains(word)) {
          result = false;
        }
      }
      return result;
    }).toList();
    _searchResult = fullData.toSet().toList();
    salesController.loadingDataOrders.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'selectProducts'),
        body: Column(
          children: [
            Padding(
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
                    onChanged: onSearchTextChanged,
                  ),
                  contentPadding: EdgeInsets.only(left: 15.w),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                return _searchResult.isNotEmpty || controller.text.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        itemCount: _searchResult.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, i) {
                          final product = ProductModel(
                            name: _searchResult[i]['name'],
                            brandName: _searchResult[i]['brand'].toString(),
                            category: _searchResult[i]['category'].toString(),
                            cost: _searchResult[i]['cost'].toString(),
                            gramm: _searchResult[i]['gramm'].toString(),
                            image: _searchResult[i]['image'].toString(),
                            location: _searchResult[i]['location'].toString(),
                            material: _searchResult[i]['material'].toString(),
                            quantity: int.parse(_searchResult[i]['quantity'].toString()),
                            sellPrice: _searchResult[i]['sell_price'].toString(),
                            note: _searchResult[i]['note'].toString(),
                            package: _searchResult[i]['package'].toString(),
                            documentID: _searchResult[i].id,
                          );
                          return ProductCard(
                            addCounterWidget: true,
                            disableOnTap: false,
                            purchaseView: widget.purchaseView,
                            product: product,
                          );
                        },
                      )
                    : salesController.loadingDataOrders.value == true
                        ? CustomWidgets.spinKit()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            itemCount: seacrhViewController.productsList.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              final product = ProductModel(
                                name: seacrhViewController.productsList[index]['name'],
                                brandName: seacrhViewController.productsList[index]['brand'].toString(),
                                category: seacrhViewController.productsList[index]['category'].toString(),
                                cost: seacrhViewController.productsList[index]['cost'].toString(),
                                gramm: seacrhViewController.productsList[index]['gramm'].toString(),
                                image: seacrhViewController.productsList[index]['image'].toString(),
                                location: seacrhViewController.productsList[index]['location'].toString(),
                                material: seacrhViewController.productsList[index]['material'].toString(),
                                quantity: int.parse(seacrhViewController.productsList[index]['quantity'].toString()),
                                sellPrice: seacrhViewController.productsList[index]['sell_price'].toString(),
                                note: seacrhViewController.productsList[index]['note'].toString(),
                                package: seacrhViewController.productsList[index]['package'].toString(),
                                documentID: seacrhViewController.productsList[index].id,
                              );
                              return ProductCard(
                                addCounterWidget: true,
                                purchaseView: widget.purchaseView,
                                disableOnTap: false,
                                product: product,
                              );
                            },
                          );
              }),
            ),
          ],
        ));
  }
}

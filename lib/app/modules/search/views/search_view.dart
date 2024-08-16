import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:stock_managament_admin/app/data/models/product_model.dart';
import 'package:stock_managament_admin/app/modules/products_page/views/web_add_product_page.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/constants/cards/product_card.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController controller = TextEditingController();
  final SeacrhViewController searchViewController = Get.put(SeacrhViewController());
  List filters = [
    {'name': 'Brands', 'searchName': 'brand'},
    {'name': 'Categories', 'searchName': 'category'},
    {'name': 'Locations', 'searchName': 'location'},
    {'name': 'Materials', 'searchName': 'material'}
  ];
  List topPartNames = [
    {'name': 'Product Name', 'sortName': "quantity"},
    {'name': '   Cost', 'sortName': "cost"},
    {'name': 'Sell Price', 'sortName': "sell_price"},
    {'name': 'Brand', 'sortName': "brand"},
    {'name': 'Category', 'sortName': "category"},
  ];
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchViewController.getClientStream();
  }

  Future<dynamic> filter() {
    return Get.defaultDialog(
        title: 'Filter',
        content: Container(
          width: Get.size.width / 3,
          height: Get.size.height / 2,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: ListView.builder(
            itemCount: filters.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  Get.defaultDialog(
                      title: filters[index]['name'],
                      content: Container(
                        width: Get.size.width / 3,
                        height: Get.size.height / 2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection(filters[index]['name'].toLowerCase()).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (BuildContext context, int indexx) {
                                    return ListTile(
                                      onTap: () {
                                        searchViewController.filterProductsMine(filters[index]['searchName'], snapshot.data!.docs[indexx]['name']);
                                      },
                                      title: Text(snapshot.data!.docs[indexx]['name']),
                                    );
                                  },
                                );
                              }
                              return Center(
                                child: spinKit(),
                              );
                            }),
                      ));
                },
                title: Text(filters[index]['name'].toString()),
                trailing: const Icon(IconlyLight.arrowRightCircle),
              );
            },
          ),
        ));
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
                      textWidgetPrice('Products :   ', searchViewController.sumCount.value.toString()),
                      textWidgetPrice('In Stock :   ', searchViewController.sumQuantity.value.toString()),
                      textWidgetPrice('Sum Sell :   ', '${searchViewController.sumSell.value.toStringAsFixed(0)} \$'),
                      textWidgetPrice('Sum Cost :    ', '${searchViewController.sumCost.value.toStringAsFixed(0)} \$'),
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
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                  return const WebAddProductPage();
                }));
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
            FloatingActionButton(
              heroTag: "viewChange",
              backgroundColor: Colors.black,
              onPressed: () {
                searchViewController.showInGrid.value = !searchViewController.showInGrid.value;
              },
              child: Obx(() {
                return Icon(
                  searchViewController.showInGrid.value ? IconlyLight.paper : IconlyLight.category,
                  color: Colors.amber,
                );
              }),
            ),
          ],
        ),
        body: Column(
          children: [
            searchWidget(),
            Obx(() {
              return Center(
                child: searchViewController.showInGrid.value
                    ? const SizedBox.shrink()
                    : topWidgetTextPart(addMorePadding: true, names: topPartNames, ordersView: false, clientView: false, purchasesView: false),
              );
            }),
            MainBody()
          ],
        ));
  }

  // ignore: non_constant_identifier_names
  Expanded MainBody() {
    return Expanded(
      child: Obx(() {
        return searchViewController.loadingData.value == true
            ? spinKit()
            : searchViewController.searchResult.isEmpty && controller.text.isNotEmpty
                ? emptyData()
                : searchViewController.productsList.isEmpty
                    ? emptyData()
                    : searchViewController.showInGrid.value
                        ? gridViewStyle()
                        : listViewStyle();
      }),
    );
  }

  GridView gridViewStyle() {
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Get.size.width > 1000 ? 6 : 4, mainAxisSpacing: 20),
        itemCount: controller.text.isNotEmpty ? searchViewController.searchResult.length : searchViewController.productsList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final product = controller.text.isEmpty
              ? ProductModel(
                  name: searchViewController.productsList[index]['name'],
                  brandName: searchViewController.productsList[index]['brand'].toString(),
                  category: searchViewController.productsList[index]['category'].toString(),
                  cost: searchViewController.productsList[index]['cost'].toString(),
                  gramm: searchViewController.productsList[index]['gramm'].toString(),
                  image: searchViewController.productsList[index]['image'].toString(),
                  location: searchViewController.productsList[index]['location'].toString(),
                  material: searchViewController.productsList[index]['material'].toString(),
                  quantity: int.parse(searchViewController.productsList[index]['quantity'].toString()),
                  sellPrice: searchViewController.productsList[index]['sell_price'].toString(),
                  note: searchViewController.productsList[index]['note'].toString(),
                  package: searchViewController.productsList[index]['package'].toString(),
                  date: searchViewController.productsList[index]['date'].toString(),
                  documentID: searchViewController.productsList[index].id,
                )
              : ProductModel(
                  name: searchViewController.searchResult[index]['name'].toString(),
                  brandName: searchViewController.searchResult[index]['brand'].toString(),
                  category: searchViewController.searchResult[index]['category'].toString(),
                  cost: searchViewController.searchResult[index]['cost'].toString(),
                  gramm: searchViewController.searchResult[index]['gramm'].toString(),
                  image: searchViewController.searchResult[index]['image'].toString(),
                  location: searchViewController.searchResult[index]['location'].toString(),
                  material: searchViewController.searchResult[index]['material'].toString(),
                  quantity: int.parse(searchViewController.searchResult[index]['quantity'].toString()),
                  sellPrice: searchViewController.searchResult[index]['sell_price'].toString(),
                  note: searchViewController.searchResult[index]['note'].toString(),
                  package: searchViewController.searchResult[index]['package'].toString(),
                  documentID: searchViewController.searchResult[index].id,
                );
          return SecondProductCard(
            product: product,
          );
        });
  }

  ListView listViewStyle() {
    return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        itemCount: controller.text.isNotEmpty ? searchViewController.searchResult.length : searchViewController.productsList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final product = controller.text.isEmpty
              ? ProductModel(
                  name: searchViewController.productsList[index]['name'],
                  brandName: searchViewController.productsList[index]['brand'].toString(),
                  category: searchViewController.productsList[index]['category'].toString(),
                  cost: searchViewController.productsList[index]['cost'].toString(),
                  gramm: searchViewController.productsList[index]['gramm'].toString(),
                  image: searchViewController.productsList[index]['image'].toString(),
                  location: searchViewController.productsList[index]['location'].toString(),
                  material: searchViewController.productsList[index]['material'].toString(),
                  quantity: int.parse(searchViewController.productsList[index]['quantity'].toString()),
                  sellPrice: searchViewController.productsList[index]['sell_price'].toString(),
                  note: searchViewController.productsList[index]['note'].toString(),
                  package: searchViewController.productsList[index]['package'].toString(),
                  date: searchViewController.productsList[index]['date'].toString(),
                  documentID: searchViewController.productsList[index].id,
                )
              : ProductModel(
                  name: searchViewController.searchResult[index]['name'].toString(),
                  brandName: searchViewController.searchResult[index]['brand'].toString(),
                  category: searchViewController.searchResult[index]['category'].toString(),
                  cost: searchViewController.searchResult[index]['cost'].toString(),
                  gramm: searchViewController.searchResult[index]['gramm'].toString(),
                  image: searchViewController.searchResult[index]['image'].toString(),
                  location: searchViewController.searchResult[index]['location'].toString(),
                  material: searchViewController.searchResult[index]['material'].toString(),
                  quantity: int.parse(searchViewController.searchResult[index]['quantity'].toString()),
                  sellPrice: searchViewController.searchResult[index]['sell_price'].toString(),
                  note: searchViewController.searchResult[index]['note'].toString(),
                  package: searchViewController.searchResult[index]['package'].toString(),
                  documentID: searchViewController.searchResult[index].id,
                );
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
                child: ProductCard(
                  purchaseView: false,
                  addCounterWidget: false,
                  disableOnTap: false,
                  product: product,
                ),
              )
            ],
          );
        });
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
              searchViewController.onSearchTextChanged(value);
            },
          ),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            onPressed: () {
              controller.clear();
              // searchViewController.onSearchTextChanged('');
              searchViewController.clearFilter();
            },
          ),
        ),
      ),
    );
  }
}

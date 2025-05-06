import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/components/bottom_price_sheet.dart';
import 'package:stock_managament_admin/app/modules/search/components/right_side_buttons.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/product_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

import '../../../product/init/packages.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final SeacrhViewController searchViewController = Get.put(SeacrhViewController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<ProductModel>>(
        future: ProductsService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            print(snapshot.error);

            return CustomWidgets.errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return CustomWidgets.emptyData();
          }

          print(snapshot.data!);
          if (searchViewController.productsList.isEmpty && snapshot.hasData) {
            searchViewController.productsList.assignAll(snapshot.data!);
          }

          return Obx(() {
            final isSearching = searchController.text.isNotEmpty;
            final hasResult = searchViewController.searchResult.isNotEmpty;

            final displayList = (isSearching) ? (hasResult ? searchViewController.searchResult.toList() : <ProductModel>[]) : searchViewController.productsList.toList();

            return Stack(
              children: [
                Column(
                  children: [
                    SearchWidget(
                      controller: searchController,
                      onChanged: (value) {
                        searchViewController.onSearchTextChanged(value);
                      },
                      onClear: () {
                        searchController.clear();
                        searchViewController.searchResult.clear();
                      },
                    ),
                    ListviewTopText<ProductModel>(
                      names: StringConstants.searchViewtopPartNames,
                      listToSort: displayList,
                      setSortedList: (newList) {
                        if (searchController.text.isNotEmpty && searchViewController.searchResult.isNotEmpty) {
                          searchViewController.searchResult.assignAll(newList);
                        } else {
                          searchViewController.productsList.assignAll(newList);
                        }
                      },
                      getSortValue: (model, key) {
                        switch (key) {
                          case 'name':
                            return model.name;
                          case 'price':
                            return model.price;
                          case 'cost':
                            return model.cost;
                          case 'count':
                            return model.count;
                          case 'brend':
                            return model.brend;
                          case 'category':
                            return model.category;
                          case 'gramm':
                            return model.gramm;
                          default:
                            return '';
                        }
                      },
                    ),
                    Expanded(
                        child: displayList.isEmpty && isSearching
                            ? Center(child: Text("No results found for '${searchController.text}'"))
                            : displayList.isEmpty
                                ? CustomWidgets.emptyData()
                                : (searchViewController.showInGrid.value ? gridViewStyle(displayList) : listViewStyle(displayList)))
                  ],
                ),
                Positioned(
                  bottom: 70.0,
                  right: 20.0,
                  child: RightSideButtons(),
                ),
                Positioned(
                  bottom: 15.0,
                  left: 0.0,
                  right: 0.0,
                  child: BottomPriceSheet(),
                )
              ],
            );
          });
        },
      ),
    );
  }

  GridView gridViewStyle(List<ProductModel> list) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Get.size.width > 1000 ? 6 : 4, mainAxisSpacing: 20, childAspectRatio: 0.8),
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Card(child: Center(child: Text(list[index].name)));
        });
  }

  ListView listViewStyle(List<ProductModel> list) {
    return ListView.builder(
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: [
              Container(
                width: 40.w,
                padding: EdgeInsets.only(right: 10.w),
                alignment: Alignment.centerRight,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(color: Colors.black54, fontSize: 16.sp),
                ),
              ),
              Expanded(
                child: ProductCard(
                  disableOnTap: false,
                  product: list[index],
                ),
              )
            ],
          );
        });
  }
}

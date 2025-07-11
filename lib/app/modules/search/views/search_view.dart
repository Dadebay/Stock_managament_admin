import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/components/bottom_price_sheet.dart';
import 'package:stock_managament_admin/app/modules/search/components/right_side_buttons.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

import '../../../product/init/packages.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.selectableProducts, this.whichPage});
  final bool selectableProducts;
  final String? whichPage;
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final SearchViewController searchViewController = Get.put(SearchViewController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.selectableProducts
          ? CustomAppBar(
              backArrow: true,
              centerTitle: true,
              actionIcon: false,
              name: 'Select products to add'.tr,
            )
          : null,
      body: FutureBuilder<List<SearchModel>>(
        future: SearchService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return CustomWidgets.emptyData();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            searchViewController.historyList.assignAll(snapshot.data!.toList());
            searchViewController.productsList.assignAll(snapshot.data!.toList());
            searchViewController.searchResult.assignAll(snapshot.data!.toList());
            searchViewController.calculateTotals();
          });

          return Obx(() {
            final isSearching = searchController.text.isNotEmpty;
            final hasResult = searchViewController.searchResult.isNotEmpty;
            final displayList = (isSearching) ? (hasResult ? searchViewController.searchResult.toList() : <SearchModel>[]) : searchViewController.productsList.toList();
            return Stack(
              children: [
                Column(
                  children: [
                    _searchWidget(),
                    searchViewController.showInGrid.value ? SizedBox.shrink() : _topText(displayList),
                    Expanded(
                        child: displayList.isEmpty && snapshot.hasData
                            ? CustomWidgets.spinKit()
                            : displayList.isEmpty && isSearching
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
                  bottom: 0.0,
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

  ListviewTopText<SearchModel> _topText(List<SearchModel> displayList) {
    return ListviewTopText<SearchModel>(
      names: widget.selectableProducts ? StringConstants.salesTopText : StringConstants.searchViewtopPartNames,
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
          case 'count':
            return model.count ?? 0;
          case 'price':
            return model.price ?? 0;
          case 'cost':
            return model.cost ?? 0;
          case 'brends':
            return model.brend?.name ?? '';
          case 'category':
            return model.category?.name ?? '';
          case 'location':
            return model.location?.name ?? '';
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
        searchViewController.onSearchTextChanged(value);
      },
      onClear: () {
        searchController.clear();
        searchViewController.searchResult.clear();
      },
    );
  }

  GridView gridViewStyle(List<SearchModel> list) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Get.size.width > 1000 ? 5 : 4, mainAxisSpacing: 20, childAspectRatio: 1.0),
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return SecondProductCard(product: list[index]);
        });
  }

  ListView listViewStyle(List<SearchModel> list) {
    return ListView.builder(
        itemCount: list.length,
        padding: EdgeInsets.only(bottom: 50.h),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: [
              CustomWidgets.counter(list.length - index),
              Expanded(
                child: SearchCard(
                  disableOnTap: widget.selectableProducts,
                  product: list[index],
                  addCounterWidget: widget.selectableProducts,
                  whcihPage: widget.whichPage,
                ),
              )
            ],
          );
        });
  }
}

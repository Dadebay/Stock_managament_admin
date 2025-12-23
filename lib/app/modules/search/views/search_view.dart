import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/components/bottom_price_sheet.dart';
import 'package:stock_managament_admin/app/modules/search/components/right_side_buttons.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

import '../../../product/init/packages.dart';

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.selectableProducts, required this.hideAppBar, required this.addCounterWidget, this.whichPage, required this.isAdmin, this.showCategoryFilter = false});
  final bool selectableProducts;
  final bool addCounterWidget;
  final bool isAdmin;
  final bool hideAppBar;
  final String? whichPage;
  final bool showCategoryFilter;
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final SearchViewController searchViewController = Get.find<SearchViewController>();
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    searchViewController.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.hideAppBar == false
          ? CustomAppBar(
              backArrow: true,
              centerTitle: true,
              actionIcon: false,
              name: 'Select products to add'.tr,
            )
          : null,
      body: Obx(() {
        if (searchViewController.isLoading.value) {
          return CustomWidgets.spinKit();
        } else if (searchViewController.historyList.isEmpty) {
          return CustomWidgets.emptyData();
        }

        final isSearching = searchController.text.isNotEmpty;
        final displayList = searchViewController.searchResult.toList();
        return Stack(
          children: [
            Column(
              children: [
                _searchWidget(),
                if (widget.showCategoryFilter)
                  SizedBox(
                    height: 50,
                    child: Obx(() {
                      Widget _buildCategoryChip(String categoryName) {
                        final isSelected = searchViewController.selectedCategory.value == categoryName;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(categoryName),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                searchViewController.filterByCategory(categoryName);
                              }
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            backgroundColor: Colors.grey[200],
                            shape: const StadiumBorder(),
                          ),
                        );
                      }

                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip('All'),
                          ...searchViewController.categories.map((cat) => _buildCategoryChip(cat.name)).toList(),
                        ],
                      );
                    }),
                  ),
                searchViewController.showInGrid.value ? SizedBox.shrink() : _topText(displayList),
                Expanded(
                    child: displayList.isEmpty && isSearching == false
                        ? CustomWidgets.spinKit()
                        : displayList.isEmpty && isSearching
                            ? Center(child: Text("No results found for '${searchController.text}'"))
                            : displayList.isEmpty
                                ? CustomWidgets.emptyData()
                                : (searchViewController.showInGrid.value ? gridViewStyle(displayList) : listViewStyle(displayList)))
              ],
            ),
            Positioned(
              bottom: 150.0,
              right: 20.0,
              child: RightSideButtons(isAdmin: widget.isAdmin),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: BottomPriceSheet(),
            )
          ],
        );
      }),
    );
  }

  ListviewTopText<SearchModel> _topText(List<SearchModel> displayList) {
    return ListviewTopText<SearchModel>(
      names: widget.selectableProducts ? StringConstants.salesTopText : StringConstants.searchViewtopPartNames,
      listToSort: displayList,
      setSortedList: (newList) {
        print('===== SORT CALLBACK CALLED =====');
        print('New list length: ${newList.length}');
        print('First 3 items after sort:');
        for (int i = 0; i < (newList.length > 3 ? 3 : newList.length); i++) {
          print('  $i: ${newList[i].name} - Price: ${newList[i].price} - Cost: ${newList[i].cost}');
        }

        // Update all three lists to maintain sort order
        searchViewController.historyList.assignAll(newList);
        searchViewController.searchResult.assignAll(newList);
        searchViewController.productsList.assignAll(newList);

        print('After assignment - historyList length: ${searchViewController.historyList.length}');
        print('After assignment - searchResult length: ${searchViewController.searchResult.length}');
        print('After assignment - productsList length: ${searchViewController.productsList.length}');
      },
      getSortValue: (model, key) {
        switch (key) {
          case 'name':
            return model.name;
          case 'count':
            return model.count;
          case 'price':
            return double.tryParse(model.price) ?? 0.0;
          case 'cost':
            return double.tryParse(model.cost) ?? 0.0;
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
          return SecondProductCard(product: list[index], isAdmin: widget.isAdmin);
        });
  }

  ListView listViewStyle(List<SearchModel> list) {
    return ListView.builder(
        key: ValueKey(list.map((e) => e.id).join('-')),
        itemCount: list.length,
        itemExtent: 105.h,
        cacheExtent: 500.0,
        padding: EdgeInsets.only(bottom: 150.h),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return SearchCard(
            key: ObjectKey('${list[index].id}-$index-${list.length - index}'),
            disableOnTap: widget.selectableProducts,
            product: list[index],
            addCounterWidget: widget.addCounterWidget,
            whcihPage: widget.whichPage,
            isAdmin: widget.isAdmin,
            counter: list.length - index,
          );
        });
  }
}

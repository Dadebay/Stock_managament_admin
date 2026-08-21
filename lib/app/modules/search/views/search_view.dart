import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/components/bottom_price_sheet.dart';
import 'package:stock_managament_admin/app/modules/search/components/right_side_buttons.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';
import 'package:stock_managament_admin/app/product/widgets/year_filter_bar.dart';

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
  const SearchView(
      {super.key,
      required this.selectableProducts,
      required this.hideAppBar,
      required this.addCounterWidget,
      this.whichPage,
      required this.isAdmin,
      this.showCategoryFilter = false});
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
  final SearchViewController searchViewController =
      Get.find<SearchViewController>();
  final TextEditingController searchController = TextEditingController();
  String? _selectedYear;
  bool? _pagedSortAscending;

  // Product pickers (order/purchase creation) and the category-filter view need
  // the whole catalog in memory; the plain "Gözleg" browsing tab doesn't, so it
  // gets fast paginated loading instead. See _buildPagedBody / _buildFullCatalogBody.
  late final bool _needsFullCatalog =
      widget.selectableProducts || widget.showCategoryFilter;

  @override
  void initState() {
    super.initState();
    if (_needsFullCatalog) {
      searchViewController.loadProducts();
    } else {
      searchViewController.loadProductsPage(page: 1);
      searchViewController.loadCatalogTotals();
    }
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
        final usingFullCatalog =
            _needsFullCatalog || searchViewController.historyList.isNotEmpty;
        return usingFullCatalog ? _buildFullCatalogBody() : _buildPagedBody();
      }),
    );
  }

  Widget _buildFullCatalogBody() {
    if (searchViewController.isLoading.value) {
      return CustomWidgets.spinKit();
    } else if (searchViewController.historyList.isEmpty) {
      return CustomWidgets.emptyData();
    }

    final isSearching = searchController.text.isNotEmpty;
    final searchResults = searchViewController.searchResult.toList();
    final years = searchViewController.historyList
        .map(_yearOf)
        .where((year) => year.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final displayList = _selectedYear == null
        ? searchResults
        : searchResults
            .where((product) => _yearOf(product) == _selectedYear)
            .toList();
    return Stack(
      children: [
        Column(
          children: [
            _pageBar(years),
            if (widget.showCategoryFilter)
              SizedBox(
                height: 50,
                child: Obx(() {
                  Widget _buildCategoryChip(String categoryName) {
                    final isSelected =
                        searchViewController.selectedCategory.value ==
                            categoryName;
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
                      ...searchViewController.categories
                          .map((cat) => _buildCategoryChip(cat.name))
                          .toList(),
                    ],
                  );
                }),
              ),
            searchViewController.showInGrid.value
                ? SizedBox.shrink()
                : _topText(displayList),
            Expanded(
                child: displayList.isEmpty && isSearching == false
                    ? CustomWidgets.spinKit()
                    : displayList.isEmpty && isSearching
                        ? Center(
                            child: Text(
                                "No results found for '${searchController.text}'"))
                        : displayList.isEmpty
                            ? CustomWidgets.emptyData()
                            : (searchViewController.showInGrid.value
                                ? gridViewStyle(displayList)
                                : listViewStyle(displayList)))
          ],
        ),
        Positioned(
          bottom: 96.0,
          right: 20.0,
          child: RightSideButtons(isAdmin: widget.isAdmin),
        ),
        Positioned(
          bottom: 0,
          right: 20,
          child: SizedBox(
            width: Get.width > 720 ? 640 : Get.width - 40,
            child: BottomPriceSheet(
              productCount: displayList.length,
              stockCount: _stockCount(displayList),
              totalCost: _totalCost(displayList),
              totalSell: _totalSell(displayList),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagedBody() {
    final displayList = searchViewController.pageItems.toList();
    final isLoading = searchViewController.pageLoading.value;
    final totalPages = searchViewController.totalPages.value;
    final hasPager = displayList.isNotEmpty && totalPages > 1;

    return Stack(
      children: [
        Column(
          children: [
            _pagedHeader(),
            searchViewController.showInGrid.value
                ? SizedBox.shrink()
                : _topTextPaged(displayList),
            Expanded(
                child: isLoading && displayList.isEmpty
                    ? CustomWidgets.spinKit()
                    : displayList.isEmpty
                        ? CustomWidgets.emptyData()
                        : (searchViewController.showInGrid.value
                            ? gridViewStyle(displayList)
                            : listViewStyle(
                                displayList,
                                counterStart: _pagedSortAscending == true
                                    ? ((searchViewController.currentPage.value -
                                                1) *
                                            SearchService.pageSize) +
                                        1
                                    : searchViewController.totalCount.value -
                                        ((searchViewController
                                                    .currentPage.value -
                                                1) *
                                            SearchService.pageSize),
                                counterStep:
                                    _pagedSortAscending == true ? 1 : -1,
                              ))),
          ],
        ),
        if (hasPager)
          Positioned(
            bottom: 10.0,
            left: 20.0,
            child: _buildPager(),
          ),
        Positioned(
          bottom: hasPager ? 90.0 : 96.0,
          right: 20.0,
          child: RightSideButtons(isAdmin: widget.isAdmin),
        ),
        Positioned(
          bottom: (!isLoading && displayList.isNotEmpty && totalPages > 1)
              ? 0.0
              : 0.0,
          right: 20,
          child: SizedBox(
            width: Get.width > 720 ? 640 : Get.width - 40,
            child: Obx(() => BottomPriceSheet(
                  productCount: searchViewController.catalogProductCount.value,
                  stockCount: searchViewController.catalogStockCount.value,
                  totalCost: searchViewController.catalogTotalCost.value,
                  totalSell: searchViewController.catalogTotalSell.value,
                )),
          ),
        ),
      ],
    );
  }

  Widget _pagedHeader() => Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Row(children: [
          Expanded(
            flex: 4,
            child: Text('search'.tr,
                style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 240,
                child: SearchWidget(
                  controller: searchController,
                  onChanged: searchViewController.onPagedSearchTextChanged,
                  onClear: () {
                    searchController.clear();
                    searchViewController.onPagedSearchTextChanged('');
                  },
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _buildPager() {
    final currentPage = searchViewController.currentPage.value;
    final totalPages = searchViewController.totalPages.value;
    final start =
        (currentPage - 2).clamp(1, (totalPages - 4).clamp(1, totalPages));
    final end = (start + 4).clamp(1, totalPages);
    final pages = [for (var p = start; p <= end; p++) p];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pagerIcon(
              Icons.chevron_left,
              currentPage > 1,
              () =>
                  searchViewController.loadProductsPage(page: currentPage - 1)),
          if (start > 1) ...[
            _pageChip(1, currentPage),
            if (start > 2) _ellipsis(),
          ],
          for (final p in pages) _pageChip(p, currentPage),
          if (end < totalPages) ...[
            if (end < totalPages - 1) _ellipsis(),
            _pageChip(totalPages, currentPage),
          ],
          _pagerIcon(
              Icons.chevron_right,
              currentPage < totalPages,
              () =>
                  searchViewController.loadProductsPage(page: currentPage + 1)),
        ],
      ),
    );
  }

  Widget _pageChip(int page, int currentPage) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: isActive
            ? null
            : () => searchViewController.loadProductsPage(page: page),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ellipsis() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('...', style: TextStyle(color: Color(0xFF94A3B8))),
      );

  Widget _pagerIcon(IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      color: enabled ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
    );
  }

  ListviewTopText<SearchModel> _topTextPaged(List<SearchModel> displayList) {
    return ListviewTopText<SearchModel>(
      names: widget.selectableProducts
          ? StringConstants.salesTopText
          : StringConstants.searchViewtopPartNames,
      listToSort: displayList,
      setSortedList: (newList) {
        // Paginated mode: sort only applies to the current page's items.
        searchViewController.pageItems.assignAll(newList);
      },
      onSortChanged: (ascending) =>
          setState(() => _pagedSortAscending = ascending),
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

  ListviewTopText<SearchModel> _topText(List<SearchModel> displayList) {
    return ListviewTopText<SearchModel>(
      names: widget.selectableProducts
          ? StringConstants.salesTopText
          : StringConstants.searchViewtopPartNames,
      listToSort: displayList,
      setSortedList: (newList) {
        print('===== SORT CALLBACK CALLED =====');
        print('New list length: ${newList.length}');
        print('First 3 items after sort:');
        for (int i = 0; i < (newList.length > 3 ? 3 : newList.length); i++) {
          print(
              '  $i: ${newList[i].name} - Price: ${newList[i].price} - Cost: ${newList[i].cost}');
        }

        // Update all three lists to maintain sort order
        searchViewController.historyList.assignAll(newList);
        searchViewController.searchResult.assignAll(newList);
        searchViewController.productsList.assignAll(newList);

        print(
            'After assignment - historyList length: ${searchViewController.historyList.length}');
        print(
            'After assignment - searchResult length: ${searchViewController.searchResult.length}');
        print(
            'After assignment - productsList length: ${searchViewController.productsList.length}');
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

  Widget _pageBar(List<String> years) => Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Row(children: [
          Expanded(
            flex: 4,
            child: YearFilterBar(
              years: years,
              selectedYear: _selectedYear,
              onSelected: (year) => setState(() => _selectedYear = year),
              totalForAll: _totalCost(searchViewController.historyList),
              totalForYear: (year) => _totalCost(searchViewController
                  .historyList
                  .where((product) => _yearOf(product) == year)
                  .toList()),
              height: 54,
              showBorder: false,
              padding: EdgeInsets.zero,
              verticalPadding: 4,
              dense: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('search'.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 240,
                child: SearchWidget(
                  controller: searchController,
                  onChanged: searchViewController.onSearchTextChanged,
                  onClear: () {
                    searchController.clear();
                    searchViewController.onSearchTextChanged('');
                  },
                ),
              ),
            ),
          ),
        ]),
      );

  String _yearOf(SearchModel product) {
    final date = DateTime.tryParse(product.createdAT);
    return date == null ? '' : date.year.toString();
  }

  int _stockCount(Iterable<SearchModel> products) =>
      products.fold(0, (sum, product) => sum + product.count);

  double _totalCost(Iterable<SearchModel> products) => products.fold(
      0,
      (sum, product) =>
          sum + (double.tryParse(product.cost) ?? 0) * product.count);

  double _totalSell(Iterable<SearchModel> products) => products.fold(
      0,
      (sum, product) =>
          sum + (double.tryParse(product.price) ?? 0) * product.count);

  GridView gridViewStyle(List<SearchModel> list) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Get.size.width > 1000 ? 7 : 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0),
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return SecondProductCard(
              product: list[index], isAdmin: widget.isAdmin);
        });
  }

  ListView listViewStyle(List<SearchModel> list,
      {int? counterStart, int counterStep = -1}) {
    return ListView.separated(
        key: ValueKey(list.map((e) => e.id).join('-')),
        itemCount: list.length,
        cacheExtent: 500.0,
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 96.h),
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (BuildContext context, int index) {
          return SearchCard(
            key: ObjectKey(
                '${list[index].id}-$index-${(counterStart ?? list.length) + (index * counterStep)}'),
            disableOnTap: widget.selectableProducts,
            product: list[index],
            addCounterWidget: widget.addCounterWidget,
            whcihPage: widget.whichPage,
            isAdmin: widget.isAdmin,
            counter: (counterStart ?? list.length) + (index * counterStep),
          );
        });
  }
}

import 'dart:async';

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
import 'package:stock_managament_admin/app/product/widgets/year_filter_bar.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  TextEditingController searchController = TextEditingController();
  final OrderController orderController = Get.find<OrderController>();
  Timer? _debounce;
  String? _selectedYear;
  bool _hasSorted = false;
  bool _sortAscending = true;

  String _yearOf(OrderModel order) =>
      DateTime.tryParse(order.date.toString())?.year.toString() ?? '';
  double _total(List<OrderModel> orders) => orders.fold(
      0,
      (sum, order) =>
          sum + (double.tryParse(order.totalsum.replaceAll(',', '.')) ?? 0));

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350),
        () => orderController.onSearchTextChanged(value));
  }

  dynamic _rightSideButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.isAdmin
            ? _actionButton(
                heroTag: "add_product",
                backgroundColor: ColorConstants.blackColor,
                onPressed: () {
                  Get.to(() => OrderCreateView(isAdmin: widget.isAdmin))?.then(
                      (_) => orderController.fetchOrders(
                          page: orderController.currentPage.value));
                },
                icon: IconlyLight.plus,
              )
            : SizedBox(),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _actionButton(
            backgroundColor: ColorConstants.blackColor,
            heroTag: "filter",
            onPressed: () => DialogsUtils.orderFilterDialog(),
            icon: IconlyLight.filter2,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
          {required String heroTag,
          required VoidCallback onPressed,
          required IconData icon,
          Color? backgroundColor}) =>
      SizedBox(
          width: 42,
          height: 42,
          child: FloatingActionButton(
              heroTag: heroTag,
              mini: true,
              backgroundColor: const Color(0xFF0F172A),
              onPressed: onPressed,
              child: Icon(icon, color: const Color(0xFFFACC15), size: 20)));

  SearchWidget _searchWidget() {
    return SearchWidget(
      controller: searchController,
      onChanged: _onSearchChanged,
      onClear: () {
        searchController.clear();
        _debounce?.cancel();
        orderController.onSearchTextChanged('');
      },
    );
  }

  ListviewTopText<OrderModel> _topText(List<OrderModel> displayList) {
    return ListviewTopText<OrderModel>(
      names: StringConstants.orderNamesList,
      listToSort: displayList,
      setSortedList: (newList) {
        // Sıralama sadece o an yüklü olan sayfadaki siparişlere uygulanır.
        orderController.orders.assignAll(newList);
      },
      onSortChanged: (ascending) => setState(() {
        _hasSorted = true;
        _sortAscending = ascending;
      }),
      getSortValue: (model, key) {
        switch (key) {
          case 'name':
            return model.name.toLowerCase();
          case 'date':
            return model.date;
          case 'count':
            return model.count ?? 0;
          case 'totalsum':
            return double.tryParse(model.totalsum.replaceAll(',', '.')) ?? 0.0;
          case 'totalchykdajy':
            return double.tryParse(model.totalchykdajy.replaceAll(',', '.')) ??
                0.0;
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
        key: ValueKey(list.map((e) => e.id).join('-')),
        itemCount: list.length,
        padding: const EdgeInsets.only(bottom: 84),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final pageOffset =
              (orderController.currentPage.value - 1) * OrderService.pageSize;
          final displayIndex = _hasSorted && _sortAscending
              ? pageOffset + index + 1
              : orderController.totalCount.value - pageOffset - index;
          return OrderCardView(
              key: ValueKey('order-${list[index].id}-${list.length - index}'),
              order: list[index],
              isAdmin: widget.isAdmin,
              index: displayIndex,
              onChanged: () => orderController.fetchOrders(
                  page: orderController.currentPage.value));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final isLoading = orderController.pageLoading.value;
        final pageOrders = orderController.orders.toList();
        final totalPages = orderController.totalPages.value;

        if (isLoading && pageOrders.isEmpty) {
          return CustomWidgets.spinKit();
        }

        if (pageOrders.isEmpty && searchController.text.isEmpty) {
          return CustomWidgets.emptyData();
        }

        final years = pageOrders
            .map(_yearOf)
            .where((year) => year.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
        final displayList = _selectedYear == null
            ? pageOrders
            : pageOrders
                .where((order) => _yearOf(order) == _selectedYear)
                .toList();
        final hasPager = displayList.isNotEmpty && totalPages > 1;

        return Stack(
          children: [
            Column(
              children: [
                _pageBar(years, pageOrders),
                _topText(displayList),
                Expanded(
                  child: displayList.isEmpty && searchController.text.isNotEmpty
                      ? Center(
                          child: Text(
                              "No results found for '${searchController.text}'"))
                      : listViewStyle(displayList),
                ),
              ],
            ),
            Positioned(
              bottom: 125.0,
              right: 20.0,
              child: _rightSideButtons(),
            ),
            if (hasPager)
              Positioned(
                bottom: 10.0,
                left: 20.0,
                child: _buildPager(),
              ),
            Positioned(
              bottom: 10.0,
              right: 20.0,
              child: SizedBox(width: 420, child: BottomPriceSheetSalesView()),
            )
          ],
        );
      }),
    );
  }

  Widget _buildPager() {
    final currentPage = orderController.currentPage.value;
    final totalPages = orderController.totalPages.value;
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
          _pagerIcon(Icons.chevron_left, currentPage > 1,
              () => orderController.fetchOrders(page: currentPage - 1)),
          if (start > 1) ...[
            _pageChip(1, currentPage),
            if (start > 2) _ellipsis(),
          ],
          for (final p in pages) _pageChip(p, currentPage),
          if (end < totalPages) ...[
            if (end < totalPages - 1) _ellipsis(),
            _pageChip(totalPages, currentPage),
          ],
          _pagerIcon(Icons.chevron_right, currentPage < totalPages,
              () => orderController.fetchOrders(page: currentPage + 1)),
        ],
      ),
    );
  }

  Widget _pageChip(int page, int currentPage) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: isActive ? null : () => orderController.fetchOrders(page: page),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0F172A) : Colors.transparent,
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

  Widget _pageBar(List<String> years, List<OrderModel> pageOrders) => Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(children: [
        Text('sales'.tr,
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A))),
        SizedBox(width: 20.w),
        Expanded(
            flex: 4,
            child: YearFilterBar(
                years: years,
                selectedYear: _selectedYear,
                onSelected: (year) => setState(() => _selectedYear = year),
                totalForAll: _total(pageOrders),
                totalForYear: (year) => _total(pageOrders
                    .where((order) => _yearOf(order) == year)
                    .toList()),
                height: 54,
                showBorder: false,
                padding: EdgeInsets.zero,
                verticalPadding: 4,
                dense: true)),
        Expanded(
            flex: 4,
            child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(width: 240, child: _searchWidget()))),
      ]));
}

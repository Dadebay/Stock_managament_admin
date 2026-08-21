import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/create_purchase_view.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchase_card.dart';
import 'package:stock_managament_admin/app/modules/search/components/bottom_price_sheet.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';
import 'package:stock_managament_admin/app/product/widgets/year_filter_bar.dart';

class PurchasesView extends StatefulWidget {
  const PurchasesView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<PurchasesView> createState() => _PurchasesViewState();
}

class _PurchasesViewState extends State<PurchasesView> {
  final PurchasesController purchasesController =
      Get.find<PurchasesController>();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  String _sortKey = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    purchasesController.pageLoading.value = true;
    try {
      final result = await PurchasesService()
          .getPurchases(page: page, search: searchController.text.trim());
      purchasesController.purchases.assignAll(result.purchases);
      purchasesController.currentPage.value = result.page;
      purchasesController.totalPages.value =
          result.totalPages < 1 ? 1 : result.totalPages;
      purchasesController.totalCount.value = result.count;
      purchasesController.summ.value = result.summ;
      purchasesController.totalProductCount.value = result.totalProductCount;
    } finally {
      purchasesController.pageLoading.value = false;
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _loadPage(1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final isLoading = purchasesController.pageLoading.value;
        final purchasesForPage = purchasesController.purchases.toList();

        if (isLoading && purchasesForPage.isEmpty) {
          return CustomWidgets.spinKit();
        }
        if (!isLoading &&
            purchasesForPage.isEmpty &&
            searchController.text.isEmpty) {
          return CustomWidgets.emptyData();
        }

        final years = purchasesController.availableYears(purchasesForPage);
        final selectedYear = purchasesController.selectedYear.value;
        final yearFiltered =
            purchasesController.applyYearFilter(purchasesForPage);
        final displayList = _sortPurchases(yearFiltered);
        final totalPages = purchasesController.totalPages.value;
        final isSearching = searchController.text.isNotEmpty;

        return Stack(
          children: [
            Column(
              children: [
                _pageBar(years, purchasesForPage, selectedYear),
                _tableHeader(),
                Expanded(
                    child: displayList.isEmpty && isSearching
                        ? Center(
                            child: Text(
                                "No results found for '${searchController.text}'"))
                        : displayList.isEmpty
                            ? CustomWidgets.emptyData()
                            : ListView.separated(
                                key: ValueKey(
                                    displayList.map((e) => e.id).join('-')),
                                itemCount: displayList.length,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 84),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (context, index) {
                                  final pageOffset =
                                      (purchasesController.currentPage.value -
                                              1) *
                                          PurchasesService.pageSize;
                                  final displayIndex = _sortAscending
                                      ? pageOffset + index + 1
                                      : purchasesController.totalCount.value -
                                          pageOffset -
                                          index;
                                  return PurchaseCard(
                                    key: ObjectKey(
                                        '${displayList[index].id}-$index'),
                                    purchasesModel: displayList[index],
                                    showInProductProfil: false,
                                    index: displayIndex,
                                    isAdmin: widget.isAdmin,
                                    onChanged: () => _loadPage(
                                        purchasesController.currentPage.value),
                                  );
                                },
                              )),
              ],
            ),
            widget.isAdmin
                ? Positioned(
                    bottom: 92.0,
                    right: 20.0,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF4F46E5),
                      heroTag: "add_purchase",
                      onPressed: () {
                        Get.to(() =>
                            CreatePurchasesView(
                                isAdmin: widget.isAdmin))?.then((_) =>
                            _loadPage(purchasesController.currentPage.value));
                      },
                      child: const Icon(
                        IconlyLight.plus,
                        color: Colors.white,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            if (!isLoading && displayList.isNotEmpty && totalPages > 1)
              Positioned(
                bottom: 10.0,
                left: 20.0,
                child: _buildPager(),
              ),
            Positioned(
              bottom: 10.0,
              right: 20.0,
              child: SizedBox(
                width: 500,
                child: BottomPriceSheetPurchases(
                  totalCost: selectedYear == null
                      ? purchasesController.summ.value
                      : PurchasesController.totalCostOf(displayList),
                  purchaseCount: selectedYear == null
                      ? purchasesController.totalCount.value
                      : displayList.length,
                  productCount: selectedYear == null
                      ? purchasesController.totalProductCount.value
                      : PurchasesController.totalCountOf(displayList),
                  scopeLabel: selectedYear ?? 'allYears'.tr,
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  List<PurchasesModel> _sortPurchases(List<PurchasesModel> purchases) {
    final sorted = List<PurchasesModel>.from(purchases);
    int compare(PurchasesModel a, PurchasesModel b) {
      switch (_sortKey) {
        case 'title':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'source':
          return a.source.toLowerCase().compareTo(b.source.toLowerCase());
        case 'count':
          return a.count.compareTo(b.count);
        case 'cost':
          return (double.tryParse(a.cost) ?? 0)
              .compareTo(double.tryParse(b.cost) ?? 0);
        default:
          return a.date.compareTo(b.date);
      }
    }

    sorted.sort((a, b) => _sortAscending ? compare(a, b) : compare(b, a));
    return sorted;
  }

  Widget _pageBar(
      List<String> years, List<PurchasesModel> pageList, String? selectedYear) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: YearFilterBar(
              years: years,
              selectedYear: selectedYear,
              onSelected: (year) =>
                  purchasesController.selectedYear.value = year,
              totalForAll: purchasesController.summ.value,
              totalForYear: (year) => PurchasesController.totalCostOf(pageList
                  .where((model) => PurchasesController.yearOf(model) == year)
                  .toList()),
              height: 46,
              showBorder: false,
              padding: EdgeInsets.zero,
              verticalPadding: 4,
              dense: true,
            ),
          ),
        ),
        Text('purchases'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 17.sp,
                fontWeight: FontWeight.w700)),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(width: 220.w, child: _searchWidget()),
          ),
        ),
      ]),
    );
  }

  Widget _buildPager() {
    final currentPage = purchasesController.currentPage.value;
    final totalPages = purchasesController.totalPages.value;
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
              () => _loadPage(currentPage - 1)),
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
              () => _loadPage(currentPage + 1)),
        ],
      ),
    );
  }

  Widget _pageChip(int page, int currentPage) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: isActive ? null : () => _loadPage(page),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
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

  Widget _tableHeader() {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(children: [
        const SizedBox(width: 46),
        const SizedBox(width: 14),
        _headerCell('purchases'.tr, 'title', flex: 3),
        _headerCell('date'.tr, 'date', flex: 2),
        _headerCell('description'.tr, 'source', flex: 2),
        _headerCell('count'.tr, 'count',
            flex: 1, alignment: Alignment.centerRight),
        _headerCell('cost'.tr, 'cost',
            flex: 2, alignment: Alignment.centerRight),
        if (widget.isAdmin) const SizedBox(width: 92),
      ]),
    );
  }

  Widget _headerCell(String label, String key,
      {required int flex, Alignment alignment = Alignment.centerLeft}) {
    final isActive = _sortKey == key;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => setState(() {
          if (isActive)
            _sortAscending = !_sortAscending;
          else {
            _sortKey = key;
            _sortAscending = key == 'date' ? false : true;
          }
        }),
        child: Align(
          alignment: alignment,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: TextStyle(
                    color: isActive
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFF64748B),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Icon(
                isActive
                    ? (_sortAscending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 15,
                color: isActive
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF94A3B8)),
          ]),
        ),
      ),
    );
  }

  SearchWidget _searchWidget() {
    return SearchWidget(
      controller: searchController,
      onChanged: _onSearchChanged,
      onClear: () {
        searchController.clear();
        _debounce?.cancel();
        _loadPage(1);
      },
    );
  }
}

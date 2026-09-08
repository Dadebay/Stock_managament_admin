import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_service.dart';
import 'package:stock_managament_admin/app/modules/expences/views/edit_add_expences.dart';
import 'package:stock_managament_admin/app/modules/expences/views/expences_card.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

class ExpencesView extends StatefulWidget {
  const ExpencesView({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<ExpencesView> createState() => _ExpencesViewState();
}

class _ExpencesViewState extends State<ExpencesView> {
  final ExpencesController controller = Get.find<ExpencesController>();
  final searchController = TextEditingController();
  late final Future<List<ExpencesModel>> _future;
  final RxString _searchQuery = ''.obs;
  String? _selectedYear;
  String _sortKey = 'date';
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _future = ExpencesService().getExpences();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FutureBuilder<List<ExpencesModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return CustomWidgets.spinKit();
          if (snapshot.hasError) return CustomWidgets.errorData();
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return CustomWidgets.emptyData();
          if (controller.expencesList.isEmpty) {
            final initial = List<ExpencesModel>.from(snapshot.data!)
              ..sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.expencesList.assignAll(initial);
              controller.totalPrice.value = _total(initial);
            });
          }
          return Obx(() {
            final query = _searchQuery.value.trim().toLowerCase();
            final terms =
                query.isEmpty ? const <String>[] : query.split(RegExp(r'\s+'));
            final source = controller.expencesList.where((expense) {
              if (terms.isEmpty) return true;
              final searchable =
                  '${expense.name} ${expense.note} ${expense.cost}'
                      .toLowerCase();
              return terms.every(searchable.contains);
            }).toList();
            final years = source
                .map((item) => _yearOf(item))
                .where((year) => year.isNotEmpty)
                .toSet()
                .toList()
              ..sort((a, b) => b.compareTo(a));
            final filtered = _selectedYear == null
                ? source
                : source
                    .where((item) => _yearOf(item) == _selectedYear)
                    .toList();
            final display = _sort(filtered);
            return Stack(children: [
              Column(children: [
                _pageBar(years, source),
                _header(),
                Expanded(
                  child: display.isEmpty
                      ? CustomWidgets.emptyData()
                      : ListView.separated(
                          itemCount: display.length,
                          // Bottom padding clears the floating summary/actions
                          // so the last row is never trapped behind them.
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 84),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, index) => ExpencesCard(
                              expencesModel: display[index],
                              count: display.length - index,
                              isAdmin: widget.isAdmin),
                        ),
                ),
              ]),
              // The total floats over the list instead of sitting on an opaque
              // strip, so the rows behind it stay visible while scrolling.
              Positioned(
                  left: 0, right: 0, bottom: 12, child: _summary(display)),
            ]);
          });
        },
      ),
      if (widget.isAdmin)
        Positioned(
            right: 20,
            bottom: 12,
            child: Row(children: [
              _floatingAction(
                  HugeIcons.strokeRoundedFile02,
                  const Color(0xFF475569),
                  const Color(0xFFF1F5F9),
                  controller.exportToExcel),
              const SizedBox(width: 8),
              _floatingAction(
                  HugeIcons.strokeRoundedAdd01,
                  Colors.white,
                  const Color(0xFF4F46E5),
                  () => showDialog(
                      context: context,
                      builder: (_) => const EditAddExpencesDialog())),
            ])),
    ]);
  }

  String _yearOf(ExpencesModel item) =>
      (item.date?.length ?? 0) >= 4 ? item.date!.substring(0, 4) : '';
  double _total(List<ExpencesModel> list) =>
      list.fold(0, (sum, item) => sum + (double.tryParse(item.cost) ?? 0));

  List<ExpencesModel> _sort(List<ExpencesModel> list) {
    final sorted = List<ExpencesModel>.from(list);
    int compare(ExpencesModel a, ExpencesModel b) {
      switch (_sortKey) {
        case 'name':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'cost':
          return (double.tryParse(a.cost) ?? 0)
              .compareTo(double.tryParse(b.cost) ?? 0);
        case 'note':
          return a.note.toLowerCase().compareTo(b.note.toLowerCase());
        default:
          return (a.date ?? '').compareTo(b.date ?? '');
      }
    }

    sorted.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return sorted;
  }

  Widget _pageBar(List<String> years, List<ExpencesModel> source) {
    return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Row(children: [
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: years.length < 2
                      ? const SizedBox.shrink()
                      : _yearChips(years, source))),
          Text('expences'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700)),
          Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                      width: 220.w,
                      child: SearchWidget(
                          controller: searchController,
                          onChanged: (value) => _searchQuery.value = value,
                          onClear: () {
                            searchController.clear();
                            _searchQuery.value = '';
                          })))),
        ]));
  }

  Widget _yearChips(List<String> years, List<ExpencesModel> source) {
    return SizedBox(
        height: 42.h,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: years.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final year = index == 0 ? null : years[index - 1];
              final selected = _selectedYear == year;
              final subset = year == null
                  ? source
                  : source.where((item) => _yearOf(item) == year).toList();
              return Material(
                  color: selected
                      ? const Color(0xFFF97316)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                      onTap: () => setState(() => _selectedYear = year),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(year ?? 'allYears'.tr,
                                    style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF9A3412),
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700)),
                                Text('${_total(subset).toStringAsFixed(0)} \$',
                                    style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                                .withValues(alpha: .85)
                                            : const Color(0xFFB45309),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600))
                              ]))));
            }));
  }

  Widget _header() => Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(children: [
        const SizedBox(width: 46),
        const SizedBox(width: 14),
        _head('expences_name'.tr, 'name', 3),
        _head('date'.tr, 'date', 2),
        _head('cost'.tr, 'cost', 2, right: true),
        _head('note'.tr, 'note', 4),
        if (widget.isAdmin) const SizedBox(width: 92)
      ]));

  Widget _head(String label, String key, int flex, {bool right = false}) {
    final active = _sortKey == key;
    return Expanded(
        flex: flex,
        child: InkWell(
            onTap: () => setState(() {
                  if (active)
                    _ascending = !_ascending;
                  else {
                    _sortKey = key;
                    _ascending = key == 'date' ? false : true;
                  }
                }),
            child: Align(
                alignment: right ? Alignment.centerRight : Alignment.centerLeft,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(label,
                      style: TextStyle(
                          color: active
                              ? const Color(0xFFF97316)
                              : const Color(0xFF64748B),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Icon(
                      active
                          ? (_ascending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded)
                          : Icons.unfold_more_rounded,
                      color: active
                          ? const Color(0xFFF97316)
                          : const Color(0xFF94A3B8),
                      size: 15)
                ]))));
  }

  Widget _summary(List<ExpencesModel> display) => Align(
      alignment: Alignment.centerRight,
      child: Container(
          margin: EdgeInsets.only(
              left: 20, right: widget.isAdmin ? 116 : 20, bottom: 0),
          constraints: const BoxConstraints(maxWidth: 270),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0xFF9A3412),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF9A3412).withValues(alpha: .28),
                    blurRadius: 18,
                    offset: const Offset(0, 6))
              ]),
          child: Row(children: [
            const Icon(IconlyLight.wallet, color: Colors.white, size: 19),
            const SizedBox(width: 10),
            Flexible(
                child: Text(_selectedYear ?? 'allYears'.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: .8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600))),
            const SizedBox(width: 10),
            Text('${_total(display).toStringAsFixed(2)} \$',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800)),
          ])));

  Widget _floatingAction(List<List<dynamic>> icon, Color color,
          Color background, VoidCallback onTap) =>
      SizedBox(
          width: 40,
          height: 40,
          child: Material(
              color: background,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: FittedBox(
                              child: HugeIcon(
                                  icon: icon, color: color, size: 20)))))));
}

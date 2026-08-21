import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/components/enter_add_button.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_controller.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/views/enter_card.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

class EnteringAppView extends StatefulWidget {
  const EnteringAppView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<EnteringAppView> createState() => _EnteringAppViewState();
}

class _EnteringAppViewState extends State<EnteringAppView> {
  final controller = Get.find<EnterController>();
  final searchController = TextEditingController();
  late final Future<List<EnterModel>> _future;
  String _sortKey = 'name';
  bool _ascending = true;
  @override
  void initState() {
    super.initState();
    _future = EnterService().getClients();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        FutureBuilder<List<EnterModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return CustomWidgets.spinKit();
              if (snapshot.hasError) return CustomWidgets.errorData();
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return CustomWidgets.emptyData();
              if (controller.clients.isEmpty)
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => controller.clients.assignAll(snapshot.data!));
              return Obx(() {
                final searching = searchController.text.isNotEmpty;
                final source = searching
                    ? controller.searchResult.toList()
                    : controller.clients.toList();
                final list = List<EnterModel>.from(source)..sort(_compare);
                return Column(children: [
                  SearchWidget(
                      controller: searchController,
                      onChanged: controller.onSearchTextChanged,
                      onClear: () {
                        searchController.clear();
                        controller.searchResult.clear();
                      }),
                  _header(),
                  Expanded(
                      child: list.isEmpty
                          ? CustomWidgets.emptyData()
                          : ListView.separated(
                              itemCount: list.length,
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (_, index) => EnterCard(
                                  client: list[index],
                                  count: list.length - index,
                                  isAdmin: widget.isAdmin))),
                ]);
              });
            }),
        if (widget.isAdmin)
          Positioned(
              right: 20,
              bottom: 20,
              child: Row(children: [
                FloatingActionButton(
                    heroTag: 'user_export',
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    onPressed: controller.exportToExcel,
                    child: const Icon(IconlyLight.document, size: 22)),
                const SizedBox(width: 12),
                FloatingActionButton(
                    heroTag: 'user_add',
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const EnterAddButton()),
                    child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserAdd01,
                        color: Colors.white,
                        size: 15)),
              ])),
      ]);

  int _compare(EnterModel a, EnterModel b) {
    final l = _sortKey == 'name'
        ? (a.username ?? '')
        : _sortKey == 'password'
            ? (a.password ?? '')
            : (a.isSuperUser ?? false ? '1' : '0');
    final r = _sortKey == 'name'
        ? (b.username ?? '')
        : _sortKey == 'password'
            ? (b.password ?? '')
            : (b.isSuperUser ?? false ? '1' : '0');
    return _ascending
        ? l.toLowerCase().compareTo(r.toLowerCase())
        : r.toLowerCase().compareTo(l.toLowerCase());
  }

  Widget _header() => Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(children: [
        const SizedBox(width: 50),
        _head('client_name'.tr, 'name', 3),
        _head('Password', 'password', 3),
        _head('Admin', 'role', 2),
        if (widget.isAdmin) const SizedBox(width: 92)
      ]));
  Widget _head(String text, String key, int flex) {
    final active = _sortKey == key;
    return Expanded(
        flex: flex,
        child: InkWell(
            onTap: () => setState(() {
                  if (active)
                    _ascending = !_ascending;
                  else {
                    _sortKey = key;
                    _ascending = true;
                  }
                }),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(text,
                  style: TextStyle(
                      color: active
                          ? const Color(0xFF4F46E5)
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
                  size: 15,
                  color: active
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF94A3B8))
            ])));
  }
}

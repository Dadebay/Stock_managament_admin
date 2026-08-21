import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/components/client_add_button.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  final ClientsController controller = Get.find<ClientsController>();
  final searchController = TextEditingController();
  Timer? _debounce;

  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  bool isLoading = true;
  bool isExporting = false;
  String? error;
  String _search = '';
  List<ClientModel> clients = [];

  String _sortKey = 'name';
  bool _ascending = true;

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
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result =
          await ClientsService().getClients(page: page, search: _search);
      setState(() {
        clients = result.clients;
        currentPage = result.page;
        totalPages = result.totalPages < 1 ? 1 : result.totalPages;
        totalCount = result.count;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'error'.tr;
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search = value.trim();
      _loadPage(1);
    });
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        Column(children: [
          _pageBar(),
          _header(),
          Expanded(child: _buildBody()),
        ]),
        if (error == null && clients.isNotEmpty && totalPages > 1)
          Positioned(bottom: 10, left: 20, child: _buildPager()),
        if (widget.isAdmin)
          Positioned(
              right: 20,
              bottom: 20,
              child: Row(children: [
                FloatingActionButton(
                    heroTag: 'clients_export',
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    onPressed: isExporting
                        ? null
                        : () async {
                            setState(() => isExporting = true);
                            await SignInService()
                                .getClients('didario', 'Didar123#');
                            if (await AuthStorage().getAdminStatus()) {
                              final all = await ClientsService()
                                  .getAllClientsForExport();
                              await controller.exportToExcel(all);
                            } else {
                              CustomWidgets.showSnackBar(
                                  'Error', 'You are not admin', Colors.red);
                            }
                            if (mounted) setState(() => isExporting = false);
                          },
                    child: isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(IconlyLight.document, size: 22)),
                const SizedBox(width: 12),
                FloatingActionButton(
                    heroTag: 'clients_add',
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    onPressed: () => showDialog(
                            context: context, builder: (_) => ClientAddButton())
                        .then((_) => _loadPage(currentPage)),
                    child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserAdd01,
                        color: Colors.white,
                        size: 15)),
              ])),
      ]);

  Widget _buildBody() {
    if (isLoading && clients.isEmpty) return CustomWidgets.spinKit();
    if (error != null) return CustomWidgets.errorData();
    if (clients.isEmpty) return CustomWidgets.emptyData();

    final display = _sort(clients);
    return ListView.separated(
        itemCount: display.length,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, index) => ClientCard(
            client: display[index],
            count: totalCount -
                ((currentPage - 1) * ClientsService.pageSize + index),
            isAdmin: widget.isAdmin,
            onChanged: () => _loadPage(currentPage)));
  }

  Widget _buildPager() {
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
            _pageChip(1),
            if (start > 2) _ellipsis(),
          ],
          for (final p in pages) _pageChip(p),
          if (end < totalPages) ...[
            if (end < totalPages - 1) _ellipsis(),
            _pageChip(totalPages),
          ],
          _pagerIcon(Icons.chevron_right, currentPage < totalPages,
              () => _loadPage(currentPage + 1)),
        ],
      ),
    );
  }

  Widget _pageChip(int page) {
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

  List<ClientModel> _sort(List<ClientModel> list) {
    final sorted = List<ClientModel>.from(list);
    int compare(ClientModel a, ClientModel b) {
      switch (_sortKey) {
        case 'address':
          return a.address.toLowerCase().compareTo(b.address.toLowerCase());
        case 'phone':
          return a.phone.compareTo(b.phone);
        case 'order':
          return (a.orderCount ?? 0).compareTo(b.orderCount ?? 0);
        case 'total':
          return (double.tryParse(a.sumPrice ?? '') ?? 0)
              .compareTo(double.tryParse(b.sumPrice ?? '') ?? 0);
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    }

    sorted.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return sorted;
  }

  Widget _pageBar() => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(children: [
          const Expanded(child: SizedBox()),
          Text('clients'.tr,
              style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 240,
                child: SearchWidget(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    searchController.clear();
                    _debounce?.cancel();
                    _search = '';
                    _loadPage(1);
                  },
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _header() => Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(children: [
        const SizedBox(width: 46),
        const SizedBox(width: 14),
        _head('client_name'.tr, 'name', 3),
        _head('address'.tr, 'address', 3),
        _head('phone'.tr, 'phone', 2),
        _head('orderCount'.tr, 'order', 1, right: true),
        _head('sumPrice'.tr, 'total', 2, right: true),
        if (widget.isAdmin) const SizedBox(width: 92)
      ]));

  Widget _head(String text, String key, int flex, {bool right = false}) {
    final active = _sortKey == key;
    return Expanded(
        flex: flex,
        child: InkWell(
            onTap: () => setState(() {
                  if (active)
                    _ascending = !_ascending;
                  else {
                    _sortKey = key;
                    _ascending = key == 'name';
                  }
                }),
            child: Align(
                alignment: right ? Alignment.centerRight : Alignment.centerLeft,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(text,
                      style: TextStyle(
                          color: active
                              ? const Color(0xFF2563EB)
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
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8))
                ]))));
  }
}

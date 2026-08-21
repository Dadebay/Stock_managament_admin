import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/product/constants/color_constants.dart';

class LogsView extends StatefulWidget {
  const LogsView({super.key});

  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  bool isLoading = true;
  String? error;
  List<LogModel> logs = [];

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await LogService().fetchLogs(page: page);
      setState(() {
        logs = result.logs;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildBody()),
        if (!isLoading && error == null && logs.isNotEmpty && totalPages > 1)
          _buildPager(),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (logs.isEmpty) {
      return Center(child: Text("noData".tr));
    }

    return Column(children: [
      Container(
        height: 58,
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Row(children: [
          const SizedBox(width: 42),
          const SizedBox(width: 14),
          _columnTitle('Hadysa', flex: 3),
          _columnTitle('Ulanyjy', flex: 2),
          _columnTitle('Maglumat', flex: 3),
          _columnTitle('Sene', flex: 2),
        ]),
      ),
      Expanded(
          child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final color = getColorForMethod(log.method);
          return Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${totalCount - ((currentPage - 1) * LogService.pageSize + index)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 3,
                    child: Row(children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Icon(getIconForMethod(log.method),
                              color: color, size: 15)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(log.operation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A)))),
                    ]),
                  ),
                  Expanded(
                      flex: 2,
                      child: Text(
                          '${log.username} (${log.isSuperuser ? 'Admin' : 'User'})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500))),
                  Expanded(
                      flex: 3,
                      child: Text(log.name.isEmpty ? '—' : log.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF475569)))),
                  Expanded(
                      flex: 2,
                      child: Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(log.datetime),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 12);
        },
      ))
    ]);
  }

  Widget _columnTitle(String title, {required int flex}) => Expanded(
      flex: flex,
      child: Text(title,
          style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700)));

  Widget _buildPager() {
    final start =
        (currentPage - 2).clamp(1, (totalPages - 4).clamp(1, totalPages));
    final end = (start + 4).clamp(1, totalPages);
    final pages = [for (var p = start; p <= end; p++) p];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
            color:
                isActive ? ColorConstants.kPrimaryColor2 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ellipsis() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('...', style: TextStyle(color: Colors.grey)),
      );

  Widget _pagerIcon(IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      color: enabled ? Colors.black87 : Colors.grey.shade300,
    );
  }

  IconData getIconForMethod(String method) {
    switch (method) {
      case 'create':
        return Icons.add_circle_outline;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color getColorForMethod(String method) {
    switch (method) {
      case 'create':
        return Colors.green;
      case 'edit':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getLabelForMethod(String method) {
    switch (method) {
      case 'create':
        return 'created';
      case 'edit':
        return 'edited';
      case 'delete':
        return 'deleted';
      default:
        return 'unknown';
    }
  }
}

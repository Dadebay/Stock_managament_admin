import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/product/widgets/widgets.dart';

class LogsView extends StatefulWidget {
  const LogsView({super.key});

  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  late Future<List<LogModel>> _logs;

  @override
  void initState() {
    super.initState();
    _logs = LogService().fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LogModel>>(
      future: _logs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("noData".tr));
        }

        final logs = snapshot.data!;
        return ListView.separated(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Row(
              children: [
                CustomWidgets.counter(logs.length - index),
                Expanded(
                  child: ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            "${log.operation} – ${getLabelForMethod(log.method).tr}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(
                          getIconForMethod(log.method),
                          color: getColorForMethod(log.method),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "${'userName'.tr}: ${log.username} (${log.isSuperuser ? 'admin'.tr : 'user'.tr})\n"
                      "${'name'.tr}: ${log.name}\n"
                      "${'date'.tr} ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.datetime)}",
                    ),
                    isThreeLine: true,
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        );
      },
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

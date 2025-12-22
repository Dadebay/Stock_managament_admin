import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/components/client_add_button.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class ClientCard extends StatelessWidget {
  ClientCard({
    required this.client,
    required this.count,
    required this.isAdmin,
    required this.topTextColumnSize,
    super.key,
  });

  final ClientModel client;
  final int count;
  final bool isAdmin;
  final List<Map<String, dynamic>> topTextColumnSize;
  final ClientsController clientsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // ID Badge
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Content
            Expanded(
              child: Row(
                children: [
                  ..._buildDynamicTextWidgets(),
                ],
              ),
            ),
            // Action buttons
            if (isAdmin) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicTextWidgets() {
    return topTextColumnSize.map<Widget>((column) {
      final flex = CustomWidgets().getFlexForSize(column['size'].toString());
      final value = _getClientFieldBySortName(column['sortName']);
      final columnName = column['name'] ?? '';

      return Expanded(
        flex: flex,
        child: Container(
          margin: EdgeInsets.only(right: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                columnName.toString().tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value ?? '',
                maxLines: 2,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String? _getClientFieldBySortName(String key) {
    switch (key) {
      case 'name':
        return client.name;
      case 'address':
        return client.address;
      case 'number':
        return client.phone;
      case 'order_count':
        return client.orderCount.toString();
      case 'sum_price':
        return client.sumPrice;
      default:
        return '';
    }
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () async {
              final confirm = await Get.defaultDialog<bool>(
                title: 'delete'.tr,
                middleText: '${'confirmDelete'.tr} ${client.name}?',
                textConfirm: 'yes'.tr,
                textCancel: 'no'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () => Get.back(result: true),
                onCancel: () => Get.back(result: false),
              );

              if (confirm == true) {
                await ClientsService().deleteClient(id: client.id!);
                clientsController.deleteClient(client.id!);
                CustomWidgets.showSnackBar(
                  "deleted".tr,
                  "${client.name} ${"clientDeleted".tr}",
                  Colors.red,
                );
              }
            },
            icon: const Icon(
              IconlyLight.delete,
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              IconlyLight.editSquare,
              color: Colors.black87,
            ),
            onPressed: () {
              showDialog(
                context: Get.context!,
                builder: (context) {
                  return ClientAddButton(
                    model: client,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/components/enter_add_button.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_controller.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class EnterCard extends StatelessWidget {
  EnterCard({
    required this.client,
    required this.count,
    required this.topTextColumnSize,
    required this.isAdmin,
    super.key,
  });

  final EnterModel client;
  final int count;
  final bool isAdmin;
  final List<Map<String, dynamic>> topTextColumnSize;

  final EnterController clientsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (client.isSuperUser ?? false) ? Colors.amber.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
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
                color: (client.isSuperUser ?? false) ? Colors.amber.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (client.isSuperUser ?? false) ? Colors.amber : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: (client.isSuperUser ?? false) ? Colors.amber[800] : Colors.grey[700],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Content
            ..._buildDynamicTextWidgets(),
            // Action buttons
            if (isAdmin) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicTextWidgets() {
    return topTextColumnSize.asMap().entries.map<Widget>((entry) {
      final column = entry.value;
      final index = entry.key;
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
              if (column['sortName'] == 'isSuperUser')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: value == 'true' ? Colors.amber : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value == 'true' ? 'Admin' : 'User',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: value == 'true' ? Colors.black87 : Colors.grey[700],
                    ),
                  ),
                )
              else
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
      case 'username':
        return client.username;
      case 'password':
        return client.password;
      case 'isSuperUser':
        return client.isSuperUser.toString();
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
                middleText: '${'confirmDelete'.tr} ${client.username}?',
                textConfirm: 'yes'.tr,
                textCancel: 'no'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () => Get.back(result: true),
                onCancel: () => Get.back(result: false),
              );

              if (confirm == true) {
                await EnterService().deleteClient(id: client.id!);
                clientsController.deleteClient(client.id!);
                CustomWidgets.showSnackBar(
                  "deleted".tr,
                  "${client.username} ${"clientDeleted".tr}",
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
                  return EnterAddButton(
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

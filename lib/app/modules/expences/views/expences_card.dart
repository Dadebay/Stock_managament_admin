import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_service.dart';
import 'package:stock_managament_admin/app/modules/expences/views/edit_add_expences.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class ExpencesCard extends StatelessWidget {
  ExpencesCard({
    required this.expencesModel,
    required this.count,
    required this.isAdmin,
    required this.topTextColumnSize,
    super.key,
  });

  final ExpencesModel expencesModel;
  final int count;
  final bool isAdmin;
  final List<Map<String, dynamic>> topTextColumnSize;

  final ExpencesController expencesController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
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
            if (isAdmin) _buildDeleteButton(context),
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

      if (columnName == '') {
        return const SizedBox.shrink();
      }

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
        return expencesModel.name;
      case 'date':
        return expencesModel.date!;
      case 'cost':
        return expencesModel.cost.toString();
      case 'notes':
        return expencesModel.note.toString();
      default:
        return '';
    }
  }

  Widget _buildDeleteButton(BuildContext context) {
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
              final confirm = await ConfirmDialog.show(
                title: 'delete'.tr,
                message: '${'confirmDelete'.tr} ${expencesModel.name}?',
              );

              if (confirm == true) {
                await ExpencesService().deleteExpence(model: expencesModel);
                expencesController.totalPrice.value -= double.tryParse(expencesModel.cost.toString()) ?? 0.0;
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditAddExpencesDialog(model: expencesModel),
              );
            },
            icon: const Icon(
              IconlyLight.editSquare,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

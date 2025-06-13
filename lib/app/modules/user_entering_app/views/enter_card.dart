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
    final textStyle = context.general.textTheme.titleMedium!;
    final fadedTextStyle = textStyle.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: ColorConstants.blackColor,
    );

    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.counter(count),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildDynamicTextWidgets(fadedTextStyle),
                isAdmin ? _buildActionButtons() : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicTextWidgets(TextStyle faded) {
    return topTextColumnSize.map<Widget>((column) {
      final flex = CustomWidgets().getFlexForSize(column['size'].toString());
      final value = _getClientFieldBySortName(column['sortName']);
      return Expanded(
        flex: flex,
        child: Container(
          margin: EdgeInsets.only(left: 20.w),
          child: Text(
            value ?? '',
            maxLines: 3,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: faded,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              clientsController.deleteClient(client.id!);

              await EnterService().deleteClient(id: client.id!);
              CustomWidgets.showSnackBar("deleted", "${client.username} " + "clientDeleted".tr, ColorConstants.redColor);
            },
            icon: const Icon(
              IconlyLight.delete,
              color: Colors.red,
            ),
          ),
          IconButton(
              icon: const Icon(IconlyLight.editSquare, color: ColorConstants.blackColor),
              onPressed: () {
                showDialog(
                  context: Get.context!,
                  builder: (context) {
                    return EnterAddButton(
                      model: client,
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}

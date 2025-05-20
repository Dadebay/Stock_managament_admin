import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/components/client_add_button.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ClientCard extends StatelessWidget {
  ClientCard({
    required this.client,
    required this.count,
    required this.topTextColumnSize,
    super.key,
  });

  final ClientModel client;
  final int count;
  final List<Map<String, dynamic>> topTextColumnSize;

  final ClientsController clientsController = Get.find();

  @override
  Widget build(BuildContext context) {
    final textStyle = context.general.textTheme.titleMedium!;
    final fadedTextStyle = textStyle.copyWith(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: ColorConstants.greyColor,
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
                _buildActionButtons(),
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
        child: Text(
          value ?? '',
          maxLines: 3,
          textAlign: flex == 1 ? TextAlign.end : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: faded,
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
        return "+993 " + client.phone;
      case 'order_count':
        return client.orderCount.toString();
      case 'sum_price':
        return client.sumPrice;
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

              await ClientsService().deleteClient(id: client.id!);
              CustomWidgets.showSnackBar("deleted", "${client.name} " + "clientDeleted".tr, ColorConstants.redColor);
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
                    return ClientAddButton(
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

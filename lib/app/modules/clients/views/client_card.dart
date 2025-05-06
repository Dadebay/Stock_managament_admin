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
      fontSize: 17.sp,
      fontWeight: FontWeight.w500,
      color: ColorConstants.greyColor,
    );

    return Padding(
      padding: EdgeInsets.only(top: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              count.toString(),
              style: textStyle.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
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
          textAlign: flex == 1
              ? column['sortName'] == "name"
                  ? TextAlign.start
                  : TextAlign.center
              : TextAlign.start,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              await ClientsService().deleteClient(id: client.id!);
              CustomWidgets.showSnackBar("deleted", "${client.name} " + "clientDeleted".tr, ColorConstants.redColor);
            },
            icon: const Icon(
              IconlyLight.delete,
              color: Colors.red,
            ),
          ),
          IconButton(
              icon: const Icon(IconlyLight.edit, color: ColorConstants.blackColor),
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

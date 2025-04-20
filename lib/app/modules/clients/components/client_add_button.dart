import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ClientAddButton extends StatelessWidget {
  final TextEditingController userNameEditingController = TextEditingController();
  final TextEditingController addressEditingController = TextEditingController();
  final TextEditingController phoneNumberEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "button",
      onPressed: () {
        Get.defaultDialog(
          title: "add_client".tr,
          titleStyle: context.general.textTheme.titleLarge!.copyWith(fontSize: 28.sp, fontWeight: FontWeight.bold),
          contentPadding: context.padding.horizontalNormal,
          titlePadding: context.padding.verticalLow.copyWith(top: 20.h, bottom: 0),
          content: SizedBox(
            width: Get.size.width / 3,
            height: Get.size.height / 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomTextField(
                  labelName: 'client_name',
                  controller: userNameEditingController,
                  focusNode: focusNode,
                  requestfocusNode: focusNode1,
                ),
                CustomTextField(
                  labelName: 'address',
                  controller: addressEditingController,
                  focusNode: focusNode1,
                  requestfocusNode: focusNode2,
                ),
                PhoneNumberTextField(mineFocus: focusNode2, controller: phoneNumberEditingController, requestFocus: focusNode, style: true, unFocus: false),
                AgreeButton(
                    onTap: () async {
                      await ClientsService().addClient(name: userNameEditingController.text, address: addressEditingController.text, phone: phoneNumberEditingController.text, context: context);
                    },
                    text: "add_client")
              ],
            ),
          ),
        );
      },
      child: const Icon(IconlyLight.plus),
    );
  }
}

// ignore_for_file: must_be_immutable

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ClientAddButton extends StatelessWidget {
  final ClientModel? model;

  final TextEditingController userNameEditingController = TextEditingController();
  final TextEditingController addressEditingController = TextEditingController();
  final TextEditingController phoneNumberEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  ClientAddButton({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    final isEdit = model != null;

    if (isEdit) {
      userNameEditingController.text = model!.name;
      addressEditingController.text = model!.address;
      phoneNumberEditingController.text = model!.phone;
    }
    return AlertDialog(
      title: Text(
        isEdit ? "Edit Client" : "add_client".tr,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 26.sp, fontWeight: FontWeight.bold),
      ),
      contentPadding: context.padding.normal,
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
                final newModel = ClientModel(
                  id: model!.id,
                  name: userNameEditingController.text,
                  address: addressEditingController.text,
                  phone: phoneNumberEditingController.text,
                );
                if (isEdit) {
                  await ClientsService().editClients(model: newModel);
                } else {
                  await ClientsService().addClient(model: newModel);
                }
              },
              text: isEdit ? "Edit Client" : "add_client".tr,
            )
          ],
        ),
      ),
    );
  }
}

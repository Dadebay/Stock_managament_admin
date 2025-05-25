// ignore_for_file: must_be_immutable

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class EnterAddButton extends StatelessWidget {
  final EnterModel? model;

  final TextEditingController userNameEditingController = TextEditingController();
  final TextEditingController addressEditingController = TextEditingController();
  final TextEditingController phoneNumberEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  EnterAddButton({super.key, this.model});

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
                if (model == null) {
                  final newModel = EnterModel(id: 0, name: userNameEditingController.text, address: addressEditingController.text, phone: phoneNumberEditingController.text, orderCount: 0, sumPrice: '');

                  await EnterService().addClient(model: newModel);
                } else {
                  final newModel = EnterModel(
                    id: model!.id ?? 0,
                    name: userNameEditingController.text,
                    address: addressEditingController.text,
                    phone: phoneNumberEditingController.text,
                    orderCount: 0,
                    sumPrice: '',
                  );

                  await EnterService().editClients(model: newModel);
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

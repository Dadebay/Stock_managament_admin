import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class EnterAddButton extends StatefulWidget {
  final EnterModel? model;

  const EnterAddButton({super.key, this.model});

  @override
  State<EnterAddButton> createState() => _EnterAddButtonState();
}

class _EnterAddButtonState extends State<EnterAddButton> {
  final TextEditingController userNameEditingController = TextEditingController();
  final TextEditingController passwordEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();

  bool isSuperUser = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      userNameEditingController.text = widget.model!.username ?? '';
      passwordEditingController.text = widget.model!.password ?? '';
      isSuperUser = widget.model!.isSuperUser ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.model != null;

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
              labelName: 'Password',
              controller: passwordEditingController,
              focusNode: focusNode1,
              requestfocusNode: focusNode,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Super User",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  CupertinoSwitch(
                    value: isSuperUser,
                    onChanged: (value) {
                      setState(() {
                        isSuperUser = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            AgreeButton(
              onTap: () async {
                final newModel = EnterModel(
                  id: widget.model?.id ?? 0,
                  username: userNameEditingController.text,
                  password: passwordEditingController.text,
                  isSuperUser: isSuperUser,
                );

                if (widget.model == null) {
                  await EnterService().addClient(model: newModel);
                } else {
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

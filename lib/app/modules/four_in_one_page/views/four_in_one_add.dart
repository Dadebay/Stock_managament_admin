import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class AddEditFourInOneDialog extends StatelessWidget {
  final FourInOneModel? model;
  final String name;
  final String url;
  final String editKey;
  AddEditFourInOneDialog({this.model, required this.name, required this.url, required this.editKey});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode notesFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final isEdit = model != null;

    if (isEdit) {
      nameController.text = model!.name;
      notesController.text = model!.notes;
    }

    return AlertDialog(
      title: Text(
        isEdit ? 'Edit $name' : 'Add $name',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 26.sp, fontWeight: FontWeight.bold),
      ),
      titlePadding: EdgeInsets.only(top: 20),
      content: SizedBox(
        width: Get.size.width / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              labelName: 'Name',
              controller: nameController,
              focusNode: nameFocusNode,
              requestfocusNode: notesFocusNode,
            ),
            CustomTextField(
              labelName: 'Note',
              controller: notesController,
              focusNode: notesFocusNode,
              requestfocusNode: addressFocusNode,
            ),
            name == 'location'
                ? CustomTextField(
                    labelName: 'Address',
                    controller: addressController,
                    focusNode: addressFocusNode,
                    requestfocusNode: nameFocusNode,
                  )
                : SizedBox(),
            AgreeButton(
              onTap: () async {
                final newModel = FourInOneModel(id: model?.id ?? 0, name: nameController.text, notes: notesController.text, address: addressController.text, quantity: '');
                if (isEdit) {
                  await FourInOnePageService().editFourInOne(model: newModel, location: name == 'location' ? addressController.text : null, url: url, key: editKey);
                } else {
                  await FourInOnePageService().addFourInOne(model: newModel, location: name == 'location' ? addressController.text : null, url: url, key: editKey);
                }
              },
              text: isEdit ? "Update" : "Add",
            ),
          ],
        ),
      ),
    );
  }
}

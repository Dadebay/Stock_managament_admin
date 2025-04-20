import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class AddEditFourInOneDialog extends StatelessWidget {
  final FourInOneModel? model;
  final String name;
  AddEditFourInOneDialog({super.key, this.model, required this.name});

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
        isEdit ? 'Edit Item' : 'Add Item',
        style: TextStyle(color: Colors.black, fontSize: 24.sp),
      ),
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
              requestfocusNode: nameFocusNode,
            ),
            CustomTextField(
              labelName: 'Address',
              controller: notesController,
              focusNode: notesFocusNode,
              requestfocusNode: nameFocusNode,
            ),
            AgreeButton(
              onTap: () async {
                final newModel = FourInOneModel(id: model?.id ?? 0, name: nameController.text, notes: notesController.text, address: addressController.text);

                // if (isEdit) {
                //   await FourInOnePageService().editExpence(
                //     model: newModel,
                //     context: context,
                //   );
                // } else {
                //   await FourInOnePageService().addExpence(
                //     model: newModel,
                //     context: context,
                //   );
                // }
              },
              text: isEdit ? "Update" : "Add",
            ),
          ],
        ),
      ),
    );
  }
}

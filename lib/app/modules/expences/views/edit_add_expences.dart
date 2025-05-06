import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class EditAddExpencesDialog extends StatefulWidget {
  final ExpencesModel? model; // null ise ekleme modunda

  const EditAddExpencesDialog({super.key, this.model});

  @override
  State<EditAddExpencesDialog> createState() => _EditAddExpencesDialogState();
}

class _EditAddExpencesDialogState extends State<EditAddExpencesDialog> {
  final ExpencesController expencesController = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      nameController.text = widget.model!.name;
      costController.text = widget.model!.cost;
      noteController.text = widget.model!.note;
      selectedDateTime = DateTime.tryParse(widget.model!.date ?? "");
      if (selectedDateTime != null) {
        dateController.text = DateFormat('yyyy-MM-dd , HH:mm').format(selectedDateTime!);
      }
    }
  }

  void pickDateTime() async {
    final result = await CustomWidgets.showDateTimePickerWidget(context: context);
    if (result != null) {
      selectedDateTime = result;
      dateController.text = DateFormat('yyyy-MM-dd , HH:mm').format(selectedDateTime!);
    }
  }

  void handleSubmit() async {
    final isEditing = widget.model != null;

    final model = ExpencesModel(
      id: isEditing ? widget.model!.id : 0,
      name: nameController.text,
      cost: costController.text,
      note: noteController.text,
      date: selectedDateTime.toString().substring(0, 10),
    );
    if (isEditing) {
      await ExpencesService().editExpence(model: model, context: context);
    } else {
      await ExpencesService().addExpence(model: model, context: context);
      expencesController.totalPrice.value += double.tryParse(model.cost.toString()) ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: context.padding.normal,
      child: Container(
        width: Get.size.width / 2,
        padding: context.padding.normal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.model != null ? "Edit Expense" : "Add Expense", style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 22.sp)),
            CustomTextField(labelName: "Name", controller: nameController, focusNode: FocusNode(), requestfocusNode: FocusNode()),
            CustomTextField(labelName: "Cost", controller: costController, focusNode: FocusNode(), requestfocusNode: FocusNode()),
            CustomTextField(labelName: "Note", controller: noteController, maxLine: 3, focusNode: FocusNode(), requestfocusNode: FocusNode()),
            CustomTextField(labelName: "Date", controller: dateController, onTap: pickDateTime, focusNode: FocusNode(), requestfocusNode: FocusNode()),
            const SizedBox(height: 20),
            AgreeButton(
              text: widget.model != null ? "Edit" : "Add",
              onTap: handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

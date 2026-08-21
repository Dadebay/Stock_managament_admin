import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class AddEditFourInOneDialog extends StatefulWidget {
  const AddEditFourInOneDialog(
      {super.key,
      this.model,
      required this.name,
      required this.url,
      required this.editKey});

  final FourInOneModel? model;
  final String name;
  final String url;
  final String editKey;

  @override
  State<AddEditFourInOneDialog> createState() => _AddEditFourInOneDialogState();
}

class _AddEditFourInOneDialogState extends State<AddEditFourInOneDialog> {
  final nameController = TextEditingController();
  final notesController = TextEditingController();
  final addressController = TextEditingController();
  final nameFocusNode = FocusNode();
  final notesFocusNode = FocusNode();
  final addressFocusNode = FocusNode();

  bool get isEdit => widget.model != null;
  bool get isLocation => widget.name == 'location';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.model?.name ?? '';
    notesController.text = widget.model?.notes ?? '';
    addressController.text = widget.model?.address ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    addressController.dispose();
    nameFocusNode.dispose();
    notesFocusNode.dispose();
    addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (nameController.text.trim().isEmpty) {
      nameFocusNode.requestFocus();
      return;
    }
    final newModel = FourInOneModel(
        id: widget.model?.id ?? 0,
        name: nameController.text.trim(),
        notes: notesController.text.trim(),
        address: addressController.text.trim(),
        quantity: '');
    if (isEdit) {
      await FourInOnePageService().editFourInOne(
          model: newModel,
          location: isLocation ? addressController.text.trim() : null,
          url: widget.url,
          key: widget.editKey);
    } else {
      await FourInOnePageService().addFourInOne(
          model: newModel,
          location: isLocation ? addressController.text.trim() : null,
          url: widget.url,
          key: widget.editKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Edit ${widget.name}' : 'Add ${widget.name}';
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                color: const Color(0xFFF8FAFC),
                child: Row(children: [
                  Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(IconlyLight.edit,
                          color: Color(0xFF4F46E5))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontSize: 21.sp,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Enter the details below to save this record.',
                            style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: 14.sp)),
                      ])),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                child: Column(children: [
                  _WebDialogField(
                      label: 'name'.tr,
                      controller: nameController,
                      focusNode: nameFocusNode,
                      nextFocusNode: notesFocusNode,
                      icon: IconlyLight.profile),
                  const SizedBox(height: 18),
                  _WebDialogField(
                      label: 'note'.tr,
                      controller: notesController,
                      focusNode: notesFocusNode,
                      nextFocusNode: isLocation ? addressFocusNode : null,
                      icon: IconlyLight.document,
                      maxLines: 3),
                  if (isLocation) ...[
                    const SizedBox(height: 18),
                    _WebDialogField(
                        label: 'address'.tr,
                        controller: addressController,
                        focusNode: addressFocusNode,
                        icon: IconlyLight.location),
                  ],
                  const SizedBox(height: 28),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                        onPressed: Get.back,
                        child: Text('cancel'.tr,
                            style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600))),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(IconlyLight.tickSquare, size: 19),
                      label: Text((isEdit ? 'update' : 'add').tr),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebDialogField extends StatelessWidget {
  const _WebDialogField(
      {required this.label,
      required this.controller,
      required this.focusNode,
      required this.icon,
      this.nextFocusNode,
      this.maxLines = 1});

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      onSubmitted: (_) => nextFocusNode?.requestFocus(),
      style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: 15.sp,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B))),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
      ),
    );
  }
}

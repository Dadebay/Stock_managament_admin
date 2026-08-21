import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class WebAddProductPage extends StatefulWidget {
  const WebAddProductPage({super.key});

  @override
  State<WebAddProductPage> createState() => _WebAddProductPageState();
}

class _WebAddProductPageState extends State<WebAddProductPage> {
  final SearchViewController controller = Get.find<SearchViewController>();
  final int fieldCount = 12;
  late List<TextEditingController> textControllers;
  late List<FocusNode> focusNodes;
  late List<String?> selectedIds;

  @override
  void initState() {
    super.initState();
    controller.clearSelectedImage();
    textControllers = List.generate(fieldCount, (_) => TextEditingController());
    focusNodes = List.generate(fieldCount, (_) => FocusNode());
    selectedIds = List<String?>.filled(fieldCount, null);
  }

  @override
  void dispose() {
    for (var tc in textControllers) {
      tc.dispose();
    }
    for (var fn in focusNodes) {
      fn.dispose();
    }

    super.dispose();
  }

  Future<void> _handleAddProduct() async {
    if (textControllers[0].text.isEmpty) {
      CustomWidgets.showSnackBar(
          "Hata", "Ürün adı boş bırakılamaz.", Colors.red);
      return;
    }
    if (controller.selectedImageBytes.value == null) {}

    Map<String, String> productData = {};
    for (int i = 0; i < fieldCount; i++) {
      final key = StringConstants.apiFieldNames[i];

      if (i == 3 || i == 4 || i == 5 || i == 6) {
        productData[key] = selectedIds[i] ?? '';
      } else {
        productData[key] = textControllers[i].text;
      }
    }
    controller.selectedImageFileName.value =
        "${textControllers[0].text.replaceAll(' ', '_')}_image.png";
    productData['gram'] =
        (productData['gram'] == '' ? '0' : productData['gram'])!;
    print(productData);
    print(controller.selectedImageBytes.value);
    print("${textControllers[0].text.replaceAll(' ', '_')}_image.png");

    await controller.addNewProduct(
        productData: productData,
        selectedImageBytes: controller.selectedImageBytes.value,
        selectedImageFileName:
            "${textControllers[0].text.replaceAll(' ', '_')}_image.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: const CustomAppBar(
          backArrow: true,
          actionIcon: false,
          centerTitle: true,
          name: "Haryt goş",
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(builder: (context, constraints) {
                final narrow = constraints.maxWidth < 820;
                final image = _imagePicker();
                final form = _formPanel(context);
                return narrow
                    ? Column(
                        children: [image, const SizedBox(height: 16), form])
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 270, child: image),
                          const SizedBox(width: 20),
                          Expanded(child: form),
                        ],
                      );
              }),
            ),
          ),
        ));
  }

  Widget _imagePicker() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Haryt suraty',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Surat saýlamak üçin meýdana basyň.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 16),
          Obx(() => InkWell(
                onTap: controller.pickImage,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: 230,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: controller.selectedImageBytes.value != null
                      ? Image.memory(controller.selectedImageBytes.value!,
                          fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 34, color: Color(0xFF64748B)),
                            SizedBox(height: 10),
                            Text('Surat saýla',
                                style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              )),
        ]),
      );

  Widget _formPanel(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Haryt maglumatlary',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Esasy maglumatlary dolduryň.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 20),
          _buildTextFields(context),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _handleAddProduct,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Haryt goş'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ]),
      );

  Widget _buildTextFields(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(fieldCount, (index) {
          final wide = index == 9 || index == 10;
          return SizedBox(
            width: wide ? constraints.maxWidth : width,
            child: _field(context, index),
          );
        }),
      );
    });
  }

  Widget _field(BuildContext context, int index) {
    final label = StringConstants.fieldLabels[index];
    final selectable = [3, 4, 5, 6].contains(index);
    final date = index == 2;
    final multiline = index == 9 || index == 10;
    return TextFormField(
      controller: textControllers[index],
      focusNode: focusNodes[index],
      readOnly: selectable || date,
      maxLines: multiline ? 3 : 1,
      onTap: () async {
        if (date) {
          final value =
              await CustomWidgets.showDateTimePickerWidget(context: context);
          if (value != null) {
            textControllers[index].text =
                DateFormat('yyyy-MM-dd, HH:mm').format(value);
          }
          return;
        }
        if (!selectable) return;
        focusNodes[index].unfocus();
        final fieldApiName = StringConstants.apiFieldNames[index];
        try {
          final info = StringConstants.four_in_one_names
              .firstWhere((element) => element['countName'] == fieldApiName);
          DialogsUtils().showSelectableDialog(
            context: context,
            title: label,
            url: info['url'].toString(),
            targetController: textControllers[index],
            onIdSelected: (id) => selectedIds[index] = id,
          );
        } catch (_) {
          CustomWidgets.showSnackBar(
              'Ýalňyşlyk', 'Maglumat tapylmady', Colors.red);
        }
      },
      decoration: InputDecoration(
        labelText: label.tr,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        suffixIcon: selectable
            ? const Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8))
            : date
                ? const Icon(Icons.calendar_today_outlined,
                    size: 17, color: Color(0xFF94A3B8))
                : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.4)),
      ),
    );
  }
}

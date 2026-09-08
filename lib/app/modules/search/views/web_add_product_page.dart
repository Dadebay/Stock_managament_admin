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

  /// Guards the submit button: without it the form can be posted twice and the
  /// user gets no feedback while the upload runs.
  bool _submitting = false;

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
    if (_submitting) return;
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
    // Keep the extension the compressor produced (webp), otherwise the upload
    // would be sent with a wrong content type.
    final pickedName = controller.selectedImageFileName.value ?? '';
    final extension =
        pickedName.contains('.') ? pickedName.split('.').last : 'png';
    final uploadName =
        "${textControllers[0].text.replaceAll(' ', '_')}_image.$extension";
    controller.selectedImageFileName.value = uploadName;
    // Decimals are typed with a comma or a dot; Django only accepts the dot.
    for (final key in ['price', 'cost', 'gram']) {
      final value = (productData[key] ?? '').replaceAll(',', '.');
      productData[key] = value.isEmpty ? '0' : value;
    }
    if ((productData['count'] ?? '').isEmpty) productData['count'] = '0';
    // The picker shows "2026-09-08, 00:00" but Django only accepts the value
    // without the comma; send the API format, keep the pretty text on screen.
    final date = productData['date'];
    if (date != null && date.isNotEmpty) {
      productData['date'] = date.replaceFirst(', ', ' ');
    }

    setState(() => _submitting = true);
    try {
      await controller.addNewProduct(
          productData: productData,
          selectedImageBytes: controller.selectedImageBytes.value,
          selectedImageFileName: uploadName);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
              onPressed: _submitting ? null : _handleAddProduct,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add_rounded, size: 18),
              label: Text(_submitting ? 'Ýatda saklanýar...' : 'Haryt goş'),
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

  /// Typed fields on the left, pickers (date + dropdowns) on the right, with
  /// the two prices next to each other. Long notes span the full width.
  static const List<int> _typedFields = [0, 1, 11, 7, 8];
  static const List<int> _pickerFields = [2, 3, 4, 5, 6];
  static const List<int> _wideFields = [9, 10];

  Widget _buildTextFields(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 640;
      if (narrow) {
        return Column(
          children: [
            for (final index in [
              ..._typedFields,
              ..._pickerFields,
              ..._wideFields
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _field(context, index),
              ),
          ],
        );
      }

      final rows = _typedFields.length > _pickerFields.length
          ? _typedFields.length
          : _pickerFields.length;
      return Column(
        children: [
          for (int row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: row < _typedFields.length
                        ? _field(context, _typedFields[row])
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: row < _pickerFields.length
                        ? _field(context, _pickerFields[row])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          for (final index in _wideFields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _field(context, index),
            ),
        ],
      );
    });
  }

  /// price, cost and gram accept decimals; count is a whole number.
  static const List<int> _decimalFields = [1, 11, 7];
  static const int _integerField = 8;

  Widget _field(BuildContext context, int index) {
    final label = StringConstants.fieldLabels[index];
    final selectable = [3, 4, 5, 6].contains(index);
    final date = index == 2;
    final multiline = index == 9 || index == 10;
    final decimal = _decimalFields.contains(index);
    final integer = index == _integerField;
    return TextFormField(
      controller: textControllers[index],
      focusNode: focusNodes[index],
      readOnly: selectable || date,
      maxLines: multiline ? 3 : 1,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : (integer ? TextInputType.number : null),
      inputFormatters: decimal
          ? [_DecimalInputFormatter()]
          : (integer ? [FilteringTextInputFormatter.digitsOnly] : null),
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

/// Allows digits with a single decimal separator (comma or dot); letters and
/// extra separators are rejected as they are typed.
class _DecimalInputFormatter extends TextInputFormatter {
  static final RegExp _pattern = RegExp(r'^\d*[.,]?\d*$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

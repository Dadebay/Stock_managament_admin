import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class ProductProfilView extends StatefulWidget {
  const ProductProfilView({super.key, required this.product, required this.disableUpdate, required this.isAdmin});
  final bool isAdmin;
  final SearchModel product;
  final bool disableUpdate;

  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  final SearchViewController controller = Get.find<SearchViewController>();

  final int fieldCount = 12;
  late List<FocusNode> focusNodes;
  late List<TextEditingController> textControllers;
  late List<String?> selectedIds;
  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(fieldCount, (_) => FocusNode());
    textControllers = List.generate(fieldCount, (_) => TextEditingController());
    selectedIds = List<String?>.filled(fieldCount, null);
    _populateTextFields();
  }

  @override
  void dispose() {
    for (var controller in textControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    controller.clearSelectedImage();
    super.dispose();
  }

  void _populateTextFields() {
    textControllers[0].text = widget.product.name;
    textControllers[1].text = widget.product.price;

    // Safe substring handling for createdAT
    String dateString = widget.product.createdAT.toString().replaceAll("T", " ");
    textControllers[2].text = dateString.length >= 15 ? dateString.substring(0, 15) : dateString;

    textControllers[3].text = widget.product.category?.name ?? '';
    textControllers[4].text = widget.product.brend?.name ?? '';
    textControllers[5].text = widget.product.location?.name ?? '';
    textControllers[6].text = widget.product.material?.name ?? '';
    textControllers[7].text = widget.product.gramm;
    textControllers[8].text = widget.product.count.toString();
    textControllers[9].text = widget.product.description;
    textControllers[10].text = widget.product.gaplama;
    textControllers[11].text = widget.product.cost;
    selectedIds[3] = widget.product.category?.id.toString(); // category
    selectedIds[4] = widget.product.brend?.id.toString(); // brend
    selectedIds[5] = widget.product.location?.id.toString(); // location
    selectedIds[6] = widget.product.material?.id.toString();
  }

  Future<void> _handleUpdate() async {
    Map<String, String> productData = {};
    for (int i = 0; i < fieldCount; i++) {
      final key = StringConstants.apiFieldNames[i];

      if ([3, 4, 5, 6].contains(i)) {
        final selectedId = selectedIds[i];
        if (selectedId == null || selectedId.isEmpty) {
          productData[key] = '';
          continue;
        }
        productData[key] = selectedId;

        if (productData[key] == '0') {
          productData[key] = '';
        }
      } else {
        if (textControllers[i].text == '' || textControllers[i].text.isEmpty) {
          productData[key] = '';
          continue;
        }
        if (productData[key] == '0') {
          productData[key] = '';
        }
        productData[key] = textControllers[i].text;
      }
    }

    // Decimals are typed with a comma or a dot; Django only accepts the dot.
    for (final key in ['price', 'cost', 'gram']) {
      final value = productData[key];
      if (value != null && value.isNotEmpty) {
        productData[key] = value.replaceAll(',', '.');
      }
    }

    String? finalImageFileName;
    if (controller.selectedImageBytes.value != null) {
      finalImageFileName = controller.selectedImageFileName.value; // Resim seçildiyse dosya adını al
      if (finalImageFileName == null || finalImageFileName.isEmpty) {
        finalImageFileName = "${widget.product.name}_updated.png";
      }
    }
    await SearchService()
        .updateProductWithImage(
      id: widget.product.id,
      fields: productData,
      imageBytes: controller.selectedImageBytes.value, // Controller'dan byte'ları al
      imageFileName: finalImageFileName, // Controller'dan veya oluşturulan dosya adını al
    )
        .then((_) {
      Navigator.pop(context);
      CustomWidgets.showSnackBar("Success", "Product updated successfully", Colors.green);
    }).catchError((error) {
      CustomWidgets.showSnackBar("Error", "Failed to update product: $error", Colors.red);
    });
  }

  Future<void> _handleDeleteRequest() async {
    final confirmed = await ConfirmDialog.show(
      title: 'Haryt pozmak',
      message: 'Bu haryt hemişelik pozular. Dowam etmek isleýärsiňizmi?',
    );

    if (confirmed == true) {
      Navigator.pop(context);
      await SearchService().deleteProduct(id: widget.product.id);
      Future.delayed(const Duration(milliseconds: 100), () {
        CustomWidgets.showSnackBar("Üstünlik", "Haryt pozuldy", Colors.green);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<PurchaseModelInsideProduct> purchList = widget.product.purch.reversed.toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          backArrow: true,
          centerTitle: true,
          actionIcon: widget.isAdmin ? true : false,
          icon: IconButton(tooltip: "Delete Product", onPressed: _handleDeleteRequest, icon: Icon(IconlyLight.delete, color: Colors.red)),
          name: "${widget.product.name}"),
      body: Row(
        children: [
          _mainBody(context),
          const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                children: [
                  Row(children: [
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Satyn alma taryhy', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 3),
                        Text('Soňky hereketler', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(7)),
                      child: Text('${purchList.length} ýazgy', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _topText(purchList),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: purchList.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        final item = purchList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: .04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${purchList.length - index}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              _buildInfoColumn2(item.purchaseName ?? '-'),
                              _buildInfoColumn2(item.datePurhcase ?? '-'),
                              _buildInfoColumn2('${item.priceOfSale}'),
                              _buildInfoColumn2('${item.count} sany'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Align(alignment: Alignment.centerRight, child: SizedBox(width: 360, child: _buildTotalSummary(purchList))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn2(String value) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _topText(List<PurchaseModelInsideProduct> displayList) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              '№',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Haryt ady',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Sene',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Bahasy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Sany',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(List<PurchaseModelInsideProduct> purchList) {
    double totalPrice = 0.0;
    int totalCount = 0;

    for (var item in purchList) {
      try {
        final price = double.tryParse(item.priceOfSale ?? '0') ?? 0.0;
        final count = int.tryParse(item.count ?? '0') ?? 0;
        totalPrice += price * count;
        totalCount += count;
      } catch (e) {
        // Skip items with invalid data
      }
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF166534),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jemi sany',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$totalCount sany',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            height: 50.h,
            width: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Jemi bahasy',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mainBody(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _productSummary(),
          const SizedBox(height: 18),
          _buildTextFields(context),
          widget.isAdmin
              ? Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _handleUpdate,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Üýtget'),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _productSummary() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          Obx(() {
            final image = controller.selectedImageBytes.value != null ? Image.memory(controller.selectedImageBytes.value!, fit: BoxFit.cover) : CustomWidgets.imageWidget(widget.product.img);
            return InkWell(
              onTap: _showImagePreview,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 132,
                height: 132,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
                child: image,
              ),
            );
          }),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('ID #${widget.product.id}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.product.count > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text('Sany: ${widget.product.count}',
                    style: TextStyle(color: widget.product.count > 0 ? const Color(0xFF15803D) : const Color(0xFFDC2626), fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              if (widget.isAdmin) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: controller.pickImage,
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Suraty üýtget'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ]),
          ),
        ]),
      );

  void _showImagePreview() {
    final imageBytes = controller.selectedImageBytes.value;
    final rawImage = widget.product.img ?? '';
    if (imageBytes == null && rawImage.isEmpty) return;
    final imageUrl = rawImage.startsWith(ApiConstants.imageURL) ? rawImage : '${ApiConstants.imageURL2}$rawImage';
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(32),
        child: Stack(children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820, maxHeight: 700),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.contain)
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(height: 320, child: Center(child: CircularProgressIndicator())),
                      errorWidget: (_, __, ___) => const SizedBox(height: 240, child: Center(child: Icon(Icons.broken_image_outlined))),
                    ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: .55),
              shape: const CircleBorder(),
              child: IconButton(onPressed: Get.back, icon: const Icon(Icons.close_rounded, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  /// Typed fields on the left, pickers (date + dropdowns) on the right, with
  /// the two prices next to each other. Long notes span the full width.
  static const List<int> _typedFields = [0, 1, 11, 7, 8];
  static const List<int> _pickerFields = [2, 3, 4, 5, 6];
  static const List<int> _wideFields = [9, 10];

  Widget _buildTextFields(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 640) {
        return Column(
          children: [
            for (final index in [
              ..._typedFields,
              ..._pickerFields,
              ..._wideFields
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _productField(index),
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
                        ? _productField(_typedFields[row])
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: row < _pickerFields.length
                        ? _productField(_pickerFields[row])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          for (final index in _wideFields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _productField(index),
            ),
        ],
      );
    });
  }

  /// price, cost and gram accept decimals; count is a whole number.
  static const List<int> _decimalFields = [1, 11, 7];
  static const int _integerField = 8;

  Widget _productField(int index) {
    final label = StringConstants.fieldLabels[index];
    final selectable = [3, 4, 5, 6].contains(index);
    final multiline = index == 9 || index == 10;
    final decimal = _decimalFields.contains(index);
    final integer = index == _integerField;
    return TextFormField(
      controller: textControllers[index],
      focusNode: focusNodes[index],
      readOnly: !widget.isAdmin || selectable,
      maxLines: multiline ? 3 : 1,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : (integer ? TextInputType.number : null),
      inputFormatters: decimal
          ? [_DecimalInputFormatter()]
          : (integer ? [FilteringTextInputFormatter.digitsOnly] : null),
      onTap: () {
        if (!widget.isAdmin || !selectable) return;
        final fieldName = StringConstants.apiFieldNames[index];
        final url = StringConstants.four_in_one_names.firstWhere((element) => element['countName'] == fieldName)['url'].toString();
        DialogsUtils().showSelectableDialog(
          context: context,
          title: label,
          url: url,
          targetController: textControllers[index],
          onIdSelected: (id) => selectedIds[index] = id,
        );
      },
      decoration: InputDecoration(
        labelText: label.tr,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: widget.isAdmin ? Colors.white : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.4)),
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

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
          Expanded(
            child: Column(
              children: [
                _topText(purchList),
                Expanded(
                  child: ListView.builder(
                    itemCount: purchList.length,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemBuilder: (BuildContext context, int index) {
                      final item = purchList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade100.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36.w,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${purchList.length - index}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            _buildInfoColumn2(item.purchaseName ?? '-'),
                            _buildInfoColumn2(item.datePurhcase ?? '-'),
                            _buildInfoColumn2('${item.priceOfSale} TMT'),
                            _buildInfoColumn2('${item.count} sany'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildTotalSummary(purchList),
              ],
            ),
          )
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              '№',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Haryt ady',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Sene',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Bahasy',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Sany',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: Colors.white.withOpacity(0.9),
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
            color: Colors.white.withOpacity(0.3),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Jemi bahasy',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${totalPrice.toStringAsFixed(2)} TMT',
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
        padding: context.padding.horizontalMedium,
        children: [
          Obx(() {
            final imageToShow = controller.selectedImageBytes.value != null ? Image.memory(controller.selectedImageBytes.value!, fit: BoxFit.cover) : CustomWidgets.imageWidget(widget.product.img!);

            return Center(
              child: GestureDetector(
                onTap: () {
                  if (widget.isAdmin) {
                    controller.pickImage();
                  }
                },
                child: Container(
                  width: 300,
                  height: 300,
                  margin: context.padding.verticalMedium,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: context.border.normalBorderRadius, border: Border.all(color: Colors.grey.shade300, width: 1)),
                  child: ClipRRect(
                    borderRadius: context.border.normalBorderRadius,
                    child: imageToShow,
                  ),
                ),
              ),
            );
          }),
          _buildTextFields(context),
          widget.isAdmin
              ? AgreeButton(
                  onTap: _handleUpdate,
                  text: "Update Product",
                )
              : SizedBox(),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildTextFields(BuildContext context) {
    return Column(
      children: List.generate(fieldCount, (index) {
        final label = StringConstants.fieldLabels[index];
        final isSelectableField = index == 3 || index == 4 || index == 5 || index == 6;

        return CustomTextField(
          onTap: () {
            if (widget.isAdmin) {
              if (isSelectableField) {
                final fieldName = StringConstants.apiFieldNames[index];
                final url = StringConstants.four_in_one_names.firstWhere((element) => element['countName'] == fieldName)['url'].toString();
                DialogsUtils().showSelectableDialog(
                  context: context,
                  title: label,
                  url: url,
                  targetController: textControllers[index],
                  onIdSelected: (id) {
                    selectedIds[index] = id;
                  },
                );
              }
            }
          },
          labelName: label,
          readOnly: widget.isAdmin ? false : true,
          controller: textControllers[index],
          focusNode: focusNodes[index],
          requestfocusNode: (index < fieldCount - 1) ? focusNodes[index + 1] : focusNodes[0],
          maxLine: (StringConstants.apiFieldNames[index] == 'description') ? 3 : 1,
        );
      }),
    );
  }
}

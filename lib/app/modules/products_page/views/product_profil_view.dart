import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ProductProfilView extends StatefulWidget {
  const ProductProfilView({super.key, required this.product, required this.disableUpdate});

  final SearchModel product;
  final bool disableUpdate;

  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  final SearchViewController controller = Get.find<SearchViewController>();

  final int fieldCount = 11;
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
    textControllers[2].text = widget.product.category?.name ?? '';
    textControllers[3].text = widget.product.brend?.name ?? '';
    textControllers[4].text = widget.product.location?.name ?? '';
    textControllers[5].text = widget.product.material?.name ?? '';
    textControllers[6].text = widget.product.gramm;
    textControllers[7].text = widget.product.count.toString();
    textControllers[8].text = widget.product.description;
    textControllers[9].text = widget.product.gaplama;
    textControllers[10].text = widget.product.cost;
    selectedIds[2] = widget.product.category?.id.toString(); // category
    selectedIds[3] = widget.product.brend?.id.toString(); // brend
    selectedIds[4] = widget.product.location?.id.toString(); // location
    selectedIds[5] = widget.product.material?.id.toString();
  }

  Future<void> _handleUpdate() async {
    Map<String, String> productData = {};
    for (int i = 0; i < fieldCount; i++) {
      final key = StringConstants.apiFieldNames[i];

      if ([2, 3, 4, 5].contains(i)) {
        final selectedId = selectedIds[i];
        if (selectedId == null || selectedId.isEmpty) {
          productData[key] = '';
          continue;
        }
        productData[key] = selectedId;
      } else {
        if (textControllers[i].text == '' || textControllers[i].text.isEmpty) {
          productData[key] = '';
          continue;
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
      print(error.toString());
      CustomWidgets.showSnackBar("Error", "Failed to update product: $error", Colors.red);
    });
  }

  Future<void> _handleDeleteRequest() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action will permanently delete this PRODUCT'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);
              await SearchService().deleteProduct(id: widget.product.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: true, icon: IconButton(tooltip: "Delete Product", onPressed: _handleDeleteRequest, icon: Icon(IconlyLight.delete, color: Colors.red)), name: "${widget.product.name}"),
      body: ListView(
        padding: Get.size.width > 1000 ? EdgeInsets.symmetric(horizontal: Get.size.width / 4) : context.padding.horizontalMedium,
        children: [
          Obx(() {
            final imageToShow = controller.selectedImageBytes.value != null
                ? Image.memory(controller.selectedImageBytes.value!, fit: BoxFit.cover)
                : CustomWidgets.imageWidget(
                    widget.product.img!,
                    false,
                  );

            return Center(
              child: GestureDetector(
                onTap: () {
                  controller.pickImage();
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
          AgreeButton(
            onTap: _handleUpdate,
            text: "Update Product",
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildTextFields(BuildContext context) {
    return Column(
      children: List.generate(fieldCount, (index) {
        final label = StringConstants.fieldLabels[index];
        final isSelectableField = index == 2 || index == 3 || index == 4 || index == 5;

        return CustomTextField(
          onTap: () {
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
          },
          labelName: label,
          controller: textControllers[index],
          focusNode: focusNodes[index],
          requestfocusNode: (index < fieldCount - 1) ? focusNodes[index + 1] : focusNodes[0],
          maxLine: (StringConstants.apiFieldNames[index] == 'description') ? 3 : 1,
        );
      }),
    );
  }
}

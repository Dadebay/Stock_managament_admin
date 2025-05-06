import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/product_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ProductProfilView extends StatefulWidget {
  const ProductProfilView({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  final SeacrhViewController controller = Get.find<SeacrhViewController>();

  final int fieldCount = 11;
  late List<FocusNode> focusNodes;
  late List<TextEditingController> textControllers;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(fieldCount, (_) => FocusNode());
    textControllers = List.generate(fieldCount, (_) => TextEditingController());
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
  }

  void _handleUpdate() {
    Map<String, String> productData = {};
    for (int i = 0; i < fieldCount; i++) {
      productData[StringConstants.apiFieldNames[i]] = textControllers[i].text;
    }
    print(productData);
    // controller.updateProduct(productData);
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

              await ProductsService().deleteProduct(id: widget.product.id);
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
        padding: context.padding.medium,
        children: [
          Obx(() => Center(
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
                        child: controller.selectedImageBytes.value != null
                            ? Image.memory(controller.selectedImageBytes.value!, fit: BoxFit.cover)
                            : (widget.product.img!.isNotEmpty)
                                ? CustomWidgets.imageWidget(widget.product.img, false)
                                : CustomWidgets.noImage()),
                  ),
                ),
              )),
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
              print(fieldName);
              final url = StringConstants.four_in_one_names.firstWhere((element) => element['name'] == fieldName)['url'].toString();
              print(url);
              DialogsUtils().showSelectableDialog(
                context: context,
                title: label,
                url: url,
                targetController: textControllers[index],
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

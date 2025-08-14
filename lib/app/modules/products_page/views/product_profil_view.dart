import 'dart:async';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';

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
    textControllers[2].text = widget.product.createdAT.toString().replaceAll("T", " ").substring(0, 15);
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
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        children: [
                          CustomWidgets.counter(purchList.length - index),
                          _textPart(index, purchList[index].purchaseName!),
                          _textPart(index, purchList[index].datePurhcase!),
                          _textPart(index, purchList[index].priceOfSale!),
                          _textPart(index, purchList[index].count!),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Expanded _textPart(int index, String title) => Expanded(child: Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontSize: 20)));

  Widget _topText(List<PurchaseModelInsideProduct> displayList) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: ListviewTopText<PurchaseModelInsideProduct>(
        names: StringConstants.productInsidePurchase,
        listToSort: displayList,
        setSortedList: (newList) {},
        getSortValue: (model, key) {
          switch (key) {
            case 'title':
              return model.purchaseName ?? 0;
            case 'date':
              return model.datePurhcase.toString();
            case 'cost':
              return model.priceOfSale.toString();
            case 'count':
              return model.count.toString();

            default:
              return '';
          }
        },
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

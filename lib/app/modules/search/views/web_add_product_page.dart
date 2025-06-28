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
      CustomWidgets.showSnackBar("Hata", "Ürün adı boş bırakılamaz.", Colors.red);
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
    controller.selectedImageFileName.value = "${textControllers[0].text.replaceAll(' ', '_')}_image.png";
    productData['gram'] = (productData['gram'] == '' ? '0' : productData['gram'])!;
    await controller.addNewProduct(productData: productData, selectedImageBytes: controller.selectedImageBytes.value, selectedImageFileName: "${textControllers[0].text.replaceAll(' ', '_')}_image.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          backArrow: true,
          actionIcon: false,
          centerTitle: true,
          name: "Add Product",
        ),
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(
                horizontal: Get.size.width > 1000 ? Get.size.width / 4 : context.padding.horizontalMedium.left,
                vertical: 20.h,
              ),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      controller.pickImage();
                    },
                    child: Obx(() {
                      return Container(
                        width: Get.size.width > 600 ? 300 : Get.width * 0.6,
                        height: Get.size.width > 600 ? 300 : Get.width * 0.6,
                        margin: context.padding.medium,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: context.border.normalBorderRadius,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: context.border.normalBorderRadius,
                          child: controller.selectedImageBytes.value != null
                              ? Image.memory(controller.selectedImageBytes.value!, fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(IconlyLight.camera, size: 50, color: Colors.grey.shade700),
                                    SizedBox(height: 8.h),
                                    Text("Select Image", style: TextStyle(color: Colors.grey.shade700)),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ),
                ),
                _buildTextFields(context),
                SizedBox(height: 20.h),
                Center(
                  child: AgreeButton(
                    onTap: _handleAddProduct,
                    text: "Add Product",
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ],
        ));
  }

  Widget _buildTextFields(BuildContext context) {
    return Column(
      children: List.generate(fieldCount, (index) {
        final label = StringConstants.fieldLabels[index];

        final isSelectableField = index == 3 || index == 4 || index == 5 || index == 6;

        return CustomTextField(
          onTap: () {
            if (label.toLowerCase() == "date") {
              DateTime? selectedDateTime;
              showDateTimePicker(BuildContext context) async {
                final result = await CustomWidgets.showDateTimePickerWidget(context: context);
                if (result != null) {
                  setState(() {
                    selectedDateTime = result;
                    textControllers[2].text = DateFormat('yyyy-MM-dd, HH:mm').format(selectedDateTime!);
                  });
                }
              }

              showDateTimePicker(context);
            } else {
              if (isSelectableField) {
                focusNodes[index].unfocus();
                final fieldApiName = StringConstants.apiFieldNames[index];
                Map<String, String>? selectableInfo;
                try {
                  selectableInfo = StringConstants.four_in_one_names.firstWhere((element) => element['countName'] == fieldApiName);
                } catch (e) {}
                if (selectableInfo != null && selectableInfo['url'] != null) {
                  DialogsUtils().showSelectableDialog(
                    context: context,
                    title: "Select $label",
                    url: selectableInfo['url']!,
                    targetController: textControllers[index],
                    onIdSelected: (id) {
                      selectedIds[index] = id;
                    },
                  );
                } else {
                  CustomWidgets.showSnackBar("Configuration Error", "Cannot find URL for $label", Colors.red);
                }
              }
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/data/models/product_model.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductProfilView extends StatefulWidget {
  const ProductProfilView({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());
  List<TextEditingController> textControllers = List.generate(12, (_) => TextEditingController());
  String imageURL = "";
  void changeData(final ProductModel productModel) {
    imageURL = productModel.image!;

    updateFieldIfNotEmpty(productModel.name, 0);
    updateFieldIfNotEmpty(productModel.category, 1);
    updateFieldIfNotEmpty(productModel.brandName, 2);
    updateFieldIfNotEmpty(productModel.gramm.toString(), 3);
    updateFieldIfNotEmpty(productModel.material.toString(), 4);
    updateFieldIfNotEmpty('${productModel.sellPrice}', 5);
    updateFieldIfNotEmpty(productModel.location.toString(), 6);
    updateFieldIfNotEmpty(productModel.quantity.toString(), 7);
    updateFieldIfNotEmpty(productModel.note.toString(), 8);
    updateFieldIfNotEmpty(productModel.package.toString(), 9);
    updateFieldIfNotEmpty(productModel.cost.toString(), 10);
    if (selectedDateTime == null) {
      updateFieldIfNotEmpty(productModel.date.toString(), 11);
    }
  }

  void updateFieldIfNotEmpty(String? value, int index) {
    if (value!.isNotEmpty) {
      textControllers[index].text = value;
    }
  }

  Future<dynamic> changeTextFieldWithData(String name, int indexTile, String changeName) {
    return Get.defaultDialog(
        contentPadding: EdgeInsets.zero,
        title: changeName.tr,
        content: SizedBox(
          height: Get.height / 1.5,
          width: Get.width / 2,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection(name).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int indexx) {
                      return ListTile(
                          onTap: () {
                            textControllers[indexTile].text = snapshot.data!.docs[indexx]['name'];
                            Get.back();
                          },
                          title: Text(snapshot.data!.docs[indexx]['name']));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(thickness: 1, color: Colors.grey);
                    },
                  );
                }
                return Center(
                  child: spinKit(),
                );
              }),
        ));
  }

  DateTime? selectedDateTime;

  Column textFields(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
            readOnly: true, labelName: 'productName', maxline: 3, borderRadius: true, controller: textControllers[0], focusNode: focusNodes[0], requestfocusNode: focusNodes[1], unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[1].unfocus();
              changeTextFieldWithData('categories', 1, 'category');
            },
            readOnly: true,
            labelName: 'category',
            borderRadius: true,
            controller: textControllers[1],
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
            unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[2].unfocus();
              changeTextFieldWithData('brands', 2, 'brand');
            },
            readOnly: true,
            labelName: 'brand',
            borderRadius: true,
            controller: textControllers[2],
            focusNode: focusNodes[2],
            requestfocusNode: focusNodes[3],
            unFocus: true),
        CustomTextField(readOnly: true, labelName: 'gramm', borderRadius: true, controller: textControllers[3], focusNode: focusNodes[3], requestfocusNode: focusNodes[4], unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[4].unfocus();
              changeTextFieldWithData('materials', 4, 'material');
            },
            readOnly: true,
            labelName: 'material',
            borderRadius: true,
            controller: textControllers[4],
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[5],
            unFocus: true),
        CustomTextField(readOnly: true, labelName: 'sell_price', borderRadius: true, controller: textControllers[5], focusNode: focusNodes[5], requestfocusNode: focusNodes[6], unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[6].unfocus();
              changeTextFieldWithData('locations', 6, 'location');
            },
            readOnly: true,
            labelName: 'location',
            borderRadius: true,
            controller: textControllers[6],
            focusNode: focusNodes[6],
            requestfocusNode: focusNodes[7],
            unFocus: true),
        CustomTextField(readOnly: true, labelName: 'quantity', borderRadius: true, controller: textControllers[7], focusNode: focusNodes[7], requestfocusNode: focusNodes[8], unFocus: true),
        CustomTextField(readOnly: true, labelName: 'note', maxline: 3, borderRadius: true, controller: textControllers[8], focusNode: focusNodes[8], requestfocusNode: focusNodes[9], unFocus: true),
        CustomTextField(readOnly: true, labelName: 'package', borderRadius: true, controller: textControllers[9], focusNode: focusNodes[9], requestfocusNode: focusNodes[10], unFocus: true),
        CustomTextField(readOnly: true, labelName: 'cost', borderRadius: true, controller: textControllers[10], focusNode: focusNodes[10], requestfocusNode: focusNodes[11], unFocus: true),
        CustomTextField(
            readOnly: true,
            onTap: () async {
              final result = await showDateTimePickerWidget(context: context);
              if (result != null) {
                setState(() {
                  selectedDateTime = result;
                  textControllers[11].text = DateFormat('HH:mm, MMM d, yyyy').format(selectedDateTime!);
                });
              }
            },
            labelName: 'date',
            borderRadius: true,
            controller: textControllers[11],
            focusNode: focusNodes[11],
            requestfocusNode: focusNodes[1],
            unFocus: true),
        AgreeButton(
            onTap: () async {
              var fileInfo = await ImagePickerWeb.getImageInfo;
              if (fileInfo != null) {
                _photo = fileInfo.data;
                setState(() {});
              }
              uploadFile();
            },
            text: "uploadImage"),
        AgreeButton(
          onTap: () async {
            uploadData();
          },
          text: "agree",
        ),
        SizedBox(
          height: 30.h,
        )
      ],
    );
  }

  final HomeController homeController = Get.put(HomeController());

  uploadData() {
    List names = ['name', 'category', 'brand', 'gramm', 'material', 'sell_price', 'location', 'quantity', 'note', 'package', 'cost', 'date'];
    homeController.agreeButton.value = !homeController.agreeButton.value;
    for (int i = 0; i < names.length; i++) {
      FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({
        "${names[i]}": names[i] == 'quantity' ? int.parse(textControllers[i].text.toString()) : textControllers[i].text,
      });
    }
    showSnackBar("Done", "Product data changed", Colors.green);
    homeController.agreeButton.value = !homeController.agreeButton.value;
  }

  Uint8List? _photo;
  final ImagePickerWeb _picker = ImagePickerWeb();
  Future uploadFile() async {
    DateTime now = DateTime.now();
    final storageRef = FirebaseStorage.instance.ref().child('images/$now.png');
    List<int> imageBytes = _photo!;
    String base64Image = base64Encode(imageBytes);
    await storageRef.putString(base64Image, format: PutStringFormat.base64, metadata: SettableMetadata(contentType: 'image/png')).then((p0) async {
      var dowurl = await storageRef.getDownloadURL();
      String url = dowurl.toString();
      await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({"image": url});
      showSnackBar("Done", "image succesfully uploaded", Colors.green);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCustom(context),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').doc(widget.product.documentID!).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return spinKit();
            } else if (snapshot.hasError) {
              return errorData();
            } else if (snapshot.hasData) {
              final product = ProductModel(
                name: snapshot.data!['name'].toString(),
                date: snapshot.data!['date'].toString(),
                brandName: snapshot.data!['brand'].toString(),
                category: snapshot.data!['category'].toString(),
                cost: snapshot.data!['cost'].toString(),
                gramm: snapshot.data!['gramm'].toString(),
                image: snapshot.data!['image'].toString(),
                location: snapshot.data!['location'].toString(),
                material: snapshot.data!['material'].toString(),
                quantity: snapshot.data!['quantity'],
                sellPrice: snapshot.data!['sell_price'].toString(),
                note: snapshot.data!['note'].toString(),
                package: snapshot.data!['package'].toString(),
                documentID: snapshot.data!.id,
              );
              changeData(product);
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: Get.size.width / 4),
                children: [
                  Container(
                    width: Get.size.width / 3,
                    height: Get.size.height / 3,
                    decoration: const BoxDecoration(color: Colors.grey, borderRadius: borderRadius25),
                    child: ClipRRect(
                      borderRadius: borderRadius25,
                      child: _photo == null
                          ? Image.network(
                              product.image!,
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                  ),
                                );
                              },
                            )
                          : SizedBox(
                              width: Get.size.width / 3,
                              height: Get.size.height / 3,
                              child: ClipRRect(
                                borderRadius: borderRadius20,
                                child: Image.memory(
                                  _photo!,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                    ),
                  ),
                  textFields(context)
                ],
              );
            }
            return const Text("No data");
          }),
    );
  }

  final SeacrhViewController searchViewController = Get.put(SeacrhViewController());

  CustomAppBar appBarCustom(BuildContext context) {
    return CustomAppBar(
        backArrow: true,
        centerTitle: true,
        actionIcon: true,
        icon: IconButton(
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text('This action will permanently delete this PRODUCT'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        print(widget.product.image);

                        await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).delete().then((value) async {
                          if (widget.product.image == '' || widget.product.image == null) {
                          } else {
                            var storageRef = FirebaseStorage.instance.refFromURL(widget.product.image!);
                            await storageRef.delete().then((value) {});
                          }
                          print(searchViewController.productsList.length);
                          searchViewController.productsList.removeWhere((element) => element['name'] == widget.product.name);
                          print(searchViewController.productsList.length);

                          showSnackBar("Deleted", "Succesfully deleted your product", Colors.green);
                        });
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              IconlyLight.delete,
              color: Colors.black,
            )),
        name: widget.product.name!);
  }
}

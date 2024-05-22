import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class WebAddProductPage extends StatefulWidget {
  const WebAddProductPage({super.key});

  @override
  State<WebAddProductPage> createState() => _WebAddProductPageState();
}

class _WebAddProductPageState extends State<WebAddProductPage> {
  List<TextEditingController> textControllers = List.generate(12, (_) => TextEditingController());

  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());

  Future<dynamic> onTapBottomSheetToSelectBrand(String name, int indexTile, String changeName) {
    return Get.defaultDialog(
        title: changeName,
        content: SizedBox(
          height: Get.height / 2,
          width: Get.width / 2,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection(name).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int indexx) {
                      return ListTile(
                        onTap: () {
                          textControllers[indexTile].text = snapshot.data!.docs[indexx]['name'];
                          Get.back();
                        },
                        title: Text(snapshot.data!.docs[indexx]['name']),
                      );
                    },
                  );
                }
                return Center(
                  child: spinKit(),
                );
              }),
        ));
  }

  final HomeController _homeController = Get.put(HomeController());

  Uint8List? _photo;
  Future uploadFile() async {
    _homeController.agreeButton.value = !_homeController.agreeButton.value;
    DateTime now = DateTime.now();
    final storageRef = FirebaseStorage.instance.ref().child('images/$now.png');
    List<int> imageBytes = _photo!;
    String base64Image = base64Encode(imageBytes);
    await storageRef.putString(base64Image, format: PutStringFormat.base64, metadata: SettableMetadata(contentType: 'image/png')).then((p0) async {
      var dowurl = await storageRef.getDownloadURL();
      String url = dowurl.toString();
      addData(url);
    });
  }

  final SeacrhViewController searchViewController = Get.put(SeacrhViewController());

  addData(String imageURL) async {
    String documentID = '';

    try {
      if (textControllers[9].text.isEmpty || textControllers[9].text == "") {
        showSnackBar("Error", "Add Product Quantity", Colors.red);
      } else {
        _homeController.agreeButton.value = !_homeController.agreeButton.value;
        await FirebaseFirestore.instance.collection('products').add({
          'image': imageURL,
          'name': textControllers[0].text,
          'brand': textControllers[1].text,
          'category': textControllers[2].text,
          'material': textControllers[3].text,
          'location': textControllers[4].text,
          'gramm': textControllers[5].text,
          'date': textControllers[6].text,
          'note': textControllers[7].text,
          'package': textControllers[8].text,
          'quantity': int.parse(textControllers[9].text.toString()),
          'cost': textControllers[10].text == '' ? '0.0' : textControllers[10].text,
          'sell_price': textControllers[11].text,
        }).then((value) {
          documentID = value.id;
          _homeController.agreeButton.value = !_homeController.agreeButton.value;
        });
      }
    } on Exception catch (e) {
      _homeController.agreeButton.value = false;
      showSnackBar("Error", e.toString(), Colors.red);
    } catch (e) {
      _homeController.agreeButton.value = false;

      showSnackBar("Error", e.toString(), Colors.red);
    }
    await FirebaseFirestore.instance.collection('products').doc(documentID).get().then((value22) {
      searchViewController.productsList.add(value22);
      Get.back();
      showSnackBar("Done", "Product added succesfully", Colors.green);
    });
    searchViewController.productsList.sort(
      (a, b) {
        return b['date'].compareTo(a['date']);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    textControllers[6].text = DateTime.now().toString().substring(0, 16);
    return Scaffold(
      appBar: const CustomAppBar(backArrow: true, actionIcon: false, centerTitle: true, name: "Add product"),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: Get.size.width / 4),
        children: [
          _photo == null
              ? GestureDetector(
                  onTap: () async {
                    var fileInfo = await ImagePickerWeb.getImageInfo;
                    if (fileInfo != null) {
                      _photo = fileInfo.data;
                      setState(() {});
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.grey, borderRadius: borderRadius25),
                    width: 100,
                    height: Get.height / 3,
                    child: Icon(
                      Icons.add,
                      color: Colors.grey[800],
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: borderRadius20,
                  child: Image.memory(
                    _photo!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.fill,
                  ),
                ),
          CustomTextField(labelName: "Product Name", borderRadius: true, controller: textControllers[0], focusNode: focusNodes[0], requestfocusNode: focusNodes[1], unFocus: false, readOnly: true),
          CustomTextField(
              onTap: () {
                focusNodes[1].unfocus();
                onTapBottomSheetToSelectBrand('brands', 1, 'brand');
              },
              readOnly: true,
              labelName: 'brand',
              borderRadius: true,
              controller: textControllers[1],
              focusNode: focusNodes[1],
              requestfocusNode: focusNodes[2],
              unFocus: true),
          CustomTextField(
              onTap: () {
                focusNodes[2].unfocus();
                onTapBottomSheetToSelectBrand('categories', 2, 'category');
              },
              readOnly: true,
              labelName: 'category',
              borderRadius: true,
              controller: textControllers[2],
              focusNode: focusNodes[2],
              requestfocusNode: focusNodes[3],
              unFocus: true),
          CustomTextField(
              onTap: () {
                focusNodes[3].unfocus();
                onTapBottomSheetToSelectBrand('materials', 3, 'material');
              },
              readOnly: true,
              labelName: 'material',
              borderRadius: true,
              controller: textControllers[3],
              focusNode: focusNodes[3],
              requestfocusNode: focusNodes[4],
              unFocus: true),
          CustomTextField(
              onTap: () {
                focusNodes[4].unfocus();
                onTapBottomSheetToSelectBrand('locations', 4, 'location');
              },
              readOnly: true,
              labelName: 'location',
              borderRadius: true,
              controller: textControllers[4],
              focusNode: focusNodes[4],
              requestfocusNode: focusNodes[5],
              unFocus: true),
          CustomTextField(labelName: "Gramm", borderRadius: true, controller: textControllers[5], focusNode: focusNodes[5], requestfocusNode: focusNodes[6], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Date", borderRadius: true, controller: textControllers[6], focusNode: focusNodes[6], requestfocusNode: focusNodes[7], unFocus: false, readOnly: false),
          CustomTextField(labelName: "Note", maxline: 4, borderRadius: true, controller: textControllers[7], focusNode: focusNodes[7], requestfocusNode: focusNodes[8], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Package", borderRadius: true, controller: textControllers[8], focusNode: focusNodes[8], requestfocusNode: focusNodes[9], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Quantity", borderRadius: true, controller: textControllers[9], focusNode: focusNodes[9], requestfocusNode: focusNodes[10], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Cost", borderRadius: true, controller: textControllers[10], focusNode: focusNodes[10], requestfocusNode: focusNodes[11], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Sell Price", borderRadius: true, controller: textControllers[11], focusNode: focusNodes[11], requestfocusNode: focusNodes[1], unFocus: false, readOnly: true),
          AgreeButton(
              onTap: () {
                _photo == null ? addData("") : uploadFile();
              },
              text: "add_product")
        ],
      ),
    );
  }
}

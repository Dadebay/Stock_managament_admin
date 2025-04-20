import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

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
                return CustomWidgets.spinKit();
              }),
        ));
  }

  final HomeController _homeController = Get.put(HomeController());
  @override
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
      addProductAndImage(url);
    });
  }

  final SeacrhViewController searchViewController = Get.put(SeacrhViewController());
  final SalesController salesController = Get.put(SalesController());

  addProductAndImage(String imageURL) async {
    String documentID = '';
    try {
      if (textControllers[9].text.isEmpty || textControllers[9].text == "") {
        CustomWidgets.showSnackBar("Error", "Add Product Quantity", Colors.red);
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
      CustomWidgets.showSnackBar("Error", e.toString(), Colors.red);
    } catch (e) {
      _homeController.agreeButton.value = false;

      CustomWidgets.showSnackBar("Error", e.toString(), Colors.red);
    }
    await FirebaseFirestore.instance.collection('products').doc(documentID).get().then((value22) {
      searchViewController.productsList.add(value22);

      Get.back();
      CustomWidgets.showSnackBar("Done", "Product added succesfully", Colors.green);
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
        padding: EdgeInsets.symmetric(horizontal: Get.size.width / 4, vertical: 20.h),
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
                    decoration: BoxDecoration(color: Colors.grey, borderRadius: context.border.highBorderRadius),
                    width: 100,
                    height: Get.height / 3,
                    child: Icon(
                      Icons.add,
                      color: Colors.grey[800],
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: context.border.highBorderRadius,
                  child: Image.memory(
                    _photo!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.fill,
                  ),
                ),
          CustomTextField(
            labelName: "Product Name",
            controller: textControllers[0],
            focusNode: focusNodes[0],
            requestfocusNode: focusNodes[1],
          ),
          CustomTextField(
            onTap: () {
              focusNodes[1].unfocus();
              onTapBottomSheetToSelectBrand('brands', 1, 'brand');
            },
            labelName: 'brand',
            controller: textControllers[1],
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
          ),
          CustomTextField(
            onTap: () {
              focusNodes[2].unfocus();
              onTapBottomSheetToSelectBrand('categories', 2, 'category');
            },
            labelName: 'category',
            controller: textControllers[2],
            focusNode: focusNodes[2],
            requestfocusNode: focusNodes[3],
          ),
          CustomTextField(
            onTap: () {
              focusNodes[3].unfocus();
              onTapBottomSheetToSelectBrand('materials', 3, 'material');
            },
            labelName: 'material',
            controller: textControllers[3],
            focusNode: focusNodes[3],
            requestfocusNode: focusNodes[4],
          ),
          CustomTextField(
            onTap: () {
              focusNodes[4].unfocus();
              onTapBottomSheetToSelectBrand('locations', 4, 'location');
            },
            labelName: 'location',
            controller: textControllers[4],
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[5],
          ),
          CustomTextField(
            labelName: "Gramm",
            controller: textControllers[5],
            focusNode: focusNodes[5],
            requestfocusNode: focusNodes[6],
          ),
          CustomTextField(
            labelName: "Date",
            controller: textControllers[6],
            focusNode: focusNodes[6],
            requestfocusNode: focusNodes[7],
          ),
          CustomTextField(
            labelName: "Note",
            maxLine: 4,
            controller: textControllers[7],
            focusNode: focusNodes[7],
            requestfocusNode: focusNodes[8],
          ),
          CustomTextField(
            labelName: "Package",
            controller: textControllers[8],
            focusNode: focusNodes[8],
            requestfocusNode: focusNodes[9],
          ),
          CustomTextField(
            labelName: "Quantity",
            controller: textControllers[9],
            focusNode: focusNodes[9],
            requestfocusNode: focusNodes[10],
          ),
          CustomTextField(
            labelName: "Cost",
            controller: textControllers[10],
            focusNode: focusNodes[10],
            requestfocusNode: focusNodes[11],
          ),
          CustomTextField(
            labelName: "Sell Price",
            controller: textControllers[11],
            focusNode: focusNodes[11],
            requestfocusNode: focusNodes[1],
          ),
          AgreeButton(
              onTap: () {
                _photo == null ? addProductAndImage("") : uploadFile();
              },
              text: "add")
        ],
      ),
    );
  }
}

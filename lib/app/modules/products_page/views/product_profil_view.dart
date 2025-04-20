import 'dart:async';
import 'dart:convert';

import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/product/cards/purchase_card.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

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

  @override
  void initState() {
    super.initState();
    homeController.agreeButton.value = false;
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
                return CustomWidgets.spinKit();
              }),
        ));
  }

  DateTime? selectedDateTime;

  Column textFields(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          labelName: 'productName',
          maxLine: 3,
          controller: textControllers[0],
          focusNode: focusNodes[0],
          requestfocusNode: focusNodes[1],
        ),
        CustomTextField(
          onTap: () {
            focusNodes[1].unfocus();
            changeTextFieldWithData('categories', 1, 'category');
          },
          labelName: 'category',
          controller: textControllers[1],
          focusNode: focusNodes[1],
          requestfocusNode: focusNodes[2],
        ),
        CustomTextField(
          onTap: () {
            focusNodes[2].unfocus();
            changeTextFieldWithData('brands', 2, 'brand');
          },
          labelName: 'brand',
          controller: textControllers[2],
          focusNode: focusNodes[2],
          requestfocusNode: focusNodes[3],
        ),
        CustomTextField(
          labelName: 'gramm',
          controller: textControllers[3],
          focusNode: focusNodes[3],
          requestfocusNode: focusNodes[4],
        ),
        CustomTextField(
          onTap: () {
            focusNodes[4].unfocus();
            changeTextFieldWithData('materials', 4, 'material');
          },
          labelName: 'material',
          controller: textControllers[4],
          focusNode: focusNodes[4],
          requestfocusNode: focusNodes[5],
        ),
        CustomTextField(
          labelName: 'sell_price',
          controller: textControllers[5],
          focusNode: focusNodes[5],
          requestfocusNode: focusNodes[6],
        ),
        CustomTextField(
          onTap: () {
            focusNodes[6].unfocus();
            changeTextFieldWithData('locations', 6, 'location');
          },
          labelName: 'location',
          controller: textControllers[6],
          focusNode: focusNodes[6],
          requestfocusNode: focusNodes[7],
        ),
        CustomTextField(
          labelName: 'quantity',
          controller: textControllers[7],
          focusNode: focusNodes[7],
          requestfocusNode: focusNodes[8],
        ),
        CustomTextField(
          labelName: 'note',
          maxLine: 3,
          controller: textControllers[8],
          focusNode: focusNodes[8],
          requestfocusNode: focusNodes[9],
        ),
        CustomTextField(
          labelName: 'package',
          controller: textControllers[9],
          focusNode: focusNodes[9],
          requestfocusNode: focusNodes[10],
        ),
        CustomTextField(
          labelName: 'cost',
          controller: textControllers[10],
          focusNode: focusNodes[10],
          requestfocusNode: focusNodes[11],
        ),
        CustomTextField(
          onTap: () async {
            final result = await CustomWidgets.showDateTimePickerWidget(context: context);
            if (result != null) {
              setState(() {
                selectedDateTime = result;
                textControllers[11].text = DateFormat('yyyy-MM-dd , HH:mm').format(selectedDateTime!);
              });
            }
          },
          labelName: 'date',
          controller: textControllers[11],
          focusNode: focusNodes[11],
          requestfocusNode: focusNodes[1],
        ),
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
    CustomWidgets.showSnackBar("Done", "Product data changed", Colors.green);
    homeController.agreeButton.value = !homeController.agreeButton.value;
  }

  Uint8List? _photo;
  Future uploadFile() async {
    DateTime now = DateTime.now();
    final storageRef = FirebaseStorage.instance.ref().child('images/$now.png');
    List<int> imageBytes = _photo!;
    String base64Image = base64Encode(imageBytes);
    await storageRef.putString(base64Image, format: PutStringFormat.base64, metadata: SettableMetadata(contentType: 'image/png')).then((p0) async {
      var dowurl = await storageRef.getDownloadURL();
      String url = dowurl.toString();
      await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({"image": url});
      CustomWidgets.showSnackBar("Done", "image succesfully uploaded", Colors.green);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarCustom(context),
      body: Row(
        children: [
          Expanded(child: productView()),
          Expanded(
            child: Column(
              children: [
                // CustomWidgets().topWidgetPurchases(true),
                Expanded(
                  child: FirestorePagination(
                    limit: 20, // Defaults to 10.
                    isLive: true, // Defaults to false.
                    viewType: ViewType.list,
                    reverse: false,
                    query: FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).collection('purchases').orderBy("date", descending: true),
                    itemBuilder: (context, documentSnapshot, index) {
                      final data = documentSnapshot.data() as Map<String, dynamic>?;
                      if (data == null) return Container();

                      final purchases =
                          PurchasesModel(title: data['title'].toString(), date: data['date'].toString(), note: data['note'].toString(), cost: data['cost'].toString(), productsCount: data['product_count'].toString(), source: data['source'].toString(), purchasesID: data['purchase_id'].toString());
                      return PurchaseCard(
                        showInProductProfil: true,
                        purchasesModel: purchases,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 5,
                        thickness: 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> productView() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').doc(widget.product.documentID!).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorData();
          } else if (snapshot.hasData) {
            final product = ProductModel(
              name: snapshot.data!['name'] == null ? '' : snapshot.data!['name'].toString(),
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
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                Container(
                  width: Get.size.width / 3,
                  height: Get.size.height / 2,
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: context.border.highBorderRadius),
                  child: ClipRRect(
                    borderRadius: context.border.highBorderRadius,
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
                              borderRadius: context.border.highBorderRadius,
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
        });
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
                        final snapshot = await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).collection('purchases').get();
                        for (var doc in snapshot.docs) {
                          doc.reference.delete();
                        }

                        await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).delete().then((value) async {
                          if (widget.product.image == '' || widget.product.image == null) {
                          } else {
                            var storageRef = FirebaseStorage.instance.refFromURL(widget.product.image!);
                            await storageRef.delete().then((value) {});
                          }
                          searchViewController.productsList.removeWhere((element) => element['name'] == widget.product.name);
                          CustomWidgets.showSnackBar("Deleted", "Succesfully deleted your product", Colors.green);
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

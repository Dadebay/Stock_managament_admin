import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/data/models/product_model.dart';
import 'package:stock_managament_admin/app/data/models/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_controller.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/constants/cards/product_card.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class PurchasesProductsView extends StatefulWidget {
  final PurchasesModel purchasesModel;
  final bool showInProductsView;
  const PurchasesProductsView({super.key, required this.purchasesModel, required this.showInProductsView});
  @override
  State<PurchasesProductsView> createState() => _PurchasesProductsViewState();
}

class _PurchasesProductsViewState extends State<PurchasesProductsView> {
  final SalesController salesController = Get.put(SalesController());
  final PurchasesController purchasesController = Get.put(PurchasesController());

  final SeacrhViewController seacrhViewController = Get.put(SeacrhViewController());

  final List _topPartNames = [
    {'name': 'Product Name', 'sortName': "quantity"},
    {'name': 'Cost', 'sortName': "cost"},
    {'name': 'Sell Price', 'sortName': "sell_price"},
    {'name': 'Brand', 'sortName': "brand"},
    {'name': 'Category', 'sortName': "category"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('purchases').doc(widget.purchasesModel.purchasesID!).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return spinKit();
            } else if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: textsWidgetsListview(context, snapshot),
                  ),
                  topWidgetTextPart(addMorePadding: false, names: _topPartNames, ordersView: false, clientView: false, purchasesView: false),
                  productsListview()
                ],
              );
            }
            return emptyData();
          }),
    );
  }

  AppBar customAppBar(BuildContext context) {
    return AppBar(
      title:
          Text('${"Purchases".tr}   #${widget.purchasesModel.purchasesID!.length < 5 ? widget.purchasesModel.purchasesID : widget.purchasesModel.purchasesID.toString().substring(0, 5).toString()}'),
      centerTitle: true,
      actions: [
        IconButton(
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text('This action will permanently delete this PURCHASE'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        final snapshot = await FirebaseFirestore.instance.collection('purchases').doc(widget.purchasesModel.purchasesID).collection('products').get();
                        for (var doc in snapshot.docs) {
                          doc.reference.delete();
                        }

                        await FirebaseFirestore.instance.collection('purchases').doc(widget.purchasesModel.purchasesID).delete().then((value) async {
                          purchasesController.purchasesMainList.removeWhere((element) => element.id == widget.purchasesModel.purchasesID);
                          showSnackBar("Deleted", "Succesfully deleted your PURCHASE", Colors.green);
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
      ],
      leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(IconlyLight.arrowLeftCircle, color: Colors.black)),
    );
  }

  Wrap textsWidgetsListview(BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    List namesList = [
      {'text1': 'Title', "text2": 'title'},
      {'text1': 'Date Purchases', "text2": 'date'},
      {'text1': 'Source', "text2": 'source'},
      {'text1': 'Cost', "text2": 'cost'},
      {'text1': 'Products Count', "text2": 'product_count'},
      {'text1': 'note', "text2": 'note'},
    ];
    return Wrap(
        children: List.generate(
            namesList.length,
            (index) => textWidgetOrderedPage(
                text1: namesList[index]['text1'],
                text2: namesList[index]['text2'].toString() == "cost" ? "${snapshot.data![namesList[index]['text2']] ?? "Empty"} \$" : "${snapshot.data![namesList[index]['text2']] ?? "Empty"}",
                firebaseName: namesList[index]['text2'])));
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchData() async {
    final snapshot = await FirebaseFirestore.instance.collection('purchases').doc(widget.purchasesModel.purchasesID).collection('products').get();
    return snapshot;
  }

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> productsListview() {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return spinKit();
          } else if (snapshot.hasError) {
            return errorData();
          } else if (snapshot.data!.docs.isEmpty) {
            return emptyData();
          } else if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final product = ProductModel(
                  name: snapshot.data!.docs[index]['name'],
                  brandName: snapshot.data!.docs[index]['brand'].toString(),
                  category: snapshot.data!.docs[index]['category'].toString(),
                  cost: snapshot.data!.docs[index]['cost'].toString(),
                  gramm: snapshot.data!.docs[index]['gramm'].toString(),
                  image: snapshot.data!.docs[index]['image'].toString(),
                  location: snapshot.data!.docs[index]['location'].toString(),
                  material: snapshot.data!.docs[index]['material'].toString(),
                  quantity: int.parse(snapshot.data!.docs[index]['quantity'].toString()),
                  sellPrice: snapshot.data!.docs[index]['sell_price'].toString(),
                  note: snapshot.data!.docs[index]['note'].toString(),
                  package: snapshot.data!.docs[index]['package'].toString(),
                  documentID: snapshot.data!.docs[index].id,
                );

                return ProductCard(
                  addCounterWidget: false,
                  product: product,
                  disableOnTap: true,
                );
              },
            );
          }

          return const Text("No data");
        });
  }

  Widget textWidgetOrderedPage({required String text1, required String text2, required String firebaseName}) {
    FocusNode focusNode = FocusNode();
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = text2;

    return GestureDetector(
      onTap: () {
        Get.defaultDialog(
            title: text1.tr,
            contentPadding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
            content: CustomTextField(
                onTap: () {
                  if (firebaseName == 'date') {
                    DateTime? selectedDateTime;
                    showDateTimePicker(BuildContext context) async {
                      final result = await showDateTimePickerWidget(context: context);
                      if (result != null) {
                        setState(() {
                          selectedDateTime = result;
                          textEditingController.text = DateFormat('yyyy-MM-dd , HH:mm').format(selectedDateTime!);
                        });
                      }
                    }

                    showDateTimePicker(context);
                  }
                },
                labelName: text1.toString(),
                controller: textEditingController,
                focusNode: focusNode,
                requestfocusNode: focusNode,
                unFocus: false,
                readOnly: true),
            actions: [
              TextButton(
                child: Text('no'.tr, style: TextStyle(fontFamily: gilroyMedium, fontSize: 18.sp)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('yes'.tr, style: TextStyle(fontFamily: gilroyBold, fontSize: 18.sp)),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('purchases').doc(widget.purchasesModel.purchasesID).update({firebaseName: textEditingController.text}).then((value) {
                    showSnackBar("copySucces", "changesUpdated", Colors.green);
                  });
                  purchasesController.purchasesMainList.removeWhere((element) => element.id == widget.purchasesModel.purchasesID);
                  await FirebaseFirestore.instance.collection('purchases').doc(widget.purchasesModel.purchasesID).get().then((value) {
                    purchasesController.purchasesMainList.add(value);
                  });
                  purchasesController.purchasesMainList.sort((a, b) => b['date'].compareTo(a['date']));

                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text1.tr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyMedium, fontSize: 14.sp),
                ),
                Text(
                  text2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
                )
              ],
            ),
            Divider(
              color: Colors.grey.shade200,
            )
          ],
        ),
      ),
    );
  }
}
